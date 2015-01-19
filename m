From: Stefan Agner <stefan@agner.ch>
Subject: Re: [PATCH net-next 1/1] ARM: dts: imx6sx: correct i.MX6sx sdb
 board enet phy address
Date: Mon, 19 Jan 2015 11:04:34 +0100
Message-ID: <c590198f7ed3de207da6d7c821a6779b@agner.ch>
References: <1421660282-29494-1-git-send-email-b38611@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: shawn.guo@linaro.org, davem@davemloft.net, netdev@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org, s.hauer@pengutronix.de
To: Fugang Duan <b38611@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kmu-office.ch ([178.209.48.109]:36238 "EHLO
	mail.kmu-office.ch" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751226AbbASKEk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Jan 2015 05:04:40 -0500
In-Reply-To: <1421660282-29494-1-git-send-email-b38611@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2015-01-19 10:38, Fugang Duan wrote:
> The commit (3d125f9c91c5) cause i.MX6SX sdb enet cannot work. The cause is
> the commit add mdio node with un-correct phy address.

Sorry about that, somehow I did not take in consideration that that
could be different on the SoloX board.. Just checked again on Vybrid, it
is correct there, the dual PHY DP83849I addresses the two ports with 0
and 1 respectively.

> 
> The patch just correct i.MX6sx sdb board enet phy address.

Acked-by: Stefan Agner <stefan@agner.ch>

> 
> Signed-off-by: Fugang Duan <B38611@freescale.com>
> ---
>  arch/arm/boot/dts/imx6sx-sdb.dts |    4 ++--
>  1 files changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/arch/arm/boot/dts/imx6sx-sdb.dts b/arch/arm/boot/dts/imx6sx-sdb.dts
> index 8c1febd..9db123f 100644
> --- a/arch/arm/boot/dts/imx6sx-sdb.dts
> +++ b/arch/arm/boot/dts/imx6sx-sdb.dts
> @@ -167,11 +167,11 @@
>  		#size-cells = <0>;
>  
>  		ethphy1: ethernet-phy@0 {
> -			reg = <0>;
> +			reg = <1>;
>  		};
>  
>  		ethphy2: ethernet-phy@1 {
> -			reg = <1>;
> +			reg = <2>;
>  		};
>  	};
>  };
