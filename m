From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH RESEND v2 net-next] net: hisilicon: updates HNS config and documents
Date: Fri, 30 Oct 2015 15:20:18 +0100
Message-ID: <4549013.K7sn8Pca5b@wuerfel>
References: <1445944594-244149-1-git-send-email-huangdaode@hisilicon.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: davem@davemloft.net, robh+dt@kernel.org, pawel.moll@arm.com,
	mark.rutland@arm.com, ijc+devicetree@hellion.org.uk,
	galak@codeaurora.org, catalin.marinas@arm.com, will.deacon@arm.com,
	devicetree@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org, liguozhu@hisilicon.com,
	Yisen.Zhuang@huawei.com, netdev@vger.kernel.org,
	linuxarm@huawei.com, salil.mehta@huawei.com,
	kenneth-lee-2012@foxmail.com, xuwei5@hisilicon.com,
	lisheng011@huawei.com, lipeng321@huawei.com
To: huangdaode <huangdaode@hisilicon.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1445944594-244149-1-git-send-email-huangdaode@hisilicon.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tuesday 27 October 2015 19:16:34 huangdaode wrote:
>           mdio@803c0000 {
>                     #address-cells = <1>;
>                     #size-cells = <0>;
> -                   compatible = "hisilicon,mdio","hisilicon,hns-mdio";
> +                   compatible = "hisilicon,hns-mdio","hisilicon,mdio";
>                     reg = <0x0 0x803c0000 0x0 0x10000>;
>  
> 

Does "hisilicon,mdio" actually have a specific meaning? Is that just there
for legacy reasons?

	Arnd
