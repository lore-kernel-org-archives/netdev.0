From: Pavel =?utf-8?q?Mat=C4=9Bja?= <pavel@netsafe.cz>
Subject: sky2: only 10Mb/s
Date: Sat, 15 Oct 2011 19:58:31 +0200
Message-ID: <201110151958.31300.pavel@netsafe.cz>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate1.netsafe.cz ([83.223.49.132]:54053 "EHLO gate1.netsafe.cz"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752631Ab1JOSFN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 15 Oct 2011 14:05:13 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,
I tested new kernel and I have found out I have only 10Mb/s link instead of 
100Mb/s to my router.
If I did the git bisect right it was caused by commit 
4fb99cd6ac4fe6d03a334a6f4ebb2bbfc4b479ed

My card is (lspci -v):
05:00.0 Ethernet controller: Marvell Technology Group Ltd. Yukon Optima 
88E8059 [PCIe Gigabit Ethernet Controller with AVB] (rev 11)
        Subsystem: ASUSTeK Computer Inc. Device 8439
        Flags: bus master, fast devsel, latency 0, IRQ 80
        Memory at fe6fc000 (64-bit, non-prefetchable) [size=16K]
        I/O ports at b800 [size=256]
        Expansion ROM at fe6c0000 [disabled] [size=128K]
        Capabilities: [48] Power Management version 3
        Capabilities: [5c] MSI: Enable+ Count=1/1 Maskable- 64bit+
        Capabilities: [c0] Express Legacy Endpoint, MSI 00
        Capabilities: [100] Advanced Error Reporting
        Capabilities: [130] Device Serial Number a5-89-6d-ff-ff-30-cf-20
        Kernel driver in use: sky2

Can anybody help me?
-- 
Pavel Mateja
