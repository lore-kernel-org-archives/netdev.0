From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH V2] staging: r8188eu: Fix AP mode
Date: Sun, 17 Nov 2013 13:32:15 -0600
Message-ID: <1384716735-12897-1-git-send-email-Larry.Finger@lwfinger.net>
Cc: netdev@vger.kernel.org, devel@driverdev.osuosl.org,
	Larry Finger <Larry.Finger@lwfinger.net>,
	Stable <stable@vger.kernel.org>
To: gregkh@linuxfoundation.org
Return-path: <stable-owner@vger.kernel.org>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Two code lines were accidentally deleted.  Restore them.

Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
Cc: Stable <stable@vger.kernel.org>
---

V2 - rewrite silly commit message.

 drivers/staging/rtl8188eu/core/rtw_ap.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/drivers/staging/rtl8188eu/core/rtw_ap.c b/drivers/staging/rtl8188eu/core/rtw_ap.c
index 2c73823..2a13a41 100644
--- a/drivers/staging/rtl8188eu/core/rtw_ap.c
+++ b/drivers/staging/rtl8188eu/core/rtw_ap.c
@@ -1115,6 +1115,9 @@ int rtw_check_beacon_data(struct adapter *padapter, u8 *pbuf,  int len)
 			return _FAIL;
 	}
 
+	/* fix bug of flush_cam_entry at STOP AP mode */
+	psta->state |= WIFI_AP_STATE;
+	rtw_indicate_connect(padapter);
 	pmlmepriv->cur_network.join_res = true;/* for check if already set beacon */
 	return ret;
 }
-- 
1.8.4
