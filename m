From: Shawn Guo <shawn.guo@linaro.org>
Subject: Re: [PATCH net-next v2 1/1] ARM: dts: imx6sx: correct i.MX6sx sdb
 board enet phy address
Date: Tue, 20 Jan 2015 19:15:36 +0800
Message-ID: <20150120111534.GA2766@dragon>
References: <1421743697-26918-1-git-send-email-b38611@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, s.hauer@pengutronix.de, stefan@agner.ch,
	linux-arm-kernel@lists.infradead.org
To: Fugang Duan <b38611@freescale.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f180.google.com ([209.85.192.180]:39570 "EHLO
	mail-pd0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754029AbbATLQY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Jan 2015 06:16:24 -0500
Received: by mail-pd0-f180.google.com with SMTP id ft15so13216215pdb.11
        for <netdev@vger.kernel.org>; Tue, 20 Jan 2015 03:16:24 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1421743697-26918-1-git-send-email-b38611@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 20, 2015 at 04:48:17PM +0800, Fugang Duan wrote:
> The commit (3d125f9c91c5) cause i.MX6SX sdb enet cannot work. The cause is
> the commit add mdio node with un-correct phy address.
> 
> The patch just correct i.MX6sx sdb board enet phy address.
> 
> V2:
> * As Shawn's suggestion that unit-address should match 'reg' property, so
>   update ethernet-phy unit-address.
> 
> Acked-by: Stefan Agner <stefan@agner.ch>
> Signed-off-by: Fugang Duan <B38611@freescale.com>

Acked-by: Shawn Guo <shawn.guo@linaro.org>

David,

I assume that you will send this fix for 3.19, since commit 3d125f9c91c5
was sent via your tree.  Otherwise, let me know and I will manage to
send it via arm-soc tree.

Shawn

> ---
>  arch/arm/boot/dts/imx6sx-sdb.dts |    8 ++++----
>  1 files changed, 4 insertions(+), 4 deletions(-)
> 
> diff --git a/arch/arm/boot/dts/imx6sx-sdb.dts b/arch/arm/boot/dts/imx6sx-sdb.dts
> index 8c1febd..c108bb4 100644
> --- a/arch/arm/boot/dts/imx6sx-sdb.dts
> +++ b/arch/arm/boot/dts/imx6sx-sdb.dts
> @@ -166,12 +166,12 @@
>  		#address-cells = <1>;
>  		#size-cells = <0>;
>  
> -		ethphy1: ethernet-phy@0 {
> -			reg = <0>;
> +		ethphy1: ethernet-phy@1 {
> +			reg = <1>;
>  		};
>  
> -		ethphy2: ethernet-phy@1 {
> -			reg = <1>;
> +		ethphy2: ethernet-phy@2 {
> +			reg = <2>;
>  		};
>  	};
>  };
> -- 
> 1.7.8
> 
