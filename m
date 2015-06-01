From: Enrico Mioso <mrkiko.rs-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [cdc_ncm] guidance and help refactoring cdc_ncm
Date: Mon, 1 Jun 2015 10:24:41 +0200 (CEST)
Message-ID: <alpine.LNX.2.20.1506011020001.3741@localhost.localdomain>
References: <alpine.LNX.2.20.1505311628420.16456@localhost.localdomain> <20150601005917.GB5320@kroah.com> <alpine.LNX.2.20.1506010818110.3158@localhost.localdomain> <1433144906.1557.2.camel@suse.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: Greg KH <greg-U8xfFu+wG4EAvxtiuMwx3w@public.gmane.org>, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, youtux-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
To: Oliver Neukum <oneukum-IBi9RG/b67k@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1433144906.1557.2.camel-IBi9RG/b67k@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Thank you Oliver for the reply.


On Mon, 1 Jun 2015, Oliver Neukum wrote:

==Date: Mon, 1 Jun 2015 09:48:26
==From: Oliver Neukum <oneukum-IBi9RG/b67k@public.gmane.org>
==To: Enrico Mioso <mrkiko.rs-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
==Cc: Greg KH <greg-U8xfFu+wG4EAvxtiuMwx3w@public.gmane.org>, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
==    netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, youtux-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
==Subject: Re: [cdc_ncm] guidance and help refactoring cdc_ncm
==
==On Mon, 2015-06-01 at 08:53 +0200, Enrico Mioso wrote:
==
==> A 32-bit version of the driver (talking 32-bit NCM) is here:
==> http://www.gstorm.eu/cdc_ncm.c
==> I modified the original driver with the help of a very talented friend.
==> It works: but there seem to be no real reasons to implement this properly. We 
==> did this in a consistent effort to understand what was wrong, and here it is.
==
==Well, you are really talking about two different things here.
==Do we ever fail because we only do 16 bit as opposed to 32 bit?
==Your 32 bit driver looks good, but it raises the question of what to do
==if this test:
==
==        if (le16_to_cpu(ctx->ncm_parm.bmNtbFormatsSupported) &
==                                                USB_CDC_NCM_NTB32_SUPPORTED) {
==
==fails. Otherwise it looks ready for merging.
==
==	Regards
==		Oliver
==
==
==
==

Oh - I am sorry. Infact, I am taling about two different things here. No, I've 
seen no device failing because of this (16 vs. 32 bit problem).
I was mentioning this only as an additional thing to consider, at least from my 
side.
We are failing on some cases only because of the position we put the NDP part 
of the NCM frame. Infact, this 32-bit driver will work when the 16 bit one 
does, and fail when the 16 bit one does.
Thank you for your review and consideration.
It would be nice to see this code merged - but I think we might need to merge 
the two drivers in a way that reduces code de-duplication. But this might be 
work for a second take in case.
Thank you again,
Enrico
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
