From: Christoph Lameter <cl-vYTEC60ixJUAvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH v6 0/8] ptp: IEEE 1588 hardware clock support
Date: Mon, 27 Sep 2010 10:37:35 -0500 (CDT)
Message-ID: <alpine.DEB.2.00.1009271035110.9258@router.home>
References: <cover.1285261533.git.richard.cochran@omicron.at> <alpine.DEB.2.00.1009231238170.2962@router.home> <1285268380.2587.11.camel@localhost.localdomain> <alpine.DEB.2.00.1009231402420.2962@router.home> <1285273684.2587.92.camel@localhost.localdomain>
 <alpine.DEB.2.00.1009231533040.7522@router.home> <20100923223417.4ed62e5b@lxorguk.ukuu.org.uk> <4C9BC7CE.8020400@riesch.at>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Alan Cox <alan-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org>,
	john stultz <johnstul-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>,
	Richard Cochran <richardcochran-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org,
	linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
	linuxppc-dev-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Krzysztof Halasa <khc-9GfyWEdoJtJmR6Xm/wNWPw@public.gmane.org>,
	Peter Zijlstra <peterz-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>,
	Rodolfo Giometti <giometti-k2GhghHVRtY@public.gmane.org>,
	Thomas Gleixner <tglx-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org>
To: Christian Riesch <christian-U4+xqT1Vg0VeoWH0uzbU5w@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <4C9BC7CE.8020400-U4+xqT1Vg0VeoWH0uzbU5w@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, 23 Sep 2010, Christian Riesch wrote:

> > > It implies clock tuning in userspace for a potential sub microsecond
> > > accurate clock. The clock accuracy will be limited by user space
> > > latencies and noise. You wont be able to discipline the system clock
> > > accurately.
> >
> > Noise matters, latency doesn't.
>
> Well put! That's why we need hardware support for PTP timestamping to reduce
> the noise, but get along well with the clock servo that is steering the PHC in
> user space.

Even if I buy into the catch phrase above: User space is subject to noise
that the in kernel code is not. If you do the tuning over long intervals
then it hopefully averages out but it still causes jitter effects that
affects the degree of accuracy (or sync) that you can reach. And the noise
varies with the load on the system.
