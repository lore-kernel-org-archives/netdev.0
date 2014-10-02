From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH] drivers/net/dsa/Kconfig: Let NET_DSA_BCM_SF2 depend on
 HAS_IOMEM
Date: Thu, 02 Oct 2014 09:44:23 -0700
Message-ID: <542D80E7.6040204@gmail.com>
References: <542D5DAC.4010001@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Richard Weinberger <richard@nod.at>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Chen Gang <gang.chen.5i5j@gmail.com>, davem@davemloft.net,
	leitec@staticky.com, andrew@lunn.ch
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <542D5DAC.4010001@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/02/2014 07:14 AM, Chen Gang wrote:
> NET_DSA_BCM_SF2 need HAS_IOMEM, so depend on it, the related error (w=
ith
> allmodconfig under um):
>=20
>     CC [M]  drivers/net/dsa/bcm_sf2.o
>   drivers/net/dsa/bcm_sf2.c: In function =E2=80=98bcm_sf2_sw_setup=E2=
=80=99:
>   drivers/net/dsa/bcm_sf2.c:487:3: error: implicit declaration of fun=
ction =E2=80=98iounmap=E2=80=99 [-Werror=3Dimplicit-function-declaratio=
n]
>      iounmap(*base);
>      ^
>=20
> Signed-off-by: Chen Gang <gang.chen.5i5j@gmail.com>

Acked-by: Florian Fainelli <f.fainelli@gmail.com>

> ---
>  drivers/net/dsa/Kconfig | 1 +
>  1 file changed, 1 insertion(+)
>=20
> diff --git a/drivers/net/dsa/Kconfig b/drivers/net/dsa/Kconfig
> index ea0697e..9234d80 100644
> --- a/drivers/net/dsa/Kconfig
> +++ b/drivers/net/dsa/Kconfig
> @@ -47,6 +47,7 @@ config NET_DSA_MV88E6171
> =20
>  config NET_DSA_BCM_SF2
>  	tristate "Broadcom Starfighter 2 Ethernet switch support"
> +	depends on HAS_IOMEM
>  	select NET_DSA
>  	select NET_DSA_TAG_BRCM
>  	select FIXED_PHY if NET_DSA_BCM_SF2=3Dy
>=20
