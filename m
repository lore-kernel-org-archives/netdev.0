From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH v3 0/3] dp83640: Get pin and master/slave configuration
 from DT
Date: Fri, 14 Feb 2014 13:36:17 -0500 (EST)
Message-ID: <20140214.133617.1389101802638585879.davem@davemloft.net>
References: <1392302129-24947-1-git-send-email-stefan.sorensen@spectralink.com>
	<20140213.173957.2126489785330496380.davem@davemloft.net>
	<20140214090601.GA3906@netboy>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: stefan.sorensen-usnHOLptxrsHrNJx0XZkJA@public.gmane.org, grant.likely-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org,
	robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, mark.rutland-5wv7dgnIgG8@public.gmane.org,
	devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: richardcochran-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20140214090601.GA3906@netboy>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Richard Cochran <richardcochran-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date: Fri, 14 Feb 2014 10:06:01 +0100

> People want to be able to configure the auxiliary functions on the
> pins of their PTP devices. My preference for supporting this is:
> 
> 1. additional ioctl on the PTP character device
> 2. ethtool ioctl
> 3. DT and/or ACPI
> 
> The first option seems best because that is how you activate the
> auxiliary functions. I am working on something in this direction.

Probably since PTP already uses ioctls, and that is the activation
point, yes that seems the best approach.
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
