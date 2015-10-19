From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: hisilicon: include linux/vmalloc.h in dsaf
Date: Sun, 18 Oct 2015 19:59:13 -0700 (PDT)
Message-ID: <20151018.195913.1990635897175690354.davem@davemloft.net>
References: <1444967657-107994-1-git-send-email-huangdaode@hisilicon.com>
	<4903569.oS7BSflIyn@wuerfel>
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
In-Reply-To: <4903569.oS7BSflIyn@wuerfel>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Arnd Bergmann <arnd@arndb.de>
Date: Fri, 16 Oct 2015 11:30:56 +0200

> Some configurations fail to build the hns dsaf code because of
> a missing header file:
> 
> ethernet/hisilicon/hns/hns_dsaf_main.c: In function 'hns_dsaf_init':
> ethernet/hisilicon/hns/hns_dsaf_main.c:1096:2: error: implicit declaration of function 'vzalloc' [-Werror=implicit-function-declaration]
>   priv->soft_mac_tbl = vzalloc(sizeof(*priv->soft_mac_tbl)
> 
> This adds the correct #include.
> 
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>

Applied, thank you.
