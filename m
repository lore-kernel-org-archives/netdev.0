From: Heiko Stuebner <heiko@sntech.de>
Subject: Re: [PATCH] ARM: dts: rockchip: disable gmac by default in rk3288.dtsi
Date: Sat, 14 Mar 2015 19:40:21 +0100
Message-ID: <27431752.zqze5zkeW3@phil>
References: <1426294532-32078-1-git-send-email-amstan@chromium.org> <1426294532-32078-2-git-send-email-amstan@chromium.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: roger.chen@rock-chips.com, dianders@chromium.org,
	peppe.cavallaro@st.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-rockchip@lists.infradead.org,
	kever.yang@rock-chips.com, eddie.cai@rock-chips.com,
	Rob Herring <robh+dt@kernel.org>,
	Pawel Moll <pawel.moll@arm.com>,
	Mark Rutland <mark.rutland@arm.com>,
	Ian Campbell <ijc+devicetree@hellion.org.uk>,
	Kumar Gala <galak@codeaurora.org>,
	Russell King <linux@arm.linux.org.uk>,
	linux-arm-kernel@lists.infradead.org, devicetree@vger.kernel.org
To: Alexandru M Stan <amstan@chromium.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1426294532-32078-2-git-send-email-amstan@chromium.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Am Freitag, 13. M=E4rz 2015, 17:55:32 schrieb Alexandru M Stan:
> This block should not be enabled by default or else if the kconfig is=
 set,
> it will try to load/probe even if there's no phy connected.
>=20
> Signed-off-by: Alexandru M Stan <amstan@chromium.org>

applied to my fixes branch


Thanks
Heiko

> ---
>  arch/arm/boot/dts/rk3288.dtsi | 1 +
>  1 file changed, 1 insertion(+)
>=20
> diff --git a/arch/arm/boot/dts/rk3288.dtsi b/arch/arm/boot/dts/rk3288=
=2Edtsi
> index d771f68..eccc78d 100644
> --- a/arch/arm/boot/dts/rk3288.dtsi
> +++ b/arch/arm/boot/dts/rk3288.dtsi
> @@ -411,6 +411,7 @@
>  			"mac_clk_rx", "mac_clk_tx",
>  			"clk_mac_ref", "clk_mac_refout",
>  			"aclk_mac", "pclk_mac";
> +		status =3D "disabled";
>  	};
>=20
>  	usb_host0_ehci: usb@ff500000 {
