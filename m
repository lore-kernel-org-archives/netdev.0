From: Jean-Francois Moine <moinejf@free.fr>
Subject: Re: [PATCH v4 08/10] ARM: dts: sun8i: Enable sun8i-emac on the
 Orange Pi 2
Date: Wed, 12 Oct 2016 10:55:59 +0200
Message-ID: <20161012105559.aaf9122e376fa5969a2e61d9@free.fr>
References: <1475828757-926-1-git-send-email-clabbe.montjoie@gmail.com>
 <1475828757-926-9-git-send-email-clabbe.montjoie@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: mark.rutland@arm.com, andrew@lunn.ch, f.fainelli@gmail.com,
 devicetree@vger.kernel.org, netdev@vger.kernel.org, linux@armlinux.org.uk,
 linux-kernel@vger.kernel.org, wens@csie.org, robh+dt@kernel.org,
 maxime.ripard@free-electrons.com, davem@davemloft.net,
 linux-arm-kernel@lists.infradead.org
To: Corentin Labbe <clabbe.montjoie@gmail.com>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <1475828757-926-9-git-send-email-clabbe.montjoie@gmail.com>
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

On Fri,  7 Oct 2016 10:25:55 +0200
Corentin Labbe <clabbe.montjoie@gmail.com> wrote:

> The sun8i-emac hardware is present on the Orange PI 2.
> It uses the internal PHY.
> =

> This patch create the needed emac node.
> =

> Signed-off-by: Corentin Labbe <clabbe.montjoie@gmail.com>
> ---
>  arch/arm/boot/dts/sun8i-h3-orangepi-2.dts | 8 ++++++++
>  1 file changed, 8 insertions(+)
> =

> diff --git a/arch/arm/boot/dts/sun8i-h3-orangepi-2.dts b/arch/arm/boot/dt=
s/sun8i-h3-orangepi-2.dts
> index f93f5d1..5608eb4 100644
> --- a/arch/arm/boot/dts/sun8i-h3-orangepi-2.dts
> +++ b/arch/arm/boot/dts/sun8i-h3-orangepi-2.dts
> @@ -54,6 +54,7 @@
>  =

>  	aliases {
>  		serial0 =3D &uart0;
> +		ethernet0 =3D &emac;

As there is no 'of_alias_get_id' in the driver, this alias is useless.

>  	};
>  =

>  	chosen {
> @@ -184,3 +185,10 @@
>  	usb1_vbus-supply =3D <&reg_usb1_vbus>;
>  	status =3D "okay";
>  };
> +
> +&emac {
> +	phy-handle =3D <&int_mii_phy>;
> +	phy-mode =3D "mii";
> +	allwinner,leds-active-low;
> +	status =3D "okay";
> +};
> -- =

> 2.7.3
> =

> =

> _______________________________________________
> linux-arm-kernel mailing list
> linux-arm-kernel@lists.infradead.org
> http://lists.infradead.org/mailman/listinfo/linux-arm-kernel


-- =

Ken ar c'henta=F1	|	      ** Breizh ha Linux atav! **
Jef		|		http://moinejf.free.fr/
