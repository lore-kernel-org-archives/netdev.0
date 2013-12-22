From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH 28/31] staging: r8188eu: Fix sparse warning in
 core/rtw_pwrctrl.c
Date: Sun, 22 Dec 2013 17:36:59 -0600
Message-ID: <1387755422-11443-29-git-send-email-Larry.Finger@lwfinger.net>
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

Sparse reports the following:

  CHECK   drivers/staging/rtl8188eu/core/rtw_pwrctrl.c
drivers/staging/rtl8188eu/core/rtw_pwrctrl.c:525:6: warning: symbol 'rtw_free_pwrctrl_priv' was not declared. Should it be static?

That routine is not used and has been deleted.

Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
---
 drivers/staging/rtl8188eu/core/rtw_pwrctrl.c | 4 ----
 1 file changed, 4 deletions(-)

diff --git a/drivers/staging/rtl8188eu/core/rtw_pwrctrl.c b/drivers/staging/rtl8188eu/core/rtw_pwrctrl.c
index 4eec447..b5db22c 100644
--- a/drivers/staging/rtl8188eu/core/rtw_pwrctrl.c
+++ b/drivers/staging/rtl8188eu/core/rtw_pwrctrl.c
@@ -522,10 +522,6 @@ _func_enter_;
 _func_exit_;
 }
 
-void rtw_free_pwrctrl_priv(struct adapter *adapter)
-{
-}
-
 u8 rtw_interface_ps_func(struct adapter *padapter, enum hal_intf_ps_func efunc_id, u8 *val)
 {
 	u8 bResult = true;
-- 
1.8.4
