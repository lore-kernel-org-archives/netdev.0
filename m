From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH 05/22] staging: rtl8723bs: Fix indenting mistake in
 os_dep/mlme_linux.c
Date: Sat,  8 Apr 2017 11:07:28 -0500
Message-ID: <20170408160745.14328-6-Larry.Finger@lwfinger.net>
References: <20170408160745.14328-1-Larry.Finger@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: devel@driverdev.osuosl.org, jes.sorensen@gmail.com, netdev@vger.kernel.org,
 hdegoede@redhat.com, hadess@hadess.net,
 Larry Finger <Larry.Finger@lwfinger.net>
To: gregkh@linuxfoundation.org
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <20170408160745.14328-1-Larry.Finger@lwfinger.net>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel/>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: "devel" <driverdev-devel-bounces@linuxdriverproject.org>
List-Id: netdev.vger.kernel.org

Smatch reports the following warning:

  CHECK   drivers/staging/rtl8723bs/os_dep/mlme_linux.c
drivers/staging/rtl8723bs/os_dep/mlme_linux.c:149 rtw_os_indicate_disconnect() warn: inconsistent indenting

Again, a simple change in the white space fixes this problem.

Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
---
 drivers/staging/rtl8723bs/os_dep/mlme_linux.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/staging/rtl8723bs/os_dep/mlme_linux.c b/drivers/staging/rtl8723bs/os_dep/mlme_linux.c
index aa1793389797..46315d1a82f7 100644
--- a/drivers/staging/rtl8723bs/os_dep/mlme_linux.c
+++ b/drivers/staging/rtl8723bs/os_dep/mlme_linux.c
@@ -145,8 +145,8 @@ void rtw_os_indicate_disconnect(struct adapter *adapter)
 
 	rtw_indicate_wx_disassoc_event(adapter);
 
-	 /* modify for CONFIG_IEEE80211W, none 11w also can use the same command */
-	 rtw_reset_securitypriv_cmd(adapter);
+	/* modify for CONFIG_IEEE80211W, none 11w also can use the same command */
+	rtw_reset_securitypriv_cmd(adapter);
 }
 
 void rtw_report_sec_ie(struct adapter *adapter, u8 authmode, u8 *sec_ie)
-- 
2.12.0
