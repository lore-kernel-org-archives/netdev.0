From: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>
Subject: Re: [PATCH V14 3/4] ptp: Added a clock driver for the IXP46x.
Date: Mon, 18 Apr 2011 10:26:38 +0200
Message-ID: <201104181026.39107.arnd@arndb.de>
References: <cover.1303107532.git.richard.cochran@omicron.at>
	<20110418080606.GA3809@riccoc20.at.omicron.at>
	<201104181021.01279.arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Thomas Gleixner <tglx-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org>, Rodolfo Giometti <giometti-k2GhghHVRtY@public.gmane.org>,
	Peter Zijlstra <peterz-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>, linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Russell King <linux-lFZ/pmaqli7XmaaqVzeoHQ@public.gmane.org>,
	John Stultz <john.stultz-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>,
	Alan Cox <alan-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Mike Frysinger <vapier-aBrp7R+bbdUdnm+yROfE0A@public.gmane.org>,
	Christoph Lameter <cl-vYTEC60ixJUAvxtiuMwx3w@public.gmane.org>, linuxppc-dev-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
	Krzysztof Halasa <khc-9GfyWEdoJtJmR6Xm/wNWPw@public.gmane.org>
To: Richard Cochran <richardcochran-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
In-Reply-To: <201104181021.01279.arnd-r2nGTMty4D4@public.gmane.org>
List-Unsubscribe: <https://lists.ozlabs.org/options/devicetree-discuss>,
	<mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/devicetree-discuss>
List-Post: <mailto:devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
List-Help: <mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=help>
List-Subscribe: <https://lists.ozlabs.org/listinfo/devicetree-discuss>,
	<mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=subscribe>
Errors-To: devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org
Sender: devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org
List-Id: netdev.vger.kernel.org

On Monday 18 April 2011, Arnd Bergmann wrote:
> On Monday 18 April 2011, Richard Cochran wrote:
> > On Mon, Apr 18, 2011 at 08:56:03AM +0200, Arnd Bergmann wrote:
> > > On Monday 18 April 2011, Richard Cochran wrote:
> > > > +
> > > > +       lo = __raw_readl(&regs->channel[ch].src_uuid_lo);
> > > > +       hi = __raw_readl(&regs->channel[ch].src_uuid_hi);
> > > > +
> > > 
> > > I guess you should use readl(), not __raw_readl() here. The __raw_* functions
> > > are not meant for device drivers.
> > 
> > Krzysztof had a different opinion about this.
> > 
> >     https://lkml.org/lkml/2011/1/8/67
> > 
> > Anyway, it is his driver, and I just followed what he does elsewhere
> > in the driver. It make sense to me to keep the driver consistent.
> > Maybe we should make the change throughout?
> 
> It would certainly be useful to fix it up. I now realized that this driver
> supports both big-endian and little-endian configurations, so just using
> readl() is certainly broken.
> There should probably be an ixp specific version of the safe I/O accessors
> to deal with it on all on-chip peripherals in a safe way.

Anyway, not your problem then, just leave it like it is.

Acked-by: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>
