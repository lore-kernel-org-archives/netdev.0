From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: hisilicon: add OF dependency
Date: Sun, 18 Oct 2015 20:01:37 -0700 (PDT)
Message-ID: <20151018.200137.982909998956019901.davem@davemloft.net>
References: <1444967657-107994-1-git-send-email-huangdaode@hisilicon.com>
	<4665385.OoIztz6y5m@wuerfel>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: huangdaode@hisilicon.com, joe@perches.com, liguozhu@hisilicon.com,
	Yisen.Zhuang@huawei.com, netdev@vger.kernel.org,
	linuxarm@huawei.com, salil.mehta@huawei.com,
	kenneth-lee-2012@foxmail.com, xuwei5@hisilicon.com,
	lisheng011@huawei.com, linux-kernel@vger.kernel.org,
	lipeng321@huawei.com
To: arnd@arndb.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4665385.OoIztz6y5m@wuerfel>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Arnd Bergmann <arnd@arndb.de>
Date: Fri, 16 Oct 2015 11:33:49 +0200

> The HNS MDIO driver fails to build on older ARM machines that are not
> yet converted to CONFIG_OF:
> 
> drivers/net/ethernet/hisilicon/hns_mdio.c: In function 'hns_mdio_bus_name':
> drivers/net/ethernet/hisilicon/hns_mdio.c:405:14: error: 'OF_BAD_ADDR' undeclared (first use in this function)
>   u64 taddr = OF_BAD_ADDR;
>               ^
> drivers/net/ethernet/hisilicon/hns_mdio.c:405:14: note: each undeclared identifier is reported only once for each function it appears in
> drivers/net/ethernet/hisilicon/hns_mdio.c:409:11: error: implicit declaration of function 'of_translate_address' [-Werror=implicit-function-declaration]
>    taddr = of_translate_address(np, addr);
>            ^
> 
> This clarifies the dependency to ensure we don't attempt to build these
> drivers without CONFIG_OF, but also adds a COMPILE_TEST alternative to
> give us better build coverage testing.
> 
> Build-tested on x86 as well to ensure this actually works.
> 
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>

Applied.
