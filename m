From: Oliver Neukum <oneukum-IBi9RG/b67k@public.gmane.org>
Subject: Re: [PATCH net-next] cdc_ether: Improve ZTE MF823/831/910 handling
Date: Tue, 19 Jul 2016 08:20:09 +0200
Message-ID: <1468909209.2178.0.camel@suse.com>
References: <1468844691-8222-1-git-send-email-kristian.evensen@gmail.com>
	 <1468846886.2280.6.camel@suse.com>
	 <CAKfDRXiqDmJadXL4+v7saM431vPAp_8m8F0wvTkkYt-3tNjYyw@mail.gmail.com>
	 <1468849802.2280.11.camel@suse.com>
	 <CAKfDRXjaSz25_b8Na46DJEDvGUsZ-Xye+Rn2+o6Hy0EcuOopkA@mail.gmail.com>
	 <1468851242.2280.14.camel@suse.com>
	 <CAKfDRXiK82ULw7RnRGdFwzad8NOfnwZN0vqv=08Tf+cNSdyd2g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Kristian Evensen <kristian.evensen-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CAKfDRXiK82ULw7RnRGdFwzad8NOfnwZN0vqv=08Tf+cNSdyd2g-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, 2016-07-18 at 17:04 +0200, Kristian Evensen wrote:
> On Mon, Jul 18, 2016 at 4:14 PM, Oliver Neukum <oneukum-IBi9RG/b67k@public.gmane.org> wrote:
> >> Ok, sounds good. So far, I have only seen the random MAC issue with
> >> the three previously mentioned devices, but who knows how many else is
> >> out there with the same error ... I don't think it should be in the
> >> core ethernet code, at least not yet, but I agree it would make sense
> >> to move it to for example usbnet_core(). If you agree, I can prepare a
> >> patch for it.
> >
> > I don't see how it would be specific for a subsystem. If the patch
> > is correct, it belongs into the networking core.
> 
> I had a look at some other drivers, and I think we need to be very
> careful about making setting a random MAC too generic. For example, we
> might be unlucky and break the possibly_iphdr()-code/assumption in
> qmi_wwan.c. And there is probably more code/assumptions like that in
> the network stack.

In this case please use special cases for usbnet, too.
We need a quirk.

	Regards
		Oliver


--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
