From: Baruch Siach <baruch@tkos.co.il>
Subject: Re: [PATCH net-next v2 10/10] arm64: dts: marvell: mcbin: enable
 more networking ports
Date: Wed, 23 Aug 2017 10:28:42 +0300
Message-ID: <20170823072842.ibk6gqtswhamvppy@sapphire.tkos.co.il>
References: <20170822170830.32413-1-antoine.tenart@free-electrons.com>
 <20170822170830.32413-11-antoine.tenart@free-electrons.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, jason@lakedaemon.net, andrew@lunn.ch,
        gregory.clement@free-electrons.com,
        sebastian.hesselbarth@gmail.com,
        thomas.petazzoni@free-electrons.com, netdev@vger.kernel.org,
        linux@armlinux.org.uk, nadavh@marvell.com, stefanc@marvell.com,
        mw@semihalf.com, linux-arm-kernel@lists.infradead.org
To: Antoine Tenart <antoine.tenart@free-electrons.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from guitar.tcltek.co.il ([192.115.133.116]:46619 "EHLO
        mx.tkos.co.il" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753329AbdHWH2p (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 23 Aug 2017 03:28:45 -0400
Content-Disposition: inline
In-Reply-To: <20170822170830.32413-11-antoine.tenart@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Antoine,

On Tue, Aug 22, 2017 at 07:08:30PM +0200, Antoine Tenart wrote:
> This patch enables the two GE/SFP ports. They are configured in 10GKR
> mode by default. To do this the cpm_xdmio is enabled as well, and two
> phy descriptions are added.
> 
> Signed-off-by: Antoine Tenart <antoine.tenart@free-electrons.com>
> Tested-by: Marcin Wojtas <mw@semihalf.com>
> ---
>  arch/arm64/boot/dts/marvell/armada-8040-mcbin.dts | 30 +++++++++++++++++++++++
>  1 file changed, 30 insertions(+)
> 
> diff --git a/arch/arm64/boot/dts/marvell/armada-8040-mcbin.dts b/arch/arm64/boot/dts/marvell/armada-8040-mcbin.dts
> index abd39d1c1739..6cb4b000e1ac 100644
> --- a/arch/arm64/boot/dts/marvell/armada-8040-mcbin.dts
> +++ b/arch/arm64/boot/dts/marvell/armada-8040-mcbin.dts
> @@ -127,6 +127,30 @@
>  	};
>  };
>  
> +&cpm_xmdio {
> +	status = "okay";
> +
> +	phy0: ethernet-phy@0 {
> +		compatible = "ethernet-phy-ieee802.3-c45";
> +		reg = <0>;
> +	};
> +
> +	phy1: ethernet-phy@1 {

Should be named 'ethernet-phy@8' to match the 'reg' property.

> +		compatible = "ethernet-phy-ieee802.3-c45";
> +		reg = <8>;
> +	};
> +};

baruch

-- 
     http://baruch.siach.name/blog/                  ~. .~   Tk Open Systems
=}------------------------------------------------ooO--U--Ooo------------{=
   - baruch@tkos.co.il - tel: +972.2.679.5364, http://www.tkos.co.il -
