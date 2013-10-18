From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH 2/9 RESENT] staging: r8188eu: Fix Sparse warnings in
 rtw_wlan_util
Date: Fri, 18 Oct 2013 16:33:28 -0500
Message-ID: <5261A928.3020007@lwfinger.net>
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

Sparse shows the following warning:

   CHECK   drivers/staging/rtl8188eu/core/rtw_wlan_util.c
drivers/staging/rtl8188eu/core/rtw_wlan_util.c:1635:25: warning: cast to 
restricted __le16

Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
---
  drivers/staging/rtl8188eu/core/rtw_wlan_util.c | 2 +-
  1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/staging/rtl8188eu/core/rtw_wlan_util.c 
b/drivers/staging/rtl8188eu/core/rtw_wlan_util.c
index 153ec61..30ba18c 100644
--- a/drivers/staging/rtl8188eu/core/rtw_wlan_util.c
+++ b/drivers/staging/rtl8188eu/core/rtw_wlan_util.c
@@ -1632,7 +1632,7 @@ void process_addba_req(struct adapter *padapter, u8 
*paddba_req, u8 *addr)
  	psta = rtw_get_stainfo(pstapriv, addr);
   	if (psta) {
-		param = le16_to_cpu(preq->BA_para_set);
+		param = preq->BA_para_set;
  		tid = (param>>2)&0x0f;
  		preorder_ctrl = &psta->recvreorder_ctrl[tid];
  		preorder_ctrl->indicate_seq = 0xffff;
-- 
1.8.4
