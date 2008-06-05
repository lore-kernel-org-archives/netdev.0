From: Adrian Bunk <bunk@kernel.org>
Subject: [2.6 patch] include/linux/ssb/ssb_driver_gige.h typo fix
Date: Thu, 5 Jun 2008 21:29:49 +0300
Message-ID: <20080605182945.GO1469@cs181133002.pp.htv.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	"Robert P. J. Day" <rpjday@crashcourse.ca>
To: Michael Buesch <mb@bu3sch.de>,
	"John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp4.pp.htv.fi ([213.243.153.38]:39350 "EHLO smtp4.pp.htv.fi"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753876AbYFESa1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 Jun 2008 14:30:27 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch fixes a typo in the name of a config variable.

Reported-by: Robert P. J. Day <rpjday@crashcourse.ca>
Signed-off-by: Adrian Bunk <bunk@kernel.org>

---
2aab8eeb46b30baf987c344e1b144caec365373a diff --git a/include/linux/ssb/ssb_driver_gige.h b/include/linux/ssb/ssb_driver_gige.h
index 01fbdf5..942e387 100644
--- a/include/linux/ssb/ssb_driver_gige.h
+++ b/include/linux/ssb/ssb_driver_gige.h
@@ -100,7 +100,7 @@ extern char * nvram_get(const char *name);
 /* Get the device MAC address */
 static inline void ssb_gige_get_macaddr(struct pci_dev *pdev, u8 *macaddr)
 {
-#ifdef CONFIG_BCM947XX
+#ifdef CONFIG_BCM47XX
 	char *res = nvram_get("et0macaddr");
 	if (res)
 		memcpy(macaddr, res, 6);

