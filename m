From: Linus Walleij <linus.walleij@linaro.org>
Subject: Re: [PATCH 00/19] Enable various Renesas drivers on all ARM platforms
Date: Tue, 29 Oct 2013 09:28:48 -0700
Message-ID: <CACRpkdbKk=n=6tU=9fD05Gu9utpQSZ1qrK7EqLf5qwaV7eHBWA@mail.gmail.com>
References: <1383004027-25036-1-git-send-email-laurent.pinchart+renesas@ideasonboard.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "linux-fbdev@vger.kernel.org" <linux-fbdev@vger.kernel.org>,
 "linux-sh@vger.kernel.org" <linux-sh@vger.kernel.org>,
 Guennadi Liakhovetski <g.liakhovetski+renesas@gmail.com>,
 Thierry Reding <thierry.reding@gmail.com>,
 "linux-mtd@lists.infradead.org" <linux-mtd@lists.infradead.org>,
 "linux-i2c@vger.kernel.org" <linux-i2c@vger.kernel.org>,
 Vinod Koul <vinod.koul@intel.com>, Joerg Roedel <joro@8bytes.org>,
 Wolfram Sang <wsa@the-dreams.de>, Magnus Damm <magnus.damm@gmail.com>,
 Eduardo Valentin <eduardo.valentin@ti.com>,
 Tomi Valkeinen <tomi.valkeinen@ti.com>,
 "linux-serial@vger.kernel.org" <linux-serial@vger.kernel.org>,
 Linux Input <linux-input@vger.kernel.org>, Zhang Rui <rui.zhang@intel.com>,
 Chris Ball <cjb@laptop.org>,
 Jean-Christophe Plagniol-Villard <plagnioj@jcrosoft.com>,
 "linux-media@vger.kernel.org" <linux-media@vger.kernel.org>,
 "linux-pwm@vger.kernel.org" <linu
To: Laurent Pinchart <laurent.pinchart+renesas@ideasonboard.com>
Return-path: <linux-mtd-bounces+gldm-linux-mtd-36=gmane.org@lists.infradead.org>
In-Reply-To: <1383004027-25036-1-git-send-email-laurent.pinchart+renesas@ideasonboard.com>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-mtd>,
 <mailto:linux-mtd-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-mtd/>
List-Post: <mailto:linux-mtd@lists.infradead.org>
List-Help: <mailto:linux-mtd-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-mtd>,
 <mailto:linux-mtd-request@lists.infradead.org?subject=subscribe>
Sender: "linux-mtd" <linux-mtd-bounces@lists.infradead.org>
Errors-To: linux-mtd-bounces+gldm-linux-mtd-36=gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

On Mon, Oct 28, 2013 at 4:46 PM, Laurent Pinchart
<laurent.pinchart+renesas@ideasonboard.com> wrote:

> If you believe the issue should be solved in a different way (for instance by
> removing the architecture dependency completely) please reply to the cover
> letter to let other maintainers chime in.

I have no real opinions on whether this is a good itermediate step towards
complete arch-independence or not, but I just noticed that you still
have the <mach/*> hierarchy in mach-shmobile/include/mach/*, and
grep:ing around this seems totally unnecessary, I think it would be
easy to produce a patch set eliminating <mach/*> from shmobile.

(Usually we will just move all the headers down into the
mach-shmobile folder.)

Yours,
Linus Walleij

______________________________________________________
Linux MTD discussion mailing list
http://lists.infradead.org/mailman/listinfo/linux-mtd/
