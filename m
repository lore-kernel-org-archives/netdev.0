From: "George G. Davis" <george_davis@mentor.com>
Subject: Re: [PATCH] net: fec: dt: convert phy-reset-gpios to use GPIOD API
Date: Tue, 31 May 2016 14:24:50 -0400
Message-ID: <20160531182450.GA20696@gandalf.middle.earth.net>
References: <1464715071-56012-1-git-send-email-george_davis@mentor.com>
 <CAOMZO5C7nMsV6LtjtO7AZdj8H4248YBr-DYMQ77z-h9rJhURbg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: "linux-gpio@vger.kernel.org" <linux-gpio@vger.kernel.org>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	"devicetree@vger.kernel.org" <devicetree@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Fugang Duan <fugang.duan@nxp.com>,
	Rob Herring <robh+dt@kernel.org>,
	Pawel Moll <pawel.moll@arm.com>,
	Mark Rutland <mark.rutland@arm.com>,
	Ian Campbell <ijc+devicetree@hellion.org.uk>,
	Kumar Gala <galak@codeaurora.org>,
	Shawn Guo <shawnguo@kernel.org>,
	Sascha Hauer <kernel@pengutronix.de>,
	Russell King <linux@armlinux.org.uk>,
	Linus Walleij <linus.walleij@linaro.org>,
	Alexandre Courbot <gnurou@gmail.com>
To: Fabio Estevam <festevam@gmail.com>
Return-path: <linux-gpio-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CAOMZO5C7nMsV6LtjtO7AZdj8H4248YBr-DYMQ77z-h9rJhURbg@mail.gmail.com>
Sender: linux-gpio-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello Fabio,

On Tue, May 31, 2016 at 02:26:54PM -0300, Fabio Estevam wrote:
> On Tue, May 31, 2016 at 2:17 PM, George G. Davis
> <george_davis@mentor.com> wrote:
> > Convert the i.MX FEC driver and DT files to use the GPIOD API
> > which automatically handles GPIO polarity.
> >
> > Signed-off-by: George G. Davis <george_davis@mentor.com>
> 
> In order to avoid breaking old dtb's a property called
> 'phy-reset-active-high' has been introduced.
> 
> Check: 962d8cdc3133435a ("net: fec: Rename "phy-reset-active-low"
> property") and 64f10f6ebf5a6d3ae ("net: fec: Add
> "phy-reset-active-low" property to DT").

The GPIOD API handles GPIO active assertion levels as defined by the 
DT binding. So the phy-reset-active-high and/or phy-reset-active-low
property is not needed when using the GPIOD API - just define
GPIO_ACTIVE_LOW or GPIO_ACTIVE_HIGH as required for the board and the
GPIOD API will handle active assert/deassert level as needed.

-- 
Regards,
George
