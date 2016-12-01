From: Marcin Wojtas <mw@semihalf.com>
Subject: Re: [PATCH v5 net-next 7/7] ARM64: dts: marvell: Add network support
 for Armada 3700
Date: Thu, 1 Dec 2016 17:05:28 +0100
Message-ID: <CAPv3WKfZ=v7CG+tb504bt4=afdy4q8gFW3db10ORq=K+OYQbZg@mail.gmail.com>
References: <cover.0270f6d2413a709521fe2c8c17fbebea6f2e78d1.1480542157.git-series.gregory.clement@free-electrons.com>
 <f205231e640a2324b8f007073cf54b166a263ed4.1480542157.git-series.gregory.clement@free-electrons.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
        linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
        Jisheng Zhang <jszhang@marvell.com>,
        Arnd Bergmann <arnd@arndb.de>,
        Jason Cooper <jason@lakedaemon.net>,
        Andrew Lunn <andrew@lunn.ch>,
        Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
        Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
        "linux-arm-kernel@lists.infradead.org"
        <linux-arm-kernel@lists.infradead.org>,
        Nadav Haklai <nadavh@marvell.com>,
        Dmitri Epshtein <dima@marvell.com>,
        Yelena Krivosheev <yelena@marvell.com>
To: Gregory CLEMENT <gregory.clement@free-electrons.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <f205231e640a2324b8f007073cf54b166a263ed4.1480542157.git-series.gregory.clement@free-electrons.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Gregory,

2016-11-30 22:42 GMT+01:00 Gregory CLEMENT <gregory.clement@free-electrons.com>:
> Add neta nodes for network support both in device tree for the SoC and
> the board.
>
> Signed-off-by: Gregory CLEMENT <gregory.clement@free-electrons.com>
> ---
>  arch/arm64/boot/dts/marvell/armada-3720-db.dts | 23 +++++++++++++++++++-
>  arch/arm64/boot/dts/marvell/armada-37xx.dtsi   | 23 +++++++++++++++++++-
>  2 files changed, 46 insertions(+), 0 deletions(-)
>
> diff --git a/arch/arm64/boot/dts/marvell/armada-3720-db.dts b/arch/arm64/boot/dts/marvell/armada-3720-db.dts
> index 1372e9a6aaa4..c8b82e4145de 100644
> --- a/arch/arm64/boot/dts/marvell/armada-3720-db.dts
> +++ b/arch/arm64/boot/dts/marvell/armada-3720-db.dts
> @@ -81,3 +81,26 @@
>  &pcie0 {
>         status = "okay";
>  };
> +
> +&mdio {
> +       status = "okay";
> +       phy0: ethernet-phy@0 {
> +               reg = <0>;
> +       };
> +
> +       phy1: ethernet-phy@1 {
> +               reg = <1>;
> +       };
> +};
> +
> +&eth0 {
> +       phy-mode = "rgmii-id";
> +       phy = <&phy0>;
> +       status = "okay";
> +};
> +
> +&eth1 {
> +       phy-mode = "rgmii-id";

Should be "sgmii".

Best regards,
Marcin
