From: Richard Cochran <richardcochran-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH] dp83640: Get gpio and master/slave configuration from DT
Date: Mon, 10 Feb 2014 19:46:05 +0100
Message-ID: <20140210184604.GA4296@netboy>
References: <1392037240-30913-1-git-send-email-stefan.sorensen@spectralink.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: grant.likely-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org, robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Stefan =?iso-8859-1?Q?S=F8rensen?=
	<stefan.sorensen-usnHOLptxrsHrNJx0XZkJA@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1392037240-30913-1-git-send-email-stefan.sorensen-usnHOLptxrsHrNJx0XZkJA@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, Feb 10, 2014 at 02:00:40PM +0100, Stefan S=F8rensen wrote:
> This patch removes the module parameters gpio_tab and chosen_phy in f=
avour of
> retrieving the configuration from DT through the properties

Can we please keep the module parameters? I have two platforms with
phyters neither of which will ever support DT, namely ixp and m68k,
and I want to run recent kernels on them.

Are module parameters even considered user ABI?

Even if not, still I want to retain the module params until there is
an alternative for non-DT platforms.

> 	dp83640,slave
> 	dp83640,calibrate-gpio
> 	dp83640,perout-gpios
> 	dp83640,extts-gpios
> The configuration is now stored for each master clock device, allowin=
g different=20
> gpio setups for each master.

What do you mean by "each master"? Do you mean each individual PHY devi=
ce
or each group of PHYs on the same MDIO bus?

Thanks,
Richard
--
To unsubscribe from this list: send the line "unsubscribe devicetree" i=
n
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
