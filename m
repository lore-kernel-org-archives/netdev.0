From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH 1/2 NEXT] rtlwifi: Fix Kconfig for RTL8192EE
Date: Thu,  2 Oct 2014 12:00:53 -0500
Message-ID: <1412269254-19983-2-git-send-email-Larry.Finger@lwfinger.net>
References: <1412269254-19983-1-git-send-email-Larry.Finger@lwfinger.net>
Cc: linux-wireless@vger.kernel.org, troy_tan@realsil.com.cn,
	Larry Finger <Larry.Finger@lwfinger.net>,
	netdev@vger.kernel.org
To: linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f41.google.com ([209.85.218.41]:33720 "EHLO
	mail-oi0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751834AbaJBRBM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Oct 2014 13:01:12 -0400
In-Reply-To: <1412269254-19983-1-git-send-email-Larry.Finger@lwfinger.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The driver needs btcoexist, but Kconfig fails to select it. This omission
could cause build errors for some configurations.

Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
---
 drivers/net/wireless/rtlwifi/Kconfig | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/wireless/rtlwifi/Kconfig b/drivers/net/wireless/rtlwifi/Kconfig
index 552742e..5cf509d 100644
--- a/drivers/net/wireless/rtlwifi/Kconfig
+++ b/drivers/net/wireless/rtlwifi/Kconfig
@@ -86,6 +86,7 @@ config RTL8192EE
 	depends on PCI
 	select RTLWIFI
 	select RTLWIFI_PCI
+	select RTLBTCOEXIST
 	---help---
 	This is the driver for Realtek RTL8192EE 802.11n PCIe
 	wireless network adapters.
@@ -147,7 +148,7 @@ config RTL8723_COMMON
 
 config RTLBTCOEXIST
 	tristate
-	depends on RTL8723AE || RTL8723BE || RTL8821AE
+	depends on RTL8723AE || RTL8723BE || RTL8821AE || RTL8192EE
 	default y
 
 endif
-- 
1.8.4.5
