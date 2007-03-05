From: Adrian Bunk <bunk@stusta.de>
Subject: [2.6 patch] make drivers/net/s2io.c:vlan_strip_flag static
Date: Mon, 5 Mar 2007 02:49:25 +0100
Message-ID: <20070305014925.GX3441@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Jeff Garzik <jeff@garzik.org>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Sivakumar Subramani <sivakumar.subramani@neterion.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751747AbXCEBuM@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch makes the needlessly global vlan_strip_flag static.

Signed-off-by: Adrian Bunk <bunk@stusta.de>

---
--- linux-2.6.21-rc2-mm1/drivers/net/s2io.c.old	2007-03-04 21:37:59.000000000 +0100
+++ linux-2.6.21-rc2-mm1/drivers/net/s2io.c	2007-03-04 21:38:14.000000000 +0100
@@ -316,7 +316,7 @@
 }
 
 /* A flag indicating whether 'RX_PA_CFG_STRIP_VLAN_TAG' bit is set or not */
-int vlan_strip_flag;
+static int vlan_strip_flag;
 
 /* Unregister the vlan */
 static void s2io_vlan_rx_kill_vid(struct net_device *dev, unsigned long vid)
