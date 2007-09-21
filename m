From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: [PATCH 1/2] bnx2: factor out gzip unpacker
Date: Fri, 21 Sep 2007 22:03:33 +0100
Message-ID: <20070921220333.3b31afb5@the-village.bc.nu>
References: <200709211201.24475.vda.linux@googlemail.com>
	<200709211905.23946.vda.linux@googlemail.com>
	<15775.1190399812@turing-police.cc.vt.edu>
	<200709212018.06553.vda.linux@googlemail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Valdis.Kletnieks@vt.edu, David Miller <davem@davemloft.net>,
	jeff@garzik.org, mchan@broadcom.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Denys Vlasenko <vda.linux@googlemail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from outpipe-village-512-1.bc.nu ([81.2.110.250]:49295 "EHLO
	the-village.bc.nu" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S1765271AbXIUU4t (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Sep 2007 16:56:49 -0400
In-Reply-To: <200709212018.06553.vda.linux@googlemail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> For example, bnx2 maintainer says that driver and
> firmware are closely tied for his driver. IOW: you upgrade kernel
> and your NIC is not working anymore.
> 
> Another argument is to make kernel be able to bring up NICs
> without needing firmware images in initramfs/initrd/hard drive.

dgrs should be using the request_firmware interface. Actually dgrs is
probably a good candidate for /dev/null

Alan
