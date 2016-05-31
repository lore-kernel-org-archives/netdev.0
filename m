From: Uwe =?iso-8859-1?Q?Kleine-K=F6nig?=
	<u.kleine-koenig@pengutronix.de>
Subject: Re: [PATCH] net: fec: dt: convert phy-reset-gpios to use GPIOD API
Date: Tue, 31 May 2016 19:47:48 +0200
Message-ID: <20160531174748.GI26768@pengutronix.de>
References: <1464715071-56012-1-git-send-email-george_davis@mentor.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-gpio@vger.kernel.org, linux-kernel@vger.kernel.org,
	devicetree@vger.kernel.org, netdev@vger.kernel.org,
	Mark Rutland <mark.rutland@arm.com>,
	Alexandre Courbot <gnurou@gmail.com>,
	Fugang Duan <fugang.duan@nxp.com>,
	Pawel Moll <pawel.moll@arm.com>,
	Ian Campbell <ijc+devicetree@hellion.org.uk>,
	Linus Walleij <linus.walleij@linaro.org>,
	Russell King <linux@armlinux.org.uk>,
	Rob Herring <robh+dt@kernel.org>,
	Sascha Hauer <kernel@pengutronix.de>,
	Kumar Gala <galak@codeaurora.org>,
	Shawn Guo <shawnguo@kernel.org>
To: "George G. Davis" <george_davis@mentor.com>
Return-path: <linux-gpio-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1464715071-56012-1-git-send-email-george_davis@mentor.com>
Sender: linux-gpio-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello George,

On Tue, May 31, 2016 at 01:17:51PM -0400, George G. Davis wrote:
> Convert the i.MX FEC driver and DT files to use the GPIOD API
> which automatically handles GPIO polarity.

additionally to what Fabio said, there is also a nicer approach in the
making. The resulting dts would look as follows:

	&fec {
		phy-handle =3D <&ethphy>;
		...

		mdio {
			#address-cells =3D <1>;
			#size-cells =3D <0>;

			ethphy: ethernet-phy@7 {
				...

				reset-gpios =3D <&gpio1 25 GPIO_ACTIVE_LOW>;
			};
		};
	};

Best regards
Uwe

--=20
Pengutronix e.K.                           | Uwe Kleine-K=F6nig        =
    |
Industrial Linux Solutions                 | http://www.pengutronix.de/=
  |
--
To unsubscribe from this list: send the line "unsubscribe linux-gpio" i=
n
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
