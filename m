From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] [net-next] hns_enet: use cpumask_var_t for on-stack
 mask
Date: Fri, 03 Feb 2017 11:15:10 -0500 (EST)
Message-ID: <20170203.111510.2124248517173679920.davem@davemloft.net>
References: <20170202145017.3761604-1-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yisen.zhuang@huawei.com, salil.mehta@huawei.com,
        yankejian@huawei.com, huangdaode@hisilicon.com,
        xieqianqian@huawei.com, lisheng011@huawei.com,
        lipeng321@huawei.com, tremyfr@gmail.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: arnd@arndb.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170202145017.3761604-1-arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Arnd Bergmann <arnd@arndb.de>
Date: Thu,  2 Feb 2017 15:49:24 +0100

> On large SMP builds, we can run into a build warning:
> 
> drivers/net/ethernet/hisilicon/hns/hns_enet.c: In function 'hns_set_irq_affinity.isra.27':
> drivers/net/ethernet/hisilicon/hns/hns_enet.c:1242:1: warning: the frame size of 1032 bytes is larger than 1024 bytes [-Wframe-larger-than=]
> 
> The solution here is to use cpumask_var_t, which can use dynamic
> allocation when CONFIG_CPUMASK_OFFSTACK is enabled.
> 
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>

Applied, thanks Arnd.
