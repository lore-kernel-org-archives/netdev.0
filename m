From: Nicolas Ferre <nicolas.ferre@atmel.com>
Subject: Re: [NET-NEXT PATCH] net: macb: Change capability mask for jumbo
 support
Date: Thu, 23 Jul 2015 14:34:55 +0200
Message-ID: <55B0DF6F.9050002@atmel.com>
References: <1437646465-6462-1-git-send-email-harinik@xilinx.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<devicetree@vger.kernel.org>, <harinik@xilinx.com>,
	<punnaia@xilinx.com>, <michals@xilinx.com>
To: Harini Katakam <harini.katakam@xilinx.com>, <davem@davemloft.net>,
	<robh+dt@kernel.org>, <pawel.moll@arm.com>, <mark.rutland@arm.com>,
	<ijc+devicetree@hellion.org.uk>, <galak@codeaurora.org>,
	<boris.brezillon@free-electrons.com>,
	<alexandre.belloni@free-electrons.com>,
	<harinikatakamlinux@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1437646465-6462-1-git-send-email-harinik@xilinx.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le 23/07/2015 12:14, Harini Katakam a =E9crit :
> JUMBO and NO_GIGABIT_HALF have the same capability masks.
> Change one of them.
>=20
> Signed-off-by: Harini Katakam <harinik@xilinx.com>

Yes, indeed:
Acked-by: Nicolas Ferre <nicolas.ferre@atmel.com>

> ---
>  drivers/net/ethernet/cadence/macb.h |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>=20
> diff --git a/drivers/net/ethernet/cadence/macb.h b/drivers/net/ethern=
et/cadence/macb.h
> index d746559..8fb80b2 100644
> --- a/drivers/net/ethernet/cadence/macb.h
> +++ b/drivers/net/ethernet/cadence/macb.h
> @@ -399,7 +399,7 @@
>  #define MACB_CAPS_GIGABIT_MODE_AVAILABLE	0x20000000
>  #define MACB_CAPS_SG_DISABLED			0x40000000
>  #define MACB_CAPS_MACB_IS_GEM			0x80000000
> -#define MACB_CAPS_JUMBO				0x00000008
> +#define MACB_CAPS_JUMBO				0x00000010
> =20
>  /* Bit manipulation macros */
>  #define MACB_BIT(name)					\
>=20


--=20
Nicolas Ferre
