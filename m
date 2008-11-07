From: Oliver Neukum <oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH v2] usbnet: enable more aggressive autosuspend
Date: Fri, 7 Nov 2008 13:24:17 +0100
Message-ID: <200811071324.18697.oliver@neukum.org>
References: <490080F1.1060107@t2data.se> <200811071244.17221.oliver@neukum.org> <49142DC5.8080803@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Per Hallsmark <per.hallsmark-8A+B91M1NdOzQB+pC5nmwQ@public.gmane.org>, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, david-b-yBeKhBN/0LDR7s880joybQ@public.gmane.org
To: Jeff Garzik <jeff-o2qLIJkoznsdnm+yROfE0A@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <49142DC5.8080803-o2qLIJkoznsdnm+yROfE0A@public.gmane.org>
Content-Disposition: inline
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Am Freitag, 7. November 2008 13:00:05 schrieb Jeff Garzik:
> Oliver Neukum wrote:
> > Am Freitag, 7. November 2008 09:26:33 schrieb Jeff Garzik:
> >> I pondered taking the easy route of fixing this by surrounding the 
> >> auto_pm reference with an ifdef, but it seems like usbnet could use a 
> >> bit more thought -- it is questionable whether usbnet_suspend/resume 
> >> should be built at all, if !CONFIG_PM, even though they are exported.
> > 
> > As this is a generic problem, shouldn't we get the compiler to do
> > this for us?
> 
> Can you be more specific?

As these methods are static the compiler is able to tell whether they
are referenced by anything but the tables. We should be able to set
an attribute in the header file that tells the compiler that these methods
won't be called and can be omitted in the build. Otherwise we have to ifdef
all those methods.

	Regards
		Oliver
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
