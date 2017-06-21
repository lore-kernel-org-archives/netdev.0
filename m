From: Russell King - ARM Linux <linux-I+IVW8TIWO2tmTQ+vhA3Yw@public.gmane.org>
Subject: Re: [PATCH 00/51] rtc: stop using rtc deprecated functions
Date: Wed, 21 Jun 2017 10:19:49 +0100
Message-ID: <20170621091948.GP4902@n2100.armlinux.org.uk>
References: <20170620213507.urobmtg34vzubrdq@piout.net>
 <alpine.DEB.2.20.1706202343120.2157@nanos>
 <20170621075152.GA15996@amd>
 <20170621083907.y3gadsmsoufa5niv@piout.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Pavel Machek <pavel-+ZI9xUNit7I@public.gmane.org>, Thomas Gleixner <tglx-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org>,
        Benjamin Gaignard <benjamin.gaignard-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>,
        Baruch Siach <baruch-NswTu9S1W3P6gbPvEgmw2w@public.gmane.org>,
        "patches-yzvPICuk2AATkU/dhu1WVueM+bqZidxxQQ4Iyu8u01E@public.gmane.org"
        <patches-yzvPICuk2AATkU/dhu1WVueM+bqZidxxQQ4Iyu8u01E@public.gmane.org>,
        Linus Walleij <linus.walleij-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>,
        "linux-tegra-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-tegra-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Thierry Reding <thierry.reding-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        "x86-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org" <x86-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        Jonathan Hunter <jonathanh-DDmLM1+adcrQT0dZR+AlfA@public.gmane.org>,
        Chen-Yu Tsai <wens-jdAy2FN1RRM@public.gmane.org>, Ingo Molnar <mingo-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
        Sylvain Lemieux <slemieux.tyco-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        Sebastian Hesselbarth <sebastian.hesselbarth-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        Len Brown <len.brown-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
        "linaro-kernel-cunTk1MwBs8s++Sfvej+rw@public.gmane.org" <linaro-kernel-cunTk1MwBs8s++Sfvej+rw@public.gmane.org>,
        Jason Cooper <jason-NLaQJdtUoK4Be96aLqz0jA@public.gmane.org>,
        "rtc-linux@googlegr
To: Alexandre Belloni <alexandre.belloni-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>
Return-path: <linux-tegra-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20170621083907.y3gadsmsoufa5niv-m++hUPXGwpdeoWH0uzbU5w@public.gmane.org>
Sender: linux-tegra-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, Jun 21, 2017 at 10:39:07AM +0200, Alexandre Belloni wrote:
> On 21/06/2017 at 09:51:52 +0200, Pavel Machek wrote:
> > If someone uses different threshold, well, there will be
> > confusion. But only for users that have their rtc set to the past,
> > which is quite unusual.
> > 
> 
> Or not, having an RTC set in the past is actually quite common. I'd find
> it weird to have a new device boot and be set to a date in the future.

... and that basically means you can't use hardware that stores RTC
time as a 32-bit number of seconds past 2106.

> Also note that the threshold or offset thing may seem like a good idea
> but fails with many RTCs because of how they handle leap years.

Not for the case being discussed.  A 32-bit counter of seconds knows
nothing about leap years - all that is handled by the conversion
functions.

-- 
RMK's Patch system: http://www.armlinux.org.uk/developer/patches/
FTTC broadband for 0.8mile line: currently at 9.6Mbps down 400kbps up
according to speedtest.net.
