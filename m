From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH 4/9 RESENT] staging: r8188eu: Fix sparse warnings in
 rtw_ieee80211.c
Date: Fri, 18 Oct 2013 16:35:05 -0500
Message-ID: <5261A989.8050906@lwfinger.net>
References: <1382129563-8496-1-git-send-email-Larry.Finger@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
Cc: devel@driverdev.osuosl.org, netdev <netdev@vger.kernel.org>,
 Larry Finger <Larry.Finger@lwfinger.net>
To: gregkh@linuxfoundation.org
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <1382129563-8496-1-git-send-email-Larry.Finger@lwfinger.net>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: driverdev-devel-bounces@linuxdriverproject.org
List-Id: netdev.vger.kernel.org

Sparse reports the following:

   CHECK   drivers/staging/rtl8188eu/core/rtw_ieee80211.c
drivers/staging/rtl8188eu/core/rtw_ieee80211.c:1593:14: warning: cast to 
restricted __le16

Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
---
  drivers/staging/rtl8188eu/include/ieee80211.h | 16 ++++++++--------
  1 file changed, 8 insertions(+), 8 deletions(-)

diff --git a/drivers/staging/rtl8188eu/include/ieee80211.h 
b/drivers/staging/rtl8188eu/include/ieee80211.h
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
