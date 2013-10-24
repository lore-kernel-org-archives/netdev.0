From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH NEXT 5/5] staging: r8188eu: Fix sparse warnings in rtl_p2p.c
Date: Wed, 23 Oct 2013 22:31:37 -0500
Message-ID: <1382585497-6787-6-git-send-email-Larry.Finger@lwfinger.net>
References: <1382585497-6787-1-git-send-email-Larry.Finger@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: devel@driverdev.osuosl.org, netdev@vger.kernel.org,
 Larry Finger <Larry.Finger@lwfinger.net>
To: gregkh@linuxfoundation.org
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <1382585497-6787-1-git-send-email-Larry.Finger@lwfinger.net>
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

  CHECK   drivers/staging/rtl8188eu/core/rtw_p2p.c
drivers/staging/rtl8188eu/core/rtw_p2p.c:162:15: warning: incorrect type in assignment (different base types)
drivers/staging/rtl8188eu/core/rtw_p2p.c:162:15:    expected unsigned short *fctrl
drivers/staging/rtl8188eu/core/rtw_p2p.c:162:15:    got restricted __le16 *<noident>
drivers/staging/rtl8188eu/core/rtw_p2p.c:221:15: warning: incorrect type in assignment (different base types)
drivers/staging/rtl8188eu/core/rtw_p2p.c:221:15:    expected unsigned short *fctrl
drivers/staging/rtl8188eu/core/rtw_p2p.c:221:15:    got restricted __le16 *<noident>
drivers/staging/rtl8188eu/core/rtw_p2p.c:292:15: warning: incorrect type in assignment (different base types)
drivers/staging/rtl8188eu/core/rtw_p2p.c:292:15:    expected unsigned short *fctrl
drivers/staging/rtl8188eu/core/rtw_p2p.c:292:15:    got restricted __le16 *<noident>
drivers/staging/rtl8188eu/core/rtw_p2p.c:371:15: warning: incorrect type in assignment (different base types)
drivers/staging/rtl8188eu/core/rtw_p2p.c:371:15:    expected unsigned short *fctrl
drivers/staging/rtl8188eu/core/rtw_p2p.c:371:15:    got restricted __le16 *<noident>

Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
---
 drivers/staging/rtl8188eu/core/rtw_p2p.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/staging/rtl8188eu/core/rtw_p2p.c b/drivers/staging/rtl8188eu/core/rtw_p2p.c
index 8cf915f..f46cab1 100644
--- a/drivers/staging/rtl8188eu/core/rtw_p2p.c
+++ b/drivers/staging/rtl8188eu/core/rtw_p2p.c
@@ -135,7 +135,7 @@ static void issue_group_disc_req(struct wifidirect_info *pwdinfo, u8 *da)
 	struct pkt_attrib			*pattrib;
 	unsigned char					*pframe;
 	struct rtw_ieee80211_hdr	*pwlanhdr;
-	unsigned short				*fctrl;
+	__le16 *fctrl;
 	struct adapter *padapter = pwdinfo->padapter;
 	struct xmit_priv			*pxmitpriv = &(padapter->xmitpriv);
 	struct mlme_ext_priv	*pmlmeext = &(padapter->mlmeextpriv);
@@ -192,7 +192,7 @@ static void issue_p2p_devdisc_resp(struct wifidirect_info *pwdinfo, u8 *da, u8 s
 	struct pkt_attrib			*pattrib;
 	unsigned char					*pframe;
 	struct rtw_ieee80211_hdr	*pwlanhdr;
-	unsigned short				*fctrl;
+	__le16 *fctrl;
 	struct adapter *padapter = pwdinfo->padapter;
 	struct xmit_priv			*pxmitpriv = &(padapter->xmitpriv);
 	struct mlme_ext_priv	*pmlmeext = &(padapter->mlmeextpriv);
@@ -272,7 +272,7 @@ static void issue_p2p_provision_resp(struct wifidirect_info *pwdinfo, u8 *raddr,
 	struct pkt_attrib			*pattrib;
 	unsigned char					*pframe;
 	struct rtw_ieee80211_hdr	*pwlanhdr;
-	unsigned short				*fctrl;
+	__le16 *fctrl;
 	struct xmit_priv			*pxmitpriv = &(padapter->xmitpriv);
 	struct mlme_ext_priv	*pmlmeext = &(padapter->mlmeextpriv);
 
@@ -342,7 +342,7 @@ static void issue_p2p_presence_resp(struct wifidirect_info *pwdinfo, u8 *da, u8
 	struct pkt_attrib			*pattrib;
 	unsigned char					*pframe;
 	struct rtw_ieee80211_hdr	*pwlanhdr;
-	unsigned short				*fctrl;
+	__le16 *fctrl;
 	struct adapter *padapter = pwdinfo->padapter;
 	struct xmit_priv			*pxmitpriv = &(padapter->xmitpriv);
 	struct mlme_ext_priv	*pmlmeext = &(padapter->mlmeextpriv);
-- 
1.8.4
