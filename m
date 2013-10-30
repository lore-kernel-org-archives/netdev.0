From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH 00/19] Enable various Renesas drivers on all ARM platforms
Date: Wed, 30 Oct 2013 09:05:03 +0900
Message-ID: <20131030000501.GE21262@verge.net.au>
References: <1383004027-25036-1-git-send-email-laurent.pinchart+renesas@ideasonboard.com>
 <1577821.Q7gttkPE2J@avalon> <20131029172331.GA20251@sirena.org.uk>
 <1422562.0L87CDt5Gd@avalon> <20131029175834.GD20251@sirena.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linux-fbdev@vger.kernel.org, Wolfram Sang <wsa@the-dreams.de>,
 Linus Walleij <linus.walleij@linaro.org>,
 Guennadi Liakhovetski <g.liakhovetski+renesas@gmail.com>,
 Thierry Reding <thierry.reding@gmail.com>, linux-mtd@lists.infradead.org,
 Laurent Pinchart <laurent.pinchart@ideasonboard.com>,
 Laurent Pinchart <laurent.pinchart+renesas@ideasonboard.com>,
 Vinod Koul <vinod.koul@intel.com>, Joerg Roedel <joro@8bytes.org>,
 linux-sh@vger.kernel.org, Magnus Damm <magnus.damm@gmail.com>,
 Eduardo Valentin <eduardo.valentin@ti.com>,
 Tomi Valkeinen <tomi.valkeinen@ti.com>, linux-serial@vger.kernel.org,
 linux-input@vger.kernel.org, Zhang Rui <rui.zhang@intel.com>,
 Chris Ball <cjb@laptop.org>,
 Jean-Christophe Plagniol-Villard <plagnioj@jcrosoft.com>,
 linux-media@vger.kernel.org, linux-pwm@vger.kernel.org,
 Samuel Ortiz <samuel@sortiz.org>, linux-pm@vger.kernel.org,
 Ian Molton <ian@mne
To: Mark Brown <broonie@kernel.org>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
Content-Disposition: inline
In-Reply-To: <20131029175834.GD20251@sirena.org.uk>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

On Tue, Oct 29, 2013 at 10:58:34AM -0700, Mark Brown wrote:
> On Tue, Oct 29, 2013 at 06:29:59PM +0100, Laurent Pinchart wrote:
> > On Tuesday 29 October 2013 10:23:31 Mark Brown wrote:
> > > On Tue, Oct 29, 2013 at 06:05:53PM +0100, Laurent Pinchart wrote:
> > > > The first one is that I can't compile-test all those drivers on all
> > > > architectures. The spi-sh-msiof driver, for instance, uses
> > > > io(read|write)(16|
> 
> > > Which architectures are these and is there not a symbol we can depend on
> > > for them?
> 
> > arch/cris for instance. We can use readl/writel instead (maybe it would be 
> > time to rationalize and document the I/O accessors across all architectures, 
> > but that's another topic).
> 
> It'd certainly be sensible, or adding a config option to depend on if
> you rely on these functions.
> 
> > My point is that there might be other issues that I won't be able to easily 
> > catch. This would break compilation for everybody for no reason, as the 
> > drivers are useless on non-SuperH, non-ARM platforms. That's why I believe 
> > COMPILE_TEST would be a better option as a first step.
> 
> Yes, it would - please do that.  Note that it won't stop anyone running
> into build issues on other architectures though, it's just about
> stopping Kconfig noise.

FWIW, I am happy with using COMPILE_TEST for this series.
