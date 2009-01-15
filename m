From: Oliver Neukum <oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org>
Subject: question on smsc95xx
Date: Thu, 15 Jan 2009 17:28:19 +0100
Message-ID: <200901151728.19899.oliver@neukum.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: steve.glendinning-sdUf+H5yV5I@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi,

I am looking at this code:

static void smsc95xx_async_cmd_callback(struct urb *urb, struct pt_regs *regs)
{
	struct usb_context *usb_context = urb->context;
	struct usbnet *dev = usb_context->dev;
	int status = urb->status;

	if (status < 0)
		devwarn(dev, "async callback failed with %d", status);

	complete(&usb_context->notify);

is there some ultradeep reason for using complete here?
I cannot see that serving any purpose whatsoever.

	Regards
		Oliver
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
