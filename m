From: Laurent Pinchart <laurent.pinchart-ryLnwIuWjnjg/C1BVhZhaw@public.gmane.org>
Subject: Re: [PATCH v2 00/19] Enable various Renesas drivers on all ARM
	platforms
Date: Wed, 13 Nov 2013 00:32:06 +0100
Message-ID: <55374441.jb1As8srky@avalon>
References: <1383086274-11049-1-git-send-email-laurent.pinchart+renesas@ideasonboard.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: , linux-fbdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Wolfram Sang <wsa-z923LK4zBo2bacvFa/9K2g@public.gmane.org>,
	Linus Walleij <linus.walleij-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>,
	Guennadi Liakhovetski <g.liakhovetski+renesas-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Thierry Reding <thierry.reding-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	linux-mtd-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, linux-i2c-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Laurent Pinchart <laurent.pinchart+renesas-ryLnwIuWjnjg/C1BVhZhaw@public.gmane.org>,
	Vinod Koul <vinod.koul-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>, linux-sh-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Magnus Damm <magnus.damm-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Eduardo Valentin <eduardo.valentin-l0cyMroinI0@public.gmane.org>,
	Tomi Valkeinen <tomi.valkeinen-l0cyMroinI0@public.gmane.org>, linux-serial-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-input-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Zhang Rui <rui.zhang-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Chris Ball <cjb-2X9k7bc8m7Mdnm+yROfE0A@public.gmane.org>,
	Jean-Christophe Plagniol-Villard <plagnioj-sclMFOaUSTBWk0Htik3J/w@public.gmane.org>,
	linux-media-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-pwm-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Samuel Ortiz <samuel-jcdQHdrhKHMdnm+yROfE0A@public.gmane.org>, linux-pm-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Ian Molton <ian-zdned+2MO1+9FHfhHBbuYA@public.gmane.org>, Mark Brown <broonie-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	xfoundat@
To: linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org
Return-path: <iommu-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1383086274-11049-1-git-send-email-laurent.pinchart+renesas-ryLnwIuWjnjg/C1BVhZhaw@public.gmane.org>
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

Hello,

On Tuesday 29 October 2013 23:37:35 Laurent Pinchart wrote:
> Hello,
> 
> This patch series, based on v3.12-rc7, prepares various Renesas drivers
> for migration to multiplatform kernels by enabling their compilation or
> otherwise fixing them on all ARM platforms. The patches are pretty
> straightforward and are described in their commit message.
> 
> Changes since v1:
> 
> - The drivers can also be selected when COMPILE_TEST is enabled, regardless
> of the architecture. This should provide a good compromise between wide
> build test coverage and not clobbering configuration with drivers useless
> on non-SuperH, non-ARM platforms.
> 
> - DMA configuration is now unconditional in patch 08/19
> 
> I'd like to get all these patches merged in v3.14. As they will need to go
> through their respective subsystems' trees, I would appreciate if all
> maintainers involved could notify me when they merge patches from this
> series in their tree to help me tracking the merge status. I don't plan to
> send pull requests individually for these patches, and I will repost
> patches individually if changes are requested during review.
> 
> If you believe the issue should be solved in a different way please reply to
> the cover letter to let other maintainers chime in.

This patch series was a prerequisite for a larger rework of Renesas platforms. 
However, we've decided to go with an alternative approach that renames Kconfig 
symbols to avoid touching all the drivers. There is thus no urgency to apply 
this series anymore.

I still plan to enable COMPILE_TEST on Renesas drivers. I will send a v3 of 
these patches based on the feedback received on v2. Patches from v2 that have 
already been applied can be dropped, but there's no need to revert them rebase 
trees as they're not invalid per-se. I will make sure to address the situation 
in v3. I'm sorry for the inconvenience.

-- 
Regards,

Laurent Pinchart
