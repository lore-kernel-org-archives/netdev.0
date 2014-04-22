From: Hubert Chaumette <hchaumette@adeneo-embedded.com>
Subject: Re: [PATCH] ARM: i.MX6: Add OF configuration support for ksz9031
Date: Tue, 22 Apr 2014 18:09:12 +0200
Message-ID: <1398182952.1593.20.camel@EMBLYSD005.adetelgroup.com>
References: <1397466496-24750-1-git-send-email-hchaumette@adeneo-embedded.com>
	 <20140416080322.GA11602@dragon>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, kernel@pengutronix.de,
	linux@arm.linux.org.uk, f.fainelli@gmail.com,
	linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org,
	agust@denx.de
To: Shawn Guo <shawn.guo@linaro.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140416080322.GA11602@dragon>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le mercredi 16 avril 2014 =C3=A0 16:03 +0800, Shawn Guo a =C3=A9crit :
> On Mon, Apr 14, 2014 at 11:08:16AM +0200, Hubert Chaumette wrote:
> > - Adds support for ksz9031 PAD skew configuration over devicetree
> > - Removes hard-coded pad skew configuration for imx6q-sabrelite, no=
w redundant
> >   with arch/arm/boot/dts/imx6qdl-sabrelite.dtsi
> >=20
> > Tested on congatec conga-QEVAL board with conga-QMX6 module.
> >=20
> > This patch is based on Anatolij Gustschin's patch from
> > http://www.spinics.net/lists/arm-kernel/msg319771.html
> >=20
> > Signed-off-by: Hubert Chaumette <hchaumette@adeneo-embedded.com>
> > ---
> >  arch/arm/mach-imx/mach-imx6q.c |  45 ----------
> >  drivers/net/phy/micrel.c       | 185 +++++++++++++++++++++++++++++=
+++++++++++-
>=20
> You should probably leave mach-imx6q.c unchanged, because dropping th=
e
> phy fix-up from there may break old DTBs.  And the changes on micrel.=
c
> should be submitted to net maintainer.
>=20
> Shawn

I've re-sent it without the changes to mach-imx6q.c. Thanks for your
review.

Regards,
Hubert
