From: Lothar =?UTF-8?B?V2HDn21hbm4=?= <LW@KARO-electronics.de>
Subject: Re: [Patch v4 net-next 12/12] ARM: dts: imx6sx: add multi-queue
 support enet
Date: Mon, 15 Sep 2014 09:31:16 +0200
Message-ID: <20140915093116.3a9b7cb0@ipc1.ka-ro>
References: <1410555657-10744-1-git-send-email-Frank.Li@freescale.com>
	<1410555657-10744-13-git-send-email-Frank.Li@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <b38611@freescale.com>, <davem@davemloft.net>,
	<netdev@vger.kernel.org>, <lznuaa@gmail.com>,
	devicetree@vger.kernel.org, shawn.guo@linaro.org,
	linux@arm.linux.org.uk, linux-arm-kernel@lists.infradead.org
To: <Frank.Li@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.karo-electronics.de ([81.173.242.67]:54948 "EHLO
	mail.karo-electronics.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753354AbaIOHbb convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Sep 2014 03:31:31 -0400
In-Reply-To: <1410555657-10744-13-git-send-email-Frank.Li@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

=46rank.Li@freescale.com wrote:
> From: Frank Li <Frank.Li@freescale.com>
>=20
> Enable 3 queues suppport for ethernet
>=20
> Signed-off-by: Frank Li <Frank.Li@freescale.com>
> ---
>  arch/arm/boot/dts/imx6sx.dtsi | 2 ++
>  1 file changed, 2 insertions(+)
>=20
> diff --git a/arch/arm/boot/dts/imx6sx.dtsi b/arch/arm/boot/dts/imx6sx=
=2Edtsi
> index f4b9da6..0a03260 100644
> --- a/arch/arm/boot/dts/imx6sx.dtsi
> +++ b/arch/arm/boot/dts/imx6sx.dtsi
> @@ -776,6 +776,8 @@
>  					 <&clks IMX6SX_CLK_ENET_PTP>;
>  				clock-names =3D "ipg", "ahb", "ptp",
>  					      "enet_clk_ref", "enet_out";
> +				fsl,num-tx-queues=3D<3>;
> +				fsl,num-rx-queues=3D<3>;
missing spaces around '=3D'


Lothar Wa=C3=9Fmann
--=20
___________________________________________________________

Ka-Ro electronics GmbH | Pascalstra=C3=9Fe 22 | D - 52076 Aachen
Phone: +49 2408 1402-0 | Fax: +49 2408 1402-10
Gesch=C3=A4ftsf=C3=BChrer: Matthias Kaussen
Handelsregistereintrag: Amtsgericht Aachen, HRB 4996

www.karo-electronics.de | info@karo-electronics.de
___________________________________________________________
