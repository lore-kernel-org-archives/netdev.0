From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH 29/31] staging: r8188eu: Fix sparse warning in core/rtw_xmit.c
Date: Sun, 22 Dec 2013 17:37:00 -0600
Message-ID: <1387755422-11443-30-git-send-email-Larry.Finger@lwfinger.net>
References: <1387755422-11443-1-git-send-email-Larry.Finger@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: devel@driverdev.osuosl.org, netdev@vger.kernel.org,
 Larry Finger <Larry.Finger@lwfinger.net>
To: gregkh@linuxfoundation.org
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <1387755422-11443-1-git-send-email-Larry.Finger@lwfinger.net>
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

Sparse reports the following warning:

  CHECK   drivers/staging/rtl8188eu/core/rtw_xmit.c
drivers/staging/rtl8188eu/core/rtw_xmit.c:809:23: warning: incorrect type in initializer (different base types)
drivers/staging/rtl8188eu/core/rtw_xmit.c:809:23:    expected unsigned short [usertype] *fctrl
drivers/staging/rtl8188eu/core/rtw_xmit.c:809:23:    got restricted __le16 *<noident>

Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
---
 drivers/staging/rtl8188eu/core/rtw_xmit.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/staging/rtl8188eu/core/rtw_xmit.c b/drivers/staging/rtl8188eu/core/rtw_xmit.c
index 026645c..24182fb 100644
--- a/drivers/staging/rtl8188eu/core/rtw_xmit.c
+++ b/drivers/staging/rtl8188eu/core/rtw_xmit.c
@@ -806,7 +806,7 @@ s32 rtw_make_wlanhdr (struct adapter *padapter , u8 *hdr, struct pkt_attrib *pat
 	u8 qos_option = false;
 
 	int res = _SUCCESS;
-	u16 *fctrl = &pwlanhdr->frame_ctl;
+	__le16 *fctrl = &pwlanhdr->frame_ctl;
 
 	struct sta_info *psta;
 
-- 
1.8.4
