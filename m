From: Richard Cochran <richardcochran-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH v3 0/3] dp83640: Get pin and master/slave configuration
 from DT
Date: Fri, 14 Feb 2014 10:06:01 +0100
Message-ID: <20140214090601.GA3906@netboy>
References: <1392302129-24947-1-git-send-email-stefan.sorensen@spectralink.com>
 <20140213.173957.2126489785330496380.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: stefan.sorensen-usnHOLptxrsHrNJx0XZkJA@public.gmane.org, grant.likely-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org,
	robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, mark.rutland-5wv7dgnIgG8@public.gmane.org,
	devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20140213.173957.2126489785330496380.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, Feb 13, 2014 at 05:39:57PM -0500, David Miller wrote:

> You'll have to code this in a way such that people who currently specify
> this parameter keep working.

So, do module parameters count as user land ABI?

[ In any case, for this module, there must be a way to retain the
  parameters and still offer DT, and letting DT have precedence. ]

People want to be able to configure the auxiliary functions on the
pins of their PTP devices. My preference for supporting this is:

1. additional ioctl on the PTP character device
2. ethtool ioctl
3. DT and/or ACPI

The first option seems best because that is how you activate the
auxiliary functions. I am working on something in this direction.

Can't we just drop the DT idea altogther?

> If you don't like it, be angry at whoever added this module parameter
> in the first place, not me.  Module parameters are 99 times out of 100
> not the right way to configure something, really.

Yeah, I am the one, be angry with me.

Sorry,
Richard
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
