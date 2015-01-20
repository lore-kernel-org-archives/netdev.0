From: Shawn Guo <shawn.guo@linaro.org>
Subject: Re: [PATCH net-next 1/1] ARM: dts: imx6sx: correct i.MX6sx sdb board
 enet phy address
Date: Tue, 20 Jan 2015 16:31:57 +0800
Message-ID: <20150120083156.GY2766@dragon>
References: <1421660282-29494-1-git-send-email-b38611@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org, s.hauer@pengutronix.de,
	stefan@agner.ch
To: Fugang Duan <b38611@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f170.google.com ([209.85.192.170]:55337 "EHLO
	mail-pd0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752312AbbATIcp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Jan 2015 03:32:45 -0500
Received: by mail-pd0-f170.google.com with SMTP id p10so30065889pdj.1
        for <netdev@vger.kernel.org>; Tue, 20 Jan 2015 00:32:44 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1421660282-29494-1-git-send-email-b38611@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 19, 2015 at 05:38:02PM +0800, Fugang Duan wrote:
> The commit (3d125f9c91c5) cause i.MX6SX sdb enet cannot work. The cause is
> the commit add mdio node with un-correct phy address.
> 
> The patch just correct i.MX6sx sdb board enet phy address.
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

The unit-address should match 'reg' property, so it needs an update too.

Shawn

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
> -- 
> 1.7.8
> 
