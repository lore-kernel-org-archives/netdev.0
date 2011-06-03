From: Alexey ORISHKO <alexey.orishko-0IS4wlFg1OjSUeElwK9/Pw@public.gmane.org>
Subject: RE: [PATCH] TODO FLAG_POINTTOPOINT => FLAG_WWAN? usbnet/cdc_ncm:
 mark ncm devices as "mobile broadband devices" with FLAG_WWAN
Date: Fri, 3 Jun 2011 11:45:38 +0200
Message-ID: <2AC7D4AD8BA1C640B4C60C61C8E520153E3C13B5F2@EXDCVYMBSTM006.EQ1STM.local>
References: <1306922913-17803-1-git-send-email-metze@samba.org>
 <1306922913-17803-2-git-send-email-metze@samba.org>
 <2AC7D4AD8BA1C640B4C60C61C8E520153E3C07E583@EXDCVYMBSTM006.EQ1STM.local>
 <1307053743.21633.22.camel@dcbw.foobar.com>
            <1307054132.21633.25.camel@dcbw.foobar.com>
 <5203.1307062683@turing-police.cc.vt.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Stefan Metzmacher <metze-eUNUBHrolfbYtjvyW6yDsg@public.gmane.org>,
	Oliver Neukum <oliver-Q6YOFhsQ4GZ7tPAFqOLdPg@public.gmane.org>,
	Greg Kroah-Hartman <gregkh-l3A5Bk7waGM@public.gmane.org>,
	"linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: "Valdis.Kletnieks-PjAqaU27lzQ@public.gmane.org" <Valdis.Kletnieks-PjAqaU27lzQ@public.gmane.org>,
	Dan Williams <dcbw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <5203.1307062683-+bZmOdGhbsPr6rcHtW+onFJE71vCis6O@public.gmane.org>
Content-Language: en-US
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

> -----Original Message-----
> From: Valdis.Kletnieks-PjAqaU27lzQ@public.gmane.org [mailto:Valdis.Kletnieks-PjAqaU27lzQ@public.gmane.org]
> Sent: Friday, June 03, 2011 2:58 AM
> 
> > A follow-on to this is that if you really care about specific
> devices,
> > your application can use udev rules to "tag" specific interfaces
> based
> > on USB VID/PID/GUID or other device attributes, and check for those
> > tags in your program.  Use udev (good) or netlink (good) or
> > SIOCGIFCONF (bad) to enumerate the various network interfaces on the
> > system and pick the
> 
> I think Alexey's point was that the patch will hose up programs that
> currently do the netlink or  SIOCGIFCONF thing and look for
> FLAG_POINTTOPOINT.

Just to clarify, I was objecting to renaming interface name mostly because
devices which use CDC NCM function might be something different from wwan
devices. I would prefer to keep a generic name of interface (usbX or ethX).

As an option anyone can use udev rules to set interface name they want 
for their device based on VID/PID or MAC address or something else.
I've already provided udev rule example earlier in this thread.

Dan, is it in line with your statement?

/alexey

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
