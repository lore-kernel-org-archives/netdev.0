From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] hns3: fix unused function warning
Date: Mon, 07 Aug 2017 11:24:00 -0700 (PDT)
Message-ID: <20170807.112400.1912794700598730100.davem@davemloft.net>
References: <20170807104230.3564976-1-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yisen.zhuang@huawei.com, salil.mehta@huawei.com,
        xavier.huwei@huawei.com, lipeng321@huawei.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: arnd@arndb.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170807104230.3564976-1-arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Arnd Bergmann <arnd@arndb.de>
Date: Mon,  7 Aug 2017 12:41:53 +0200

> Without CONFIG_PCI_IOV, we get a harmless warning about an
> unused function:
> 
> drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_main.c:2273:13: error: 'hclge_disable_sriov' defined but not used [-Werror=unused-function]
> 
> The #ifdefs in this driver are obviously wrong, so this just
> removes them and uses an IS_ENABLED() check that does the same
> thing correctly in a more readable way.
> 
> Fixes: 46a3df9f9718 ("net: hns3: Add HNS3 Acceleration Engine & Compatibility Layer Support")
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>

Applied.
