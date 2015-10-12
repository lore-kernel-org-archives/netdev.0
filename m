From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: HNS: fix MDIO dependencies
Date: Mon, 12 Oct 2015 05:41:38 -0700 (PDT)
Message-ID: <20151012.054138.644534181826942617.davem@davemloft.net>
References: <8114651.XErShuFr2W@wuerfel>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Yisen.Zhuang@huawei.com,
	liguozhu@huawei.com, huangdaode@hisilicon.com,
	zhangfei.gao@linaro.org, linux-kernel@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org
To: arnd@arndb.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <8114651.XErShuFr2W@wuerfel>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Arnd Bergmann <arnd@arndb.de>
Date: Fri, 09 Oct 2015 14:53:54 +0200

> The newly introduced HNS_MDIO Kconfig symbol selects 'MDIO', but
> that is the wrong symbol as the code used by this driver is
> provided by PHYLIB rather than the MDIO driver. Also, there is
> no need to make this driver user selectable, because it is already
> selected by all drivers that need it.
> 
> This changes the Kconfig file to select the correct library, and
> to make the option silent.
> 
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>
> Fixes: 5b904d39406 ("net: add Hisilicon Network Subsystem MDIO support")

Applied, thanks.
