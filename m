From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH] net: hisilicon: fix binding document of mdio
Date: Fri, 13 Nov 2015 17:44:15 +0100
Message-ID: <4637718.UGnlN7fHno@wuerfel>
References: <1447381424-107248-1-git-send-email-huangdaode@hisilicon.com> <20151113144457.GA18563@rob-hp-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: huangdaode <huangdaode@hisilicon.com>, davem@davemloft.net,
	pawel.moll@arm.com, mark.rutland@arm.com,
	ijc+devicetree@hellion.org.uk, galak@codeaurora.org,
	liguozhu@hisilicon.com, Yisen.Zhuang@huawei.com,
	dingtianhong@huawei.com, zhangfei.gao@linaro.org,
	devicetree@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org,
	linuxarm@huawei.com, salil.mehta@huawei.com,
	kenneth-lee-2012@foxmail.com, xuwei5@hisilicon.com,
	lisheng011@huawei.com
To: Rob Herring <robh@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20151113144457.GA18563@rob-hp-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Friday 13 November 2015 08:44:57 Rob Herring wrote:
> 
> Please reformat like this:
> 
> - compatible: can be one of:
>         "hisilicon,hns-mdio"
>         "hisilicon,mdio"
>   For hip04 board, must be "hisilicon,mdio".
>   Otherwise, must be "hisilicon,hns-mdio".

should we recommend the use of "hisilicon,hns-mdio" unconditionally
and only list "hisilicon,mdio" for backwards compatibility?

	Arnd
