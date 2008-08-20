From: greg-U8xfFu+wG4EAvxtiuMwx3w@public.gmane.org
Subject: [patch 01/02] hso: icon 322 detection fix
Date: Tue, 19 Aug 2008 18:07:52 -0700
Message-ID: <20080820010752.GB3365@kroah.com>
References: <20080820010353.593820280@mini.kroah.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Denis Joseph Barrow <D.Barow-x9gZzRpC1QbQT0dZR+AlfA@public.gmane.org>
To: Jeff Garzik <jgarzik-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>,
	Linux USB kernel mailing list <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline; filename="hso-icon-322-detection-fix.patch"
In-Reply-To: <20080820010738.GA3365-U8xfFu+wG4EAvxtiuMwx3w@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Denis Joseph Barrow <D.Barow-x9gZzRpC1QbQT0dZR+AlfA@public.gmane.org>

Fixes Icon-322 detection.

Signed-off-by: Denis Joseph Barrow <D.Barow-x9gZzRpC1QbQT0dZR+AlfA@public.gmane.org>
Cc: Jeff Garzik <jgarzik-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
Signed-off-by: Greg Kroah-Hartman <gregkh-l3A5Bk7waGM@public.gmane.org>

---
 drivers/net/usb/hso.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

--- a/drivers/net/usb/hso.c
+++ b/drivers/net/usb/hso.c
@@ -397,7 +397,7 @@ static const struct usb_device_id hso_id
 	{default_port_device(0x0af0, 0xc031)},	/* Icon-Edge */
 	{icon321_port_device(0x0af0, 0xd013)},	/* Module HSxPA */
 	{icon321_port_device(0x0af0, 0xd031)},	/* Icon-321 */
-	{default_port_device(0x0af0, 0xd033)},	/* Icon-322 */
+	{icon321_port_device(0x0af0, 0xd033)},	/* Icon-322 */
 	{USB_DEVICE(0x0af0, 0x7301)},		/* GE40x */
 	{USB_DEVICE(0x0af0, 0x7361)},		/* GE40x */
 	{USB_DEVICE(0x0af0, 0x7401)},		/* GI 0401 */

-- 
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
