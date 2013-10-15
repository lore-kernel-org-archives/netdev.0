From: Enrico Mioso <mrkiko.rs@gmail.com>
Subject: [PATCH] net: qmi_wwan: Olivetti Olicard 200 support
Date: Tue, 15 Oct 2013 15:06:48 +0200
Message-ID: <1381842408-10800-2-git-send-email-mrkiko.rs@gmail.com>
References: <1381842408-10800-1-git-send-email-mrkiko.rs@gmail.com>
Cc: Enrico Mioso <mrkiko.rs@gmail.com>,
	Antonella Pellizzari <anto.pellizzari83@gmail.com>
To: gregkh@linuxfoundation.org, davem@davemloft.net, bjorn@mork.no,
	dcbw@redhat.com, christian.schmiedl@gemalto.com,
	linux-usb@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1381842408-10800-1-git-send-email-mrkiko.rs@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a QMI device, manufactured by TCT Mobile Phones.
A companion patch blacklisting this device's QMI interface in the option.c
driver has been sent.

Signed-off-by: Enrico Mioso <mrkiko.rs@gmail.com>
Signed-off-by: Antonella Pellizzari <anto.pellizzari83@gmail.com>

diff --git a/drivers/net/usb/qmi_wwan.c b/drivers/net/usb/qmi_wwan.c
index 3d6aaf7..818ce90 100644
--- a/drivers/net/usb/qmi_wwan.c
+++ b/drivers/net/usb/qmi_wwan.c
@@ -714,6 +714,7 @@ static const struct usb_device_id products[] = {
 	{QMI_FIXED_INTF(0x2357, 0x0201, 4)},	/* TP-LINK HSUPA Modem MA180 */
 	{QMI_FIXED_INTF(0x2357, 0x9000, 4)},	/* TP-LINK MA260 */
 	{QMI_FIXED_INTF(0x1bc7, 0x1200, 5)},	/* Telit LE920 */
+	{QMI_FIXED_INTF(0x0b3c, 0xc005, 6)},    /* Olivetti Olicard 200 */
 	{QMI_FIXED_INTF(0x1e2d, 0x0060, 4)},	/* Cinterion PLxx */
 
 	/* 4. Gobi 1000 devices */
-- 
1.8.4
