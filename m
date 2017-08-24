From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next 12/13] arm64: dts: marvell: mcbin: add comphy
 references to Ethernet ports
Date: Thu, 24 Aug 2017 15:58:13 +0200
Message-ID: <20170824135813.GF8022@lunn.ch>
References: <20170824083823.16826-1-antoine.tenart@free-electrons.com>
 <20170824083823.16826-13-antoine.tenart@free-electrons.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, kishon@ti.com, jason@lakedaemon.net,
        sebastian.hesselbarth@gmail.com,
        gregory.clement@free-electrons.com,
        thomas.petazzoni@free-electrons.com, nadavh@marvell.com,
        linux@armlinux.org.uk, linux-kernel@vger.kernel.org,
        mw@semihalf.com, stefanc@marvell.com,
        miquel.raynal@free-electrons.com, netdev@vger.kernel.org
To: Antoine Tenart <antoine.tenart@free-electrons.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170824083823.16826-13-antoine.tenart@free-electrons.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> @@ -189,6 +191,7 @@
>  	status = "okay";
>  	phy = <&ge_phy>;
>  	phy-mode = "sgmii";
> +	phys = <&cps_comphy0 1>;

Does the binding document describe the meaning of the specifier?

     Andrew
