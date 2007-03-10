From: "Randy Dunlap" <rdunlap@xenotime.net>
Subject: SSB/b44 build failure
Date: Fri, 9 Mar 2007 19:14:09 -0800
Message-ID: <1173496449.13449@shark.he.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org
To: mb@bu3sch.de, bunk@stusta.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from xenotime.net ([66.160.160.81]:37934 "HELO xenotime.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1752598AbXCJDOO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 9 Mar 2007 22:14:14 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

In 2.6.21-rc3-mm2, with CONFIG_SSB=y but all other SSB kconfig
symbols disabled, I get this (on x86_64):

drivers/built-in.o: In function `b44_init':
b44.c:(.init.text+0x6e04): undefined reference to `ssb_pcihost_register'
b44.c:(.init.text+0x6e2c): undefined reference to `ssb_pcihost_unregister'
drivers/built-in.o: In function `b44_cleanup':
b44.c:(.exit.text+0x63b): undefined reference to `ssb_pcihost_unregister'
make: *** [.tmp_vmlinux1] Error 1

---
~Randy
I don't have time to look into a fix for it.

