From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH NEXT 2/5] staging: r8188eu: Fix sparse warnings in rtw_ieee80211.c
Date: Wed, 23 Oct 2013 22:31:34 -0500
Message-ID: <1382585497-6787-3-git-send-email-Larry.Finger@lwfinger.net>
References: <1382585497-6787-1-git-send-email-Larry.Finger@lwfinger.net>
Cc: netdev@vger.kernel.org, devel@driverdev.osuosl.org,
	Larry Finger <Larry.Finger@lwfinger.net>
To: gregkh@linuxfoundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f41.google.com ([209.85.219.41]:55767 "EHLO
	mail-oa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753840Ab3JXDbz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Oct 2013 23:31:55 -0400
Received: by mail-oa0-f41.google.com with SMTP id o9so1872305oag.0
        for <netdev@vger.kernel.org>; Wed, 23 Oct 2013 20:31:54 -0700 (PDT)
In-Reply-To: <1382585497-6787-1-git-send-email-Larry.Finger@lwfinger.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sparse reports the following:

  CHECK   drivers/staging/rtl8188eu/core/rtw_ieee80211.c
drivers/staging/rtl8188eu/core/rtw_ieee80211.c:1593:14: warning: cast to restricted __le16

Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
---
 drivers/staging/rtl8188eu/include/ieee80211.h | 16 ++++++++--------
 1 file changed, 8 insertions(+), 8 deletions(-)

diff --git a/drivers/staging/rtl8188eu/include/ieee80211.h b/drivers/staging/rtl8188eu/include/ieee80211.h
index cd37ea4..c4d38d1 100644
--- a/drivers/staging/rtl8188eu/include/ieee80211.h
+++ b/drivers/staging/rtl8188eu/include/ieee80211.h
@@ -306,8 +306,8 @@ struct ieee_ibss_seq {
 };
 
 struct rtw_ieee80211_hdr {
-	u16 frame_ctl;
-	u16 duration_id;
+	__le16 frame_ctl;
+	__le16 duration_id;
 	u8 addr1[ETH_ALEN];
 	u8 addr2[ETH_ALEN];
 	u8 addr3[ETH_ALEN];
@@ -316,8 +316,8 @@ struct rtw_ieee80211_hdr {
 } __packed;
 
 struct rtw_ieee80211_hdr_3addr {
-	u16 frame_ctl;
-	u16 duration_id;
+	__le16 frame_ctl;
+	__le16 duration_id;
 	u8 addr1[ETH_ALEN];
 	u8 addr2[ETH_ALEN];
 	u8 addr3[ETH_ALEN];
@@ -325,8 +325,8 @@ struct rtw_ieee80211_hdr_3addr {
 } __packed;
 
 struct rtw_ieee80211_hdr_qos {
-	u16 frame_ctl;
-	u16 duration_id;
+	__le16 frame_ctl;
+	__le16 duration_id;
 	u8 addr1[ETH_ALEN];
 	u8 addr2[ETH_ALEN];
 	u8 addr3[ETH_ALEN];
@@ -336,8 +336,8 @@ struct rtw_ieee80211_hdr_qos {
 }  __packed;
 
 struct rtw_ieee80211_hdr_3addr_qos {
-	u16 frame_ctl;
-	u16 duration_id;
+	__le16 frame_ctl;
+	__le16 duration_id;
 	u8 addr1[ETH_ALEN];
 	u8 addr2[ETH_ALEN];
 	u8 addr3[ETH_ALEN];
-- 
1.8.4
