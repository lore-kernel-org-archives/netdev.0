From: Krzysztof Halasa <khc-9GfyWEdoJtJmR6Xm/wNWPw@public.gmane.org>
Subject: Re: [PATCH V12 3/4] ptp: Added a clock driver for the IXP46x.
Date: Mon, 14 Mar 2011 00:40:48 +0100
Message-ID: <m3ei6azj0f.fsf@intrepid.localdomain>
References: <cover.1298878618.git.richard.cochran@omicron.at>
	<cd6ddff0dcca60ac88b35660505d7bf54ad32405.1298878618.git.richard.cochran@omicron.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org,
	linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
	linuxppc-dev-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org, Alan Cox <alan-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org>,
	Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>,
	Christoph Lameter <cl-vYTEC60ixJUAvxtiuMwx3w@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	John Stultz <john.stultz-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>,
	Peter Zijlstra <peterz-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>,
	Rodolfo Giometti <giometti-k2GhghHVRtY@public.gmane.org>,
	Thomas Gleixner <tglx-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org>,
	Benjamin Herrenschmidt <benh-XVmvHMARGAS8U2dJNN8I7kB+6BGkLq7r@public.gmane.org>,
	Mike Frysinger <vapier-aBrp7R+bbdUdnm+yROfE0A@public.gmane.org>,
	Paul Mackerras <paulus-eUNUBHrolfbYtjvyW6yDsg@public.gmane.org>,
	Russell King <linux-lFZ/pmaqli7XmaaqVzeoHQ@public.gmane.org>
To: Richard Cochran <richardcochran-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <cd6ddff0dcca60ac88b35660505d7bf54ad32405.1298878618.git.richard.cochran-3mrvs1K0uXizZXS1Dc/lvw@public.gmane.org>
	(Richard Cochran's message of "Mon, 28 Feb 2011 08:58:27 +0100")
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Richard Cochran <richardcochran-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> writes:

> This patch adds a driver for the hardware time stamping unit found on the
> IXP465. The basic clock operations and an external trigger are implemented.
>
> Signed-off-by: Richard Cochran <richard.cochran-3mrvs1K0uXizZXS1Dc/lvw@public.gmane.org>
> Acked-by: John Stultz <johnstul-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
> ---
>  arch/arm/mach-ixp4xx/include/mach/ixp46x_ts.h |   78 ++++++
>  drivers/net/arm/ixp4xx_eth.c                  |  192 ++++++++++++++-
>  drivers/ptp/Kconfig                           |   13 +
>  drivers/ptp/Makefile                          |    1 +
>  drivers/ptp/ptp_ixp46x.c                      |  332 +++++++++++++++++++++++++

I can't see any obvious problem in this code, though I don't have IXP46x
hardware.

Acked-by: Krzysztof Halasa <khc-9GfyWEdoJtJmR6Xm/wNWPw@public.gmane.org>
-- 
Krzysztof Halasa
