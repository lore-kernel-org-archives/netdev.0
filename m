From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH 3/3] staging: r8821ae: Fix potential problem with rate control
 registration
Date: Mon, 26 May 2014 14:06:06 -0500
Message-ID: <1401131166-6313-4-git-send-email-Larry.Finger@lwfinger.net>
References: <1401131166-6313-1-git-send-email-Larry.Finger@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: devel@driverdev.osuosl.org, netdev@vger.kernel.org,
 Larry Finger <Larry.Finger@lwfinger.net>
To: gregkh@linuxfoundation.org
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <1401131166-6313-1-git-send-email-Larry.Finger@lwfinger.net>
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

The zero day testing facility reported a problem with duplicate
registration of the rate-control algorithm. Although not yet reported,
this driver needs the same fix.

Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
---
 drivers/staging/rtl8821ae/rc.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/staging/rtl8821ae/rc.c b/drivers/staging/rtl8821ae/rc.c
index 0cc32c6..a5a09ba 100644
--- a/drivers/staging/rtl8821ae/rc.c
+++ b/drivers/staging/rtl8821ae/rc.c
@@ -286,7 +286,7 @@ static void rtl_rate_free_sta(void *rtlpriv,
 }
 
 static struct rate_control_ops rtl_rate_ops = {
-	.name = "rtl_rc",
+	.name = "rtl_rc_21ae",
 	.alloc = rtl_rate_alloc,
 	.free = rtl_rate_free,
 	.alloc_sta = rtl_rate_alloc_sta,
-- 
1.8.4.5
