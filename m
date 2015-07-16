From: Joachim Eastwood <manabian@gmail.com>
Subject: [PATCH net-next 8/8] stmmac: drop custom_* fields from plat_stmmacenet_data
Date: Fri, 17 Jul 2015 00:26:12 +0200
Message-ID: <1437085572-11371-9-git-send-email-manabian@gmail.com>
References: <1437085572-11371-1-git-send-email-manabian@gmail.com>
Cc: Joachim Eastwood <manabian@gmail.com>, netdev@vger.kernel.org
To: peppe.cavallaro@st.com, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f182.google.com ([209.85.217.182]:36324 "EHLO
	mail-lb0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756227AbbGPW0m (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jul 2015 18:26:42 -0400
Received: by lbbpo10 with SMTP id po10so51710328lbb.3
        for <netdev@vger.kernel.org>; Thu, 16 Jul 2015 15:26:41 -0700 (PDT)
In-Reply-To: <1437085572-11371-1-git-send-email-manabian@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Both of these fields are unused and has been unused since they
were added 3 and 5 years ago. Drop them since they are clearly
not very useful.

Signed-off-by: Joachim Eastwood <manabian@gmail.com>
---
 Documentation/networking/stmmac.txt | 4 ----
 include/linux/stmmac.h              | 2 --
 2 files changed, 6 deletions(-)

diff --git a/Documentation/networking/stmmac.txt b/Documentation/networking/stmmac.txt
index e655e2453c98..5fddefa69baf 100644
--- a/Documentation/networking/stmmac.txt
+++ b/Documentation/networking/stmmac.txt
@@ -139,8 +139,6 @@ struct plat_stmmacenet_data {
 	void (*free)(struct platform_device *pdev, void *priv);
 	int (*init)(struct platform_device *pdev, void *priv);
 	void (*exit)(struct platform_device *pdev, void *priv);
-	void *custom_cfg;
-	void *custom_data;
 	void *bsp_priv;
 };
 
@@ -186,8 +184,6 @@ Where:
 	     which will be stored in bsp_priv, and then passed to init and
 	     exit callbacks. init/exit callbacks should not use or modify
 	     platform data.
- o custom_cfg/custom_data: this is a custom configuration that can be passed
-			   while initializing the resources.
  o bsp_priv: another private pointer.
 
 For MDIO bus The we have:
diff --git a/include/linux/stmmac.h b/include/linux/stmmac.h
index c735f5c91eea..c86a20047cb1 100644
--- a/include/linux/stmmac.h
+++ b/include/linux/stmmac.h
@@ -123,8 +123,6 @@ struct plat_stmmacenet_data {
 	void (*free)(struct platform_device *pdev, void *priv);
 	int (*init)(struct platform_device *pdev, void *priv);
 	void (*exit)(struct platform_device *pdev, void *priv);
-	void *custom_cfg;
-	void *custom_data;
 	void *bsp_priv;
 };
 
-- 
1.8.0
