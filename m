From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 0/4] net: hix5hd2_gmac: add tx sg feature and
 reset/clock control signals
Date: Tue, 06 Dec 2016 10:21:54 -0500 (EST)
Message-ID: <20161206.102154.1118935347030938372.davem@davemloft.net>
References: <1480944481-118803-1-git-send-email-lidongpo@hisilicon.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: robh+dt@kernel.org, mark.rutland@arm.com, mturquette@baylibre.com,
        sboyd@codeaurora.org, linux@armlinux.org.uk,
        zhangfei.gao@linaro.org, yisen.zhuang@huawei.com,
        salil.mehta@huawei.com, arnd@arndb.de, andrew@lunn.ch,
        xuejiancheng@hisilicon.com, benjamin.chenhao@hisilicon.com,
        caizhiyong@hisilicon.com, netdev@vger.kernel.org,
        devicetree@vger.kernel.org, linux-kernel@vger.kernel.org
To: lidongpo@hisilicon.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1480944481-118803-1-git-send-email-lidongpo@hisilicon.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Dongpo Li <lidongpo@hisilicon.com>
Date: Mon, 5 Dec 2016 21:27:57 +0800

> The "hix5hd2" is SoC name, add the generic ethernet driver compatible string.
> The "hisi-gemac-v1" is the basic version and "hisi-gemac-v2" adds
> the SG/TXCSUM/TSO/UFO features.
> This patch set only adds the SG(scatter-gather) driver for transmitting,
> the drivers of other features will be submitted later.
> 
> Add the MAC reset control signals and clock signals.
> We make these signals optional to be backward compatible with
> the hix5hd2 SoC.
> 
> Changes in v2:
> - Make the compatible string changes be a separate patch and
> the most specific string come first than the generic string
> as advised by Rob.
> - Make the MAC reset control signals and clock signals optional
> to be backward compatible with the hix5hd2 SoC.
> - Change the compatible string and give the clock a specific name
> in hix5hd2 dts file.

Series applied to net-next, thanks.
