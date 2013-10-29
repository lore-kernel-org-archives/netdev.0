From: Laurent Pinchart <laurent.pinchart-ryLnwIuWjnjg/C1BVhZhaw@public.gmane.org>
Subject: Re: [PATCH 00/19] Enable various Renesas drivers on all ARM platforms
Date: Tue, 29 Oct 2013 14:22:28 +0100
Message-ID: <1844190.ApyucSZX8W@avalon>
References: <1383004027-25036-1-git-send-email-laurent.pinchart+renesas@ideasonboard.com>
	<Pine.LNX.4.64.1310291009121.8404@axis700.grange>
	<1383051980.29619.33.camel@sauron.fi.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linux-fbdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-sh-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Linus Walleij <linus.walleij-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>,
	Guennadi Liakhovetski <g.liakhovetski+renesas-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Thierry Reding <thierry.reding-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	linux-mtd-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, linux-i2c-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Laurent Pinchart <laurent.pinchart+renesas-ryLnwIuWjnjg/C1BVhZhaw@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, Vinod Koul <vinod.koul-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Wolfram Sang <wsa-z923LK4zBo2bacvFa/9K2g@public.gmane.org>, Magnus Damm <magnus.damm-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Eduardo Valentin <eduardo.valentin-l0cyMroinI0@public.gmane.org>,
	Tomi Valkeinen <tomi.valkeinen-l0cyMroinI0@public.gmane.org>,
	linux-serial-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-input-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Zhang Rui <rui.zhang-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>, Chris Ball <cjb-2X9k7bc8m7Mdnm+yROfE0A@public.gmane.org>,
	Jean-Christophe Plagniol-Villard <plagnioj-sclMFOaUSTBWk0Htik3J/w@public.gmane.org>,
	linux-media-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-pwm-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Samuel Ortiz <samuel-jcdQHdrhKHMdnm+yROfE0A@public.gmane.org>, linux-pm-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Ian Molton <ian-zdned+2MO1+9FHfhHBbuYA@public.gmane.org>, Mark
To: dedekind1-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Return-path: <iommu-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1383051980.29619.33.camel-Bxnoe/o8FG+Ef9UqXRslZEEOCMrvLtNR@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/iommu>,
	<mailto:iommu-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/iommu/>
List-Post: <mailto:iommu-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:iommu-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/iommu>,
	<mailto:iommu-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: iommu-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: iommu-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Artem,

On Tuesday 29 October 2013 15:06:20 Artem Bityutskiy wrote:
> On Tue, 2013-10-29 at 10:12 +0100, Guennadi Liakhovetski wrote:
> > On Tue, 29 Oct 2013, Laurent Pinchart wrote:
> > > Hello,
> > > 
> > > This patch series, based on v3.12-rc7, prepares various Renesas drivers
> > > for migration to multiplatform kernels by enabling their compilation or
> > > otherwise fixing them on all ARM platforms. The patches are pretty
> > > straightforward and are described in their commit message.
> > > 
> > > I'd like to get all these patches merged in v3.14. As they will need to
> > > go through their respective subsystems' trees, I would appreciate if all
> > > maintainers involved could notify me when they merge patches from this
> > > series in their tree to help me tracking the merge status. I don't plan
> > > to send pull requests individually for these patches, and I will repost
> > > patches individually if changes are requested during review.
> > > 
> > > If you believe the issue should be solved in a different way (for
> > > instance by removing the architecture dependency completely) please
> > > reply to the cover letter to let other maintainers chime in.
> > 
> > Exactly this was my doubt. If we let these drivers build on all ARM
> > platforms... Maybe we should just let them build everywhere? Unless there
> > are real ARM dependencies. Maybe you could try to remove the restriction
> > and try to build them all on x86?
> 
> If they have never been used on anything but ARM, why would you remove
> ARM dependencies? Just for the sake of compile-checking?
> 
> Also, if ARM dependency is ever removed, all these should become 'n' by
> default in the Kconfig, in order to make sure they do not slip into
> defconfigs of different architectures.

The idea is that, if ARM is neither a compile-time nor runtime dependency, it 
should not be specified in Kconfig. However, if the IP core has never been 
used on anything but SuperH and ARM, I don't think clobbering the config 
process with drivers that can't be used on the target architecture would be a 
really good idea, especially now that we have a COMPILE_TEST Kconfig option. 
My preference does goes to SUPERH || ARM || COMPILE_TEST over no dependency at 
all.

-- 
Regards,

Laurent Pinchart
