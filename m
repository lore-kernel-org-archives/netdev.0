From: Heinrich Schuchardt <xypron.glpk@gmx.de>
Subject: [PATCH] wifi: ath6kl: simplify logical condition
Date: Wed, 18 May 2016 02:24:17 +0200
Message-ID: <1463531057-12917-1-git-send-email-xypron.glpk@gmx.de>
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Heinrich Schuchardt <xypron.glpk@gmx.de>
To: Kalle Valo <kvalo@qca.qualcomm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.gmx.net ([212.227.15.19]:50560 "EHLO mout.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752116AbcERAYa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 May 2016 20:24:30 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

x <= 7 implies x < 8.

Signed-off-by: Heinrich Schuchardt <xypron.glpk@gmx.de>
---
 drivers/net/wireless/ath/ath6kl/wmi.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/drivers/net/wireless/ath/ath6kl/wmi.c b/drivers/net/wireless/ath/ath6kl/wmi.c
index 631c3a0..b8cf04d 100644
--- a/drivers/net/wireless/ath/ath6kl/wmi.c
+++ b/drivers/net/wireless/ath/ath6kl/wmi.c
@@ -2544,8 +2544,7 @@ int ath6kl_wmi_create_pstream_cmd(struct wmi *wmi, u8 if_idx,
 	s32 nominal_phy = 0;
 	int ret;
 
-	if (!((params->user_pri < 8) &&
-	      (params->user_pri <= 0x7) &&
+	if (!((params->user_pri <= 0x7) &&
 	      (up_to_ac[params->user_pri & 0x7] == params->traffic_class) &&
 	      (params->traffic_direc == UPLINK_TRAFFIC ||
 	       params->traffic_direc == DNLINK_TRAFFIC ||
-- 
2.1.4
