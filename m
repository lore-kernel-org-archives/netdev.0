From: Andy Green <andy.green@linaro.org>
Subject: [PATCH 4/7] net: wireless: wcn36xx: introduce
 WCN36XX_HAL_AVOID_FREQ_RANGE_IND
Date: Sun, 18 Jan 2015 13:11:00 +0800
Message-ID: <20150118051100.31866.37997.stgit@114-36-241-182.dynamic.hinet.net>
References: <20150118050741.31866.36490.stgit@114-36-241-182.dynamic.hinet.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: wcn36xx@lists.infradead.org, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org
To: Kalle Valo <kvalo@codeaurora.org>,
	Eugene Krasnikov <k.eugene.e@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:51191 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751577AbbARFLH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 18 Jan 2015 00:11:07 -0500
In-Reply-To: <20150118050741.31866.36490.stgit@114-36-241-182.dynamic.hinet.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

WCN3620 firmware introduces a new async indication, we need to
add it as a known message type so we can accept it

Signed-off-by: Andy Green <andy.green@linaro.org>
---
 drivers/net/wireless/ath/wcn36xx/hal.h |    2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/wireless/ath/wcn36xx/hal.h b/drivers/net/wireless/ath/wcn36xx/hal.h
index a1f1127..b947de0 100644
--- a/drivers/net/wireless/ath/wcn36xx/hal.h
+++ b/drivers/net/wireless/ath/wcn36xx/hal.h
@@ -345,6 +345,8 @@ enum wcn36xx_hal_host_msg_type {
 	WCN36XX_HAL_DHCP_START_IND = 189,
 	WCN36XX_HAL_DHCP_STOP_IND = 190,
 
+	WCN36XX_HAL_AVOID_FREQ_RANGE_IND = 233,
+
 	WCN36XX_HAL_MSG_MAX = WCN36XX_HAL_MSG_TYPE_MAX_ENUM_SIZE
 };
 
