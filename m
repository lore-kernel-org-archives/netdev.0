From: Andreas Ziegler <andreas.ziegler@fau.de>
Subject: [PATCH] staging: r8822be: Fix typo for CONFIG_RTLWIFI_DEBUG
Date: Tue, 29 Aug 2017 13:30:08 +0200
Message-ID: <1504006208-18965-1-git-send-email-andreas.ziegler@fau.de>
References: <20170829112643.GA14571@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: devel@driverdev.osuosl.org, Yan-Hsuan Chuang <yhchuang@realtek.com>,
 Birming Chiu <birming@realtek.com>, netdev <netdev@vger.kernel.org>,
 Andreas Ziegler <andreas.ziegler@fau.de>, Steven Ting <steventing@realtek.com>,
 Larry Finger <Larry.Finger@lwfinger.net>
To: Greg KH <gregkh@linuxfoundation.org>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <20170829112643.GA14571@kroah.com>
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

The debugging output in deinit_priv is guarded by an  #ifdef using
CONFIG_RTL_DEBUG. This symbol does not exist and should be
CONFIG_RTLWIFI_DEBUG instead.

Signed-off-by: Andreas Ziegler <andreas.ziegler@fau.de>
---
 drivers/staging/rtlwifi/halmac/rtl_halmac.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/staging/rtlwifi/halmac/rtl_halmac.c b/drivers/staging/rtlwifi/halmac/rtl_halmac.c
index 031bf2c..888ca43 100644
--- a/drivers/staging/rtlwifi/halmac/rtl_halmac.c
+++ b/drivers/staging/rtlwifi/halmac/rtl_halmac.c
@@ -386,7 +386,7 @@ static void deinit_priv(struct rtl_halmac *halmac)
 		u32 count, size;
 
 		count = HALMAC_FEATURE_ALL + 1;
-#ifdef CONFIG_RTL_DEBUG
+#ifdef CONFIG_RTLWIFI_DEBUG
 		{
 			struct submit_ctx *sctx;
 			u32 i;
@@ -405,7 +405,7 @@ static void deinit_priv(struct rtl_halmac *halmac)
 				rtl_mfree((u8 *)sctx, sizeof(*sctx));
 			}
 		}
-#endif /* !CONFIG_RTL_DEBUG */
+#endif /* !CONFIG_RTLWIFI_DEBUG */
 		size = sizeof(*indicator) * count;
 		kfree((u8 *)indicator);
 	}
-- 
2.7.4
