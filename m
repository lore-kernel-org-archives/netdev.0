From: Oliver Neukum <oneukum-l3A5Bk7waGM@public.gmane.org>
Subject: Re: Problem with non aligned DMA in usbnet on ARM
Date: Fri, 13 Aug 2010 15:53:19 +0200
Message-ID: <201008131553.19875.oneukum@suse.de>
References: <732137.54230.qm@web180303.mail.gq1.yahoo.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: mfuzzey-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, Matthieu CASTET <matthieu.castet-ITF29qwbsa/QT0dZR+AlfA@public.gmane.org>,
	"Russell King - ARM Linux" <linux-lFZ/pmaqli7XmaaqVzeoHQ@public.gmane.org>,
	Gary King <GKing-DDmLM1+adcrQT0dZR+AlfA@public.gmane.org>,
	"linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org"
	<linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>,
	"linux-usb" <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Greg KH <greg-U8xfFu+wG4EAvxtiuMwx3w@public.gmane.org>
To: David Brownell <david-b-yBeKhBN/0LDR7s880joybQ@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <732137.54230.qm-g47maUHHHF/6X00i2u5GFvu2YVrzzGjVVpNB7YpNyf8@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Am Freitag, 13. August 2010, 15:42:32 schrieb David Brownell:
> > > 2) Require that usb_submit_urb() accept byte aligned buffers.
> 
> I believe we already require that.  Of course,
> the requirement is on HCDs, not on th

Divers fail if HCDs can't do it. But we've never explicitly said that HCDs
need to be able to do that. We should probably document that requirement.

	Regards
		Oliver
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
