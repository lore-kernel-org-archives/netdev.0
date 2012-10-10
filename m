From: Srinivas KANDAGATLA <srinivas.kandagatla@st.com>
Subject: [PATCH 3.6.0- 3/3] wireless/ath5k: use module_platform_driver macro
Date: Wed, 10 Oct 2012 19:29:16 +0100
Message-ID: <1349893756-6900-1-git-send-email-srinivas.kandagatla@st.com>
Cc: srinivas.kandagatla@st.com, bordug@ru.mvista.com,
	netdev@vger.kernel.org, david.daney@cavium.com,
	linville@tuxdriver.com, kaloz@openwrt.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog105.obsmtp.com ([207.126.144.119]:51540 "EHLO
	eu1sys200aog105.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751497Ab2JJSau (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Oct 2012 14:30:50 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Srinivas Kandagatla <srinivas.kandagatla@st.com>

This patch removes some code duplication by using
module_platform_driver.

Signed-off-by: Srinivas Kandagatla <srinivas.kandagatla@st.com>
---
 drivers/net/wireless/ath/ath5k/ahb.c |   16 +---------------
 1 files changed, 1 insertions(+), 15 deletions(-)

diff --git a/drivers/net/wireless/ath/ath5k/ahb.c b/drivers/net/wireless/ath/ath5k/ahb.c
index aec33cc..3f9036f 100644
--- a/drivers/net/wireless/ath/ath5k/ahb.c
+++ b/drivers/net/wireless/ath/ath5k/ahb.c
@@ -235,18 +235,4 @@ static struct platform_driver ath_ahb_driver = {
 		.owner	= THIS_MODULE,
 	},
 };
-
-static int __init
-ath5k_ahb_init(void)
-{
-	return platform_driver_register(&ath_ahb_driver);
-}
-
-static void __exit
-ath5k_ahb_exit(void)
-{
-	platform_driver_unregister(&ath_ahb_driver);
-}
-
-module_init(ath5k_ahb_init);
-module_exit(ath5k_ahb_exit);
+module_platform_driver(ath_ahb_driver);
-- 
1.7.0.4
