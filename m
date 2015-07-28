From: Joachim Eastwood <manabian@gmail.com>
Subject: [PATCH net-next 15/17] stmmac: remove unused stmmac_of_data struct
Date: Wed, 29 Jul 2015 00:09:02 +0200
Message-ID: <1438121344-5304-16-git-send-email-manabian@gmail.com>
References: <1438121344-5304-1-git-send-email-manabian@gmail.com>
Cc: Joachim Eastwood <manabian@gmail.com>, netdev@vger.kernel.org
To: peppe.cavallaro@st.com, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f48.google.com ([209.85.215.48]:34531 "EHLO
	mail-la0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752120AbbG1WJi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Jul 2015 18:09:38 -0400
Received: by lafd3 with SMTP id d3so66729778laf.1
        for <netdev@vger.kernel.org>; Tue, 28 Jul 2015 15:09:36 -0700 (PDT)
In-Reply-To: <1438121344-5304-1-git-send-email-manabian@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As dwmac-* drivers that need OF match have been converted
to use their own internal OF match data structure this can
now be removed.

Signed-off-by: Joachim Eastwood <manabian@gmail.com>
---
 Documentation/networking/stmmac.txt |  2 --
 include/linux/stmmac.h              | 18 ------------------
 2 files changed, 20 deletions(-)

diff --git a/Documentation/networking/stmmac.txt b/Documentation/networking/stmmac.txt
index 5fddefa69baf..de5c42342ec3 100644
--- a/Documentation/networking/stmmac.txt
+++ b/Documentation/networking/stmmac.txt
@@ -274,8 +274,6 @@ capability register can replace what has been passed from the platform.
 Please see the following document:
 	Documentation/devicetree/bindings/net/stmmac.txt
 
-and the stmmac_of_data structure inside the include/linux/stmmac.h header file.
-
 4.11) This is a summary of the content of some relevant files:
  o stmmac_main.c: to implement the main network device driver;
  o stmmac_mdio.c: to provide mdio functions;
diff --git a/include/linux/stmmac.h b/include/linux/stmmac.h
index c86a20047cb1..b43cd56b78e9 100644
--- a/include/linux/stmmac.h
+++ b/include/linux/stmmac.h
@@ -125,22 +125,4 @@ struct plat_stmmacenet_data {
 	void (*exit)(struct platform_device *pdev, void *priv);
 	void *bsp_priv;
 };
-
-/* of_data for SoC glue layer device tree bindings */
-
-struct stmmac_of_data {
-	int has_gmac;
-	int enh_desc;
-	int tx_coe;
-	int rx_coe;
-	int bugged_jumbo;
-	int pmt;
-	int riwt_off;
-	void (*fix_mac_speed)(void *priv, unsigned int speed);
-	void (*bus_setup)(void __iomem *ioaddr);
-	void *(*setup)(struct platform_device *pdev);
-	void (*free)(struct platform_device *pdev, void *priv);
-	int (*init)(struct platform_device *pdev, void *priv);
-	void (*exit)(struct platform_device *pdev, void *priv);
-};
 #endif
-- 
1.8.0
