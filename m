From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: hns3: Fixes the wrong IS_ERR check on
 the returned phydev value
Date: Wed, 30 Aug 2017 15:30:07 -0700 (PDT)
Message-ID: <20170830.153007.110092081024877123.davem@davemloft.net>
References: <20170830110603.12372-1-salil.mehta@huawei.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yisen.zhuang@huawei.com, mehta.salil.lnk@gmail.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        linuxarm@huawei.com
To: salil.mehta@huawei.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170830110603.12372-1-salil.mehta@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Salil Mehta <salil.mehta@huawei.com>
Date: Wed, 30 Aug 2017 12:06:03 +0100

> This patch removes the wrong check being done for the phy device being
> returned by the mdiobus_get_phy() function. This function never returns
> the error pointers.
> 
> Fixes: 256727da7395 ("net: hns3: Add MDIO support to HNS3 Ethernet
> Driver for hip08 SoC")
> Reported-by: Dan Carpenter <dan.carpenter@oracle.com>
> Signed-off-by: Salil Mehta <salil.mehta@huawei.com>

Applied.
