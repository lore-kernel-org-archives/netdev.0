From: SF Markus Elfring <elfring@users.sourceforge.net>
Subject: [PATCH] net-huawei_cdc_ncm: Delete an unnecessary variable
 initialisation in huawei_cdc_ncm_bind()
Date: Fri, 1 Jan 2016 16:57:49 +0100
Message-ID: <5686A1FD.1060207@users.sourceforge.net>
References: <566ABCD9.1060404@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel@vger.kernel.org>,
	kernel-janitors@vger.kernel.org,
	Julia Lawall <julia.lawall@lip6.fr>
To: linux-usb@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <566ABCD9.1060404@users.sourceforge.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Markus Elfring <elfring@users.sourceforge.net>
Date: Fri, 1 Jan 2016 16:54:13 +0100

Omit explicit initialisation at the beginning for one local variable
that is redefined before its first use.

Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>
---
 drivers/net/usb/huawei_cdc_ncm.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/usb/huawei_cdc_ncm.c b/drivers/net/usb/huawei_cdc_ncm.c
index 2680a65..53caeb3 100644
--- a/drivers/net/usb/huawei_cdc_ncm.c
+++ b/drivers/net/usb/huawei_cdc_ncm.c
@@ -71,7 +71,7 @@ static int huawei_cdc_ncm_bind(struct usbnet *usbnet_dev,
 {
 	struct cdc_ncm_ctx *ctx;
 	struct usb_driver *subdriver = ERR_PTR(-ENODEV);
-	int ret = -ENODEV;
+	int ret;
 	struct huawei_cdc_ncm_state *drvstate = (void *)&usbnet_dev->data;
 	int drvflags = 0;
 
-- 
2.6.3
