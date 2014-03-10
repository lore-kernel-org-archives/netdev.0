From: Richard Cochran <richardcochran-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH v3 0/3] dp83640: Get pin and master/slave configuration
 from DT
Date: Mon, 10 Mar 2014 14:54:03 +0100
Message-ID: <20140310135402.GC19781@netboy>
References: <1392302129-24947-1-git-send-email-stefan.sorensen@spectralink.com>
 <20140213.173957.2126489785330496380.davem@davemloft.net>
 <20140214090601.GA3906@netboy>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: stefan.sorensen-usnHOLptxrsHrNJx0XZkJA@public.gmane.org, grant.likely-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org,
	robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, mark.rutland-5wv7dgnIgG8@public.gmane.org,
	devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20140214090601.GA3906@netboy>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, Feb 14, 2014 at 10:06:01AM +0100, Richard Cochran wrote:
> On Thu, Feb 13, 2014 at 05:39:57PM -0500, David Miller wrote:
> > If you don't like it, be angry at whoever added this module parameter
> > in the first place, not me.  Module parameters are 99 times out of 100
> > not the right way to configure something, really.
> 
> Yeah, I am the one, be angry with me.

Look back at this driver, there was in fact a good reason to have at
least the "calibration" pin as a module parameter. When using multiple
phyters, together they should act as one clock. The driver does this
automatically during the probe method, and so it needs to know which
pin to use well before user space is ready.

However, the other pin functions could have waited for user space
configuration, but I had just lumped them all together. Going forward,
I think the get/setpin ioctl will work fine both for this driver
(without changing the legacy module parameters) and for future ones.

Thanks,
Richard
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
