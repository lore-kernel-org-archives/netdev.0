From: Schemmel Hans-Christoph <Hans-Christoph.Schemmel-av01+Y74gORBDgjK7y7TUQ@public.gmane.org>
Subject: [PATCH] qmi_wwan: Added support for Gemalto's Cinterion PHxx WWAN
 interface
Date: Tue, 15 Mar 2016 09:02:09 +0000
Message-ID: <1978E4F2CF12DD4A899FA7487323EB110108364EE7@A1GTOEMBXV004.gto.a3c.atos.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: "bjorn-yOkvZcmFvRU@public.gmane.org" <bjorn-yOkvZcmFvRU@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Language: en-US
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Added support for Cinterion's PHxx WWAN interfaces by adding
QMI_FIXED_INTF with Cinterion's VID and PID.

PHxx can have 2 RmNet Interfaces (PID 0x0082)
or 1 RmNet + 1 USB Audio interface (PID 0x0083).

Signed-off-by: Hans-Christoph Schemmel <hans-christoph.schemmel-av01+Y74gORBDgjK7y7TUQ@public.gmane.org>
---
patch is against linux-4.5
--- linux/drivers/net/usb/qmi_wwan.c.orig       2016-03-14 12:18:07.153497489 +0100
+++ linux/drivers/net/usb/qmi_wwan.c    2016-03-14 12:21:37.722541644 +0100
@@ -881,6 +881,9 @@ static const struct usb_device_id produc
        {QMI_FIXED_INTF(0x0b3c, 0xc00b, 4)},    /* Olivetti Olicard 500 */
        {QMI_FIXED_INTF(0x1e2d, 0x0060, 4)},    /* Cinterion PLxx */
        {QMI_FIXED_INTF(0x1e2d, 0x0053, 4)},    /* Cinterion PHxx,PXxx */
+       {QMI_FIXED_INTF(0x1e2d, 0x0082, 4)},    /* Cinterion PHxx,PXxx (2 RmNet) */
+       {QMI_FIXED_INTF(0x1e2d, 0x0082, 5)},    /* Cinterion PHxx,PXxx (2 RmNet) */
+       {QMI_FIXED_INTF(0x1e2d, 0x0083, 4)},    /* Cinterion PHxx,PXxx (1 RmNet + USB Audio)*/
        {QMI_FIXED_INTF(0x413c, 0x81a2, 8)},    /* Dell Wireless 5806 Gobi(TM) 4G LTE Mobile Broadband Card */
        {QMI_FIXED_INTF(0x413c, 0x81a3, 8)},    /* Dell Wireless 5570 HSPA+ (42Mbps) Mobile Broadband Card */
        {QMI_FIXED_INTF(0x413c, 0x81a4, 8)},    /* Dell Wireless 5570e HSPA+ (42Mbps) Mobile Broadband Card */
________________________________
 This message and any attachments are intended solely for the addressees and may contain confidential information. Any unauthorized use or disclosure, either whole or partial, is prohibited.
E-mails are susceptible to alteration. Our company shall not be liable for the message if altered, changed or falsified. If you are not the intended recipient of this message, please delete it and notify the sender.
Although all reasonable efforts have been made to keep this transmission free from viruses, the sender will not be liable for damages caused by a transmitted virus.
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
