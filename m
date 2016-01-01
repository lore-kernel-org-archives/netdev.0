From: SF Markus Elfring <elfring@users.sourceforge.net>
Subject: [PATCH 2/2] net-qmi_wwan: Delete an unnecessary variable
 initialisation in qmi_wwan_register_subdriver()
Date: Fri, 1 Jan 2016 17:56:14 +0100
Message-ID: <5686AFAE.7020401@users.sourceforge.net>
References: <566ABCD9.1060404@users.sourceforge.net>
 <5686AE52.1020008@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel@vger.kernel.org>,
	kernel-janitors@vger.kernel.org,
	Julia Lawall <julia.lawall@lip6.fr>
To: linux-usb@vger.kernel.org, netdev@vger.kernel.org,
	=?UTF-8?Q?Bj=c3=b8rn_Mork?= <bjorn@mork.no>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <5686AE52.1020008@users.sourceforge.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Markus Elfring <elfring@users.sourceforge.net>
Date: Fri, 1 Jan 2016 17:35:03 +0100

Omit explicit initialisation at the beginning for one local variable
that is redefined before its first use.

Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>
---
 drivers/net/usb/qmi_wwan.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/usb/qmi_wwan.c b/drivers/net/usb/qmi_wwan.c
index 5b8af06..5962099 100644
--- a/drivers/net/usb/qmi_wwan.c
+++ b/drivers/net/usb/qmi_wwan.c
@@ -286,7 +286,7 @@ static int qmi_wwan_cdc_wdm_manage_power(struct usb_interface *intf, int on)
 static int qmi_wwan_register_subdriver(struct usbnet *dev)
 {
 	int rv;
-	struct usb_driver *subdriver = NULL;
+	struct usb_driver *subdriver;
 	struct qmi_wwan_state *info = (void *)&dev->data;
 
 	/* collect bulk endpoints */
-- 
2.6.3
