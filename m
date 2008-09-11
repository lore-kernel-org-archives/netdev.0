From: Oliver Neukum <oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org>
Subject: Re: a new problem with the hso driver
Date: Fri, 12 Sep 2008 01:18:26 +0200
Message-ID: <200809120118.26815.oliver@neukum.org>
References: <Pine.LNX.4.44L0.0809111835350.3949-100000@iolanthe.rowland.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Denis Joseph Barrow <D.Barow-x9gZzRpC1QbQT0dZR+AlfA@public.gmane.org>,
	Linux USB kernel mailing list <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linux netdev Mailing list <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"Greg Kroah-Hartman" <gregkh-l3A5Bk7waGM@public.gmane.org>,
	Andrew Bird <ajb-5+cxppFmGx6/3pe1ocb+s/XRex20P6io@public.gmane.org>
To: Alan Stern <stern-nwvwT67g6+6dFdvTe/nMLpVzexx5G7lz@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <Pine.LNX.4.44L0.0809111835350.3949-100000-IYeN2dnnYyZXsRXLowluHWD2FQJk+8+b@public.gmane.org>
Content-Disposition: inline
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


> > On a slightly related issue
> > we get an error -22 ie -EINVAL from usb_submit_urb
> > this though I haven't investigated properly appears to happen when the device is suspended

suspend? Are you sure it doesn't come from resume?

BTW:
	if (serial->shared_int) {
		mutex_lock(&serial->shared_int->shared_int_lock);
		if (serial->shared_int->use_count &&
		    (--serial->shared_int->use_count == 0)) {

This code deserves a honourable mentioning in the obfuscated C contest.

	Regards
		Oliver
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
