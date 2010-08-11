From: Oliver Neukum <oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org>
Subject: Re: Problem with non aligned DMA in usbnet on ARM
Date: Wed, 11 Aug 2010 21:10:05 +0200
Message-ID: <201008112110.05542.oliver@neukum.org>
References: <AANLkTi=ycg=adcizNWKMCb7EdfDANM=6Es7r_gF1LbhV@mail.gmail.com> <AANLkTimmJDKbh3_pRY_ASKvjsf4YuuUMh3edh5LvDv-p@mail.gmail.com> <20100811174238.GA12382@kroah.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Martin Fuzzey <mfuzzey-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	"Russell King - ARM Linux" <linux-lFZ/pmaqli7XmaaqVzeoHQ@public.gmane.org>,
	"linux-usb" <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org
To: Greg KH <greg-U8xfFu+wG4EAvxtiuMwx3w@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20100811174238.GA12382-U8xfFu+wG4EAvxtiuMwx3w@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Am Mittwoch 11 August 2010 19:42:38 schrieb Greg KH:
> > So the question is are hcds expected to accept arbitarilly aligned but
> > heap allocated pointers (such as the result of kmalloc() + 1)?
> 
> It sounds like your HCD doesn't like this, so perhaps we should make
> that rule :)
> 
> If you allocate the urb with a kmalloc() call with no offset, does it
> all work properly?  The driver should be calling usb_alloc_urb() which
> does this automatically for them, right?  Or is it trying to allocate
> things on its own somehow?

The buffer is the problem not the URB. And up to now the alignment
was not specified, but drivers are generally written assuming byte
granularity.

	Regards
		Oliver
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
