From: Faidon Liambotis <faidon@cube.gr>
Subject: [PATCH 2.6.17-rc6] Add two PLX device IDs
Date: Sat, 10 Jun 2006 20:54:58 +0300
Message-ID: <20060610175458.GB4617@divinity>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jouni Malinen <jkmaline@cc.hut.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from linux7.grserver.gr ([64.34.170.238]:13444 "EHLO
	linux7.grserver.gr") by vger.kernel.org with ESMTP id S1030462AbWFJRzB
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 10 Jun 2006 13:55:01 -0400
To: netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch adds device IDs for Symbol LA-4123 and Global Sun Tech
GL24110P to the HostAP PLX driver.
This is not tested with real hardware, but there is no reason why it
shouldn't work.
Please test.

Signed-off-by: Faidon Liambotis <faidon@cube.gr>

--
 hostap_plx.c |    2 ++
 1 files changed, 2 insertions(+)

diff -Nur linux-2.6.17-rc6/drivers/net/wireless/hostap/hostap_plx.c linux/drivers/net/wireless/hostap/hostap_plx.c
--- linux-2.6.17-rc6/drivers/net/wireless/hostap/hostap_plx.c	2006-06-06 03:57:02.000000000 +0300
+++ linux/drivers/net/wireless/hostap/hostap_plx.c	2006-06-10 19:20:10.000000000 +0300
@@ -67,10 +67,12 @@
 	PLXDEV(0x10b7, 0x7770, "3Com AirConnect PCI 777A"),
 	PLXDEV(0x111a, 0x1023, "Siemens SpeedStream SS1023"),
 	PLXDEV(0x126c, 0x8030, "Nortel emobility"),
+	PLXDEV(0x1562, 0x0001, "Symbol LA-4123"),
 	PLXDEV(0x1385, 0x4100, "Netgear MA301"),
 	PLXDEV(0x15e8, 0x0130, "National Datacomm NCP130 (PLX9052)"),
 	PLXDEV(0x15e8, 0x0131, "National Datacomm NCP130 (TMD7160)"),
 	PLXDEV(0x1638, 0x1100, "Eumitcom WL11000"),
+	PLXDEV(0x16ab, 0x1100, "Global Sun Tech GL24110P"),
 	PLXDEV(0x16ab, 0x1101, "Global Sun Tech GL24110P (?)"),
 	PLXDEV(0x16ab, 0x1102, "Linksys WPC11 with WDT11"),
 	PLXDEV(0x16ab, 0x1103, "Longshine 8031"),
