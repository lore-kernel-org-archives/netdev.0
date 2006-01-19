From: Adrian Bunk <bunk@stusta.de>
Subject: [2.6 patch] schedule SHAPER for removal
Date: Thu, 19 Jan 2006 03:11:50 +0100
Message-ID: <20060119021150.GC19398@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>, jgarzik@pobox.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1161154AbWASCMM@vger.kernel.org>
To: Andrew Morton <akpm@osdl.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Signed-off-by: Adrian Bunk <bunk@stusta.de>

---

This patch was already sent on:
- 13 Jan 2006

--- linux-2.6.15-mm3-full/Documentation/feature-removal-schedule.txt.old	2006-01-13 15:02:15.000000000 +0100
+++ linux-2.6.15-mm3-full/Documentation/feature-removal-schedule.txt	2006-01-13 15:06:19.000000000 +0100
@@ -164,0 +165,6 @@
+---------------------------
+
+What:   Traffic Shaper (CONFIG_SHAPER)
+When:   July 2006
+Why:    obsoleted by the code in net/sched/
+Who:    Adrian Bunk <bunk@stusta.de
--- linux-2.6.15-mm3-full/drivers/net/Kconfig.old	2006-01-13 15:06:34.000000000 +0100
+++ linux-2.6.15-mm3-full/drivers/net/Kconfig	2006-01-13 15:06:49.000000000 +0100
@@ -2663,7 +2663,7 @@
 	  "SCSI generic support".
 
 config SHAPER
-	tristate "Traffic Shaper (EXPERIMENTAL)"
+	tristate "Traffic Shaper (OBSOLETE)"
 	depends on EXPERIMENTAL
 	---help---
 	  The traffic shaper is a virtual network device that allows you to
