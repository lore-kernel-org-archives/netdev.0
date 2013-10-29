From: Artem Bityutskiy <dedekind1@gmail.com>
Subject: Re: [PATCH 00/19] Enable various Renesas drivers on all ARM platforms
Date: Tue, 29 Oct 2013 15:06:20 +0200
Message-ID: <1383051980.29619.33.camel@sauron.fi.intel.com>
References: <1383004027-25036-1-git-send-email-laurent.pinchart+renesas@ideasonboard.com>
 <Pine.LNX.4.64.1310291009121.8404@axis700.grange>
Reply-To: dedekind1@gmail.com
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linux-fbdev@vger.kernel.org, linux-sh@vger.kernel.org,
 Linus Walleij <linus.walleij@linaro.org>,
 Guennadi Liakhovetski <g.liakhovetski+renesas@gmail.com>,
 Thierry Reding <thierry.reding@gmail.com>, linux-mtd@lists.infradead.org,
 linux-i2c@vger.kernel.org,
 Laurent Pinchart <laurent.pinchart+renesas@ideasonboard.com>,
 Vinod Koul <vinod.koul@intel.com>, Joerg Roedel <joro@8bytes.org>,
 Wolfram Sang <wsa@the-dreams.de>, Magnus Damm <magnus.damm@gmail.com>,
 Eduardo Valentin <eduardo.valentin@ti.com>,
 Tomi Valkeinen <tomi.valkeinen@ti.com>, linux-serial@vger.kernel.org,
 linux-input@vger.kernel.org, Zhang Rui <rui.zhang@intel.com>,
 Chris Ball <cjb@laptop.org>,
 Jean-Christophe Plagniol-Villard <plagnioj@jcrosoft.com>,
 linux-media@vger.kernel.org, linux-pwm@vger.kernel.org,
 Samuel Ortiz <samuel@sortiz.org>, linux-pm@vger.kernel.org,
 Ian Molton <ian@mnementh.co.uk>, Mark Brown <b
To: Guennadi Liakhovetski <g.liakhovetski@gmx.de>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <Pine.LNX.4.64.1310291009121.8404@axis700.grange>
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

On Tue, 2013-10-29 at 10:12 +0100, Guennadi Liakhovetski wrote:
> Hi Laurent
> 
> On Tue, 29 Oct 2013, Laurent Pinchart wrote:
> 
> > Hello,
> > 
> > This patch series, based on v3.12-rc7, prepares various Renesas drivers
> > for migration to multiplatform kernels by enabling their compilation or
> > otherwise fixing them on all ARM platforms. The patches are pretty
> > straightforward and are described in their commit message.
> > 
> > I'd like to get all these patches merged in v3.14. As they will need to go
> > through their respective subsystems' trees, I would appreciate if all
> > maintainers involved could notify me when they merge patches from this series
> > in their tree to help me tracking the merge status. I don't plan to send pull
> > requests individually for these patches, and I will repost patches
> > individually if changes are requested during review.
> > 
> > If you believe the issue should be solved in a different way (for instance by
> > removing the architecture dependency completely) please reply to the cover
> > letter to let other maintainers chime in.
> 
> Exactly this was my doubt. If we let these drivers build on all ARM 
> platforms... Maybe we should just let them build everywhere? Unless there 
> are real ARM dependencies. Maybe you could try to remove the restriction 
> and try to build them all on x86?

If they have never been used on anything but ARM, why would you remove
ARM dependencies? Just for the sake of compile-checking?

Also, if ARM dependency is ever removed, all these should become 'n' by
default in the Kconfig, in order to make sure they do not slip into
defconfigs of different architectures.

-- 
Best Regards,
Artem Bityutskiy
