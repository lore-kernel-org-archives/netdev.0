From: Artem Bityutskiy <dedekind1@gmail.com>
Subject: Re: [PATCH 00/19] Enable various Renesas drivers on all ARM platforms
Date: Tue, 29 Oct 2013 15:54:27 +0200
Message-ID: <1383054867.29619.34.camel@sauron.fi.intel.com>
References: <1383004027-25036-1-git-send-email-laurent.pinchart+renesas@ideasonboard.com>
 <Pine.LNX.4.64.1310291009121.8404@axis700.grange>
 <1383051980.29619.33.camel@sauron.fi.intel.com> <1844190.ApyucSZX8W@avalon>
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
 "David S. Miller" <davem@davemloft.net>, Vinod Koul <vinod.koul@intel.com>,
 Joerg Roedel <joro@8bytes.org>, Wolfram Sang <wsa@the-dreams.de>,
 Magnus Damm <magnus.damm@gmail.com>,
 Eduardo Valentin <eduardo.valentin@ti.com>,
 Tomi Valkeinen <tomi.valkeinen@ti.com>, linux-serial@vger.kernel.org,
 linux-input@vger.kernel.org, Zhang Rui <rui.zhang@intel.com>,
 Chris Ball <cjb@laptop.org>,
 Jean-Christophe Plagniol-Villard <plagnioj@jcrosoft.com>,
 linux-media@vger.kernel.org, linux-pwm@vger.kernel.org,
 Samuel Ortiz <samuel@sortiz.org>, linux-pm@vger.kernel.org,
 Ian
To: Laurent Pinchart <laurent.pinchart@ideasonboard.com>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <1844190.ApyucSZX8W@avalon>
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

On Tue, 2013-10-29 at 14:22 +0100, Laurent Pinchart wrote:
> > Also, if ARM dependency is ever removed, all these should become 'n' by
> > default in the Kconfig, in order to make sure they do not slip into
> > defconfigs of different architectures.
> 
> The idea is that, if ARM is neither a compile-time nor runtime dependency, it 
> should not be specified in Kconfig. However, if the IP core has never been 
> used on anything but SuperH and ARM, I don't think clobbering the config 
> process with drivers that can't be used on the target architecture would be a 
> really good idea, especially now that we have a COMPILE_TEST Kconfig option. 
> My preference does goes to SUPERH || ARM || COMPILE_TEST over no dependency at 
> all.

Ah, OK, I missed the entire COMPILE_TEST story.

-- 
Best Regards,
Artem Bityutskiy
