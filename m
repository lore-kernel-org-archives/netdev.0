From: "Randy.Dunlap" <rdunlap@xenotime.net>
Subject: IOAT stuff
Date: Mon, 26 Jun 2006 15:29:39 -0700
Message-ID: <20060626152939.962b56e6.rdunlap@xenotime.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xenotime.net ([66.160.160.81]:57496 "HELO xenotime.net")
	by vger.kernel.org with SMTP id S933097AbWFZW1C (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Jun 2006 18:27:02 -0400
Received: from midway.site ([71.245.108.25]) by xenotime.net for <netdev@vger.kernel.org>; Mon, 26 Jun 2006 15:26:57 -0700
To: christopher.leech@intel.com, andrew.grover@intel.com
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


drivers/dma/ioatdma.c:830: warning: no return statement in function returning non-void
drivers/dma/ioatdma.c:830: warning: control reaches end of non-void function

Maybe insert "return" in front of:

	pci_module_init(&ioat_pci_drv);

or is there some reason not to do that?

BTW, pci_module_init() is obsolete.  Drivers should be using
pci_register_driver() instead.


PS:  IOAT/DMA (whatever) needs a MAINTAINERS entry.

---
~Randy
