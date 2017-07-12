From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net: hns: Bugfix for Tx timeout handling in hns
 driver
Date: Wed, 12 Jul 2017 08:22:52 -0700 (PDT)
Message-ID: <20170712.082252.1922543956027601076.davem@davemloft.net>
References: <1499857799-16124-1-git-send-email-linyunsheng@huawei.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: huangdaode@hisilicon.com, xuwei5@hisilicon.com,
        liguozhu@hisilicon.com, Yisen.Zhuang@huawei.com,
        gabriele.paoloni@huawei.com, john.garry@huawei.com,
        linuxarm@huawei.com, salil.mehta@huawei.com, lipeng321@huawei.com,
        tremyfr@gmail.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: linyunsheng@huawei.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1499857799-16124-1-git-send-email-linyunsheng@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Lin Yun Sheng <linyunsheng@huawei.com>
Date: Wed, 12 Jul 2017 19:09:59 +0800

> When hns port type is not debug mode, netif_tx_disable is called
> when there is a tx timeout, which requires system reboot to return
> to normal state. This patch fix this problem by resetting the net
> dev.
> 
> Fixes: b5996f11ea54 ("net: add Hisilicon Network Subsystem basic ethernet support")
> Signed-off-by: Lin Yun Sheng <linyunsheng@huawei.com>

Apaplied.
