From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH RESEND v2 net-next] net: hisilicon: updates HNS config and documents
Date: Mon, 02 Nov 2015 23:05:59 +0100
Message-ID: <4387413.QS6YM6BNWK@wuerfel>
References: <1445944594-244149-1-git-send-email-huangdaode@hisilicon.com> <56341C00.8080303@hisilicon.com> <563424EB.1060804@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: Salil Mehta <salil.mehta@huawei.com>,
	huangdaode <huangdaode@hisilicon.com>, mark.rutland@arm.com,
	devicetree@vger.kernel.org, Yisen.Zhuang@huawei.com,
	kenneth-lee-2012@foxmail.com, pawel.moll@arm.com,
	ijc+devicetree@hellion.org.uk, catalin.marinas@arm.com,
	lipeng321@huawei.com, will.deacon@arm.com,
	linux-kernel@vger.kernel.org, xuwei5@hisilicon.com,
	linuxarm@huawei.com, robh+dt@kernel.org, galak@codeaurora.org,
	lisheng011@huawei.com, netdev@vger.kernel.org,
	liguozhu@hisilicon.com, davem@davemloft.net
To: linux-arm-kernel@lists.infradead.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <563424EB.1060804@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Saturday 31 October 2015 02:18:19 Salil Mehta wrote:
> On 10/31/2015 1:40 AM, huangdaode wrote:
> > On 2015/10/30 22:20, Arnd Bergmann wrote:
> >> On Tuesday 27 October 2015 19:16:34 huangdaode wrote:
> >>>            mdio@803c0000 {
> >>>                      #address-cells = <1>;
> >>>                      #size-cells = <0>;
> >>> -                   compatible = "hisilicon,mdio","hisilicon,hns-mdio";
> >>> +                   compatible = "hisilicon,hns-mdio","hisilicon,mdio";
> >>>                      reg = <0x0 0x803c0000 0x0 0x10000>;
> >>>
> >> Does "hisilicon,mdio" actually have a specific meaning? Is that just 
> >> there
> >> for legacy reasons?
> >>
> >>     Arnd
> >>
> >> .
> >>
> > hi Arnd,
> > "hisilicon,mdio" is  the gernerical configuation compatible  for the 
> > default hisilicon chip,
> > We use generic hisilicon since our MDIO/PHY is same across flavour of 
> > SoCs.
> >
> Hi Arnd,
> Yes, "hisilicon,mdio" exists for the legacy reasons to support older SoC 
> Hip04.

I see. In that case, that compatible string should probably be mentioned
only as 'optional' in the binding, and not used for devices other than
hip04.

	Arnd
