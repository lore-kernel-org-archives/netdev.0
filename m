From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH 5/9 RESENT] staging: r8188eu: Fix sparse warnings in
 rtl8188e.cmd.c
Date: Fri, 18 Oct 2013 16:35:42 -0500
Message-ID: <5261A9AE.8060103@lwfinger.net>
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

Sparse displays the following:

   CHECK   drivers/staging/rtl8188eu/hal/rtl8188e_cmd.c
drivers/staging/rtl8188eu/hal/rtl8188e_cmd.c:285:15: warning: incorrect type in 
assignment (different base types)
drivers/staging/rtl8188eu/hal/rtl8188e_cmd.c:285:15:    expected unsigned short 
[usertype] *fctrl
drivers/staging/rtl8188eu/hal/rtl8188e_cmd.c:285:15:    got restricted __le16 
*<noident>
drivers/staging/rtl8188eu/hal/rtl8188e_cmd.c:368:15: warning: incorrect type in 
assignment (different base types)
drivers/staging/rtl8188eu/hal/rtl8188e_cmd.c:368:15:    expected unsigned short 
[usertype] *fctrl
drivers/staging/rtl8188eu/hal/rtl8188e_cmd.c:368:15:    got restricted __le16 
*<noident>
drivers/staging/rtl8188eu/hal/rtl8188e_cmd.c:403:15: warning: incorrect type in 
assignment (different base types)
drivers/staging/rtl8188eu/hal/rtl8188e_cmd.c:403:15:    expected unsigned short 
[usertype] *fctrl
drivers/staging/rtl8188eu/hal/rtl8188e_cmd.c:403:15:    got restricted __le16 
*<noident>
drivers/staging/rtl8188eu/hal/rtl8188e_cmd.c:465:15: warning: incorrect type in 
assignment (different base types)
drivers/staging/rtl8188eu/hal/rtl8188e_cmd.c:465:15:    expected unsigned short 
[usertype] *fctrl
drivers/staging/rtl8188eu/hal/rtl8188e_cmd.c:465:15:    got restricted __le16 
*<noident>

Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
---
  drivers/staging/rtl8188eu/hal/rtl8188e_cmd.c | 8 ++++----
  1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/staging/rtl8188eu/hal/rtl8188e_cmd.c 
b/drivers/staging/rtl8188eu/hal/rtl8188e_cmd.c
index 0b0c68c..8be2ad7 100644
--- a/drivers/staging/rtl8188eu/hal/rtl8188e_cmd.c
+++ b/drivers/staging/rtl8188eu/hal/rtl8188e_cmd.c
@@ -273,7 +273,7 @@ void rtl8188e_set_FwMediaStatus_cmd(struct adapter *adapt, 
__le16 mstatus_rpt)
  static void ConstructBeacon(struct adapter *adapt, u8 *pframe, u32 *pLength)
  {
  	struct rtw_ieee80211_hdr	*pwlanhdr;
-	u16 *fctrl;
+	__le16 *fctrl;
  	u32 rate_len, pktlen;
  	struct mlme_ext_priv *pmlmeext = &(adapt->mlmeextpriv);
  	struct mlme_ext_info	*pmlmeinfo = &(pmlmeext->mlmext_info);
@@ -360,7 +360,7 @@ static void ConstructPSPoll(struct adapter *adapt, u8 
*pframe, u32 *pLength)
  	struct rtw_ieee80211_hdr	*pwlanhdr;
  	struct mlme_ext_priv *pmlmeext = &(adapt->mlmeextpriv);
  	struct mlme_ext_info	*pmlmeinfo = &(pmlmeext->mlmext_info);
-	u16 *fctrl;
+	__le16 *fctrl;
   	pwlanhdr = (struct rtw_ieee80211_hdr *)pframe;
  @@ -391,7 +391,7 @@ static void ConstructNullFunctionData(struct adapter 
*adapt, u8 *pframe,
  	u8 bForcePowerSave)
  {
  	struct rtw_ieee80211_hdr	*pwlanhdr;
-	u16 *fctrl;
+	__le16 *fctrl;
  	u32 pktlen;
  	struct mlme_priv *pmlmepriv = &adapt->mlmepriv;
  	struct wlan_network		*cur_network = &pmlmepriv->cur_network;
@@ -450,7 +450,7 @@ static void ConstructNullFunctionData(struct adapter *adapt, 
u8 *pframe,
  static void ConstructProbeRsp(struct adapter *adapt, u8 *pframe, u32 *pLength, 
u8 *StaAddr, bool bHideSSID)
  {
  	struct rtw_ieee80211_hdr	*pwlanhdr;
-	u16 *fctrl;
+	__le16 *fctrl;
  	u8 *mac, *bssid;
  	u32 pktlen;
  	struct mlme_ext_priv *pmlmeext = &(adapt->mlmeextpriv);
-- 
1.8.4
