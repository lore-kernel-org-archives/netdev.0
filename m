From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH V2 net] net: hns: Fix the device being used for dma
 mapping during TX
Date: Fri, 10 Feb 2017 13:40:53 -0500 (EST)
Message-ID: <20170210.134053.1587518147779422167.davem@davemloft.net>
References: <20170209114615.179560-1-salil.mehta@huawei.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yisen.zhuang@huawei.com, mehta.salil.lnk@gmail.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        linuxarm@huawei.com, yankejian@huawei.com
To: salil.mehta@huawei.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170209114615.179560-1-salil.mehta@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Salil Mehta <salil.mehta@huawei.com>
Date: Thu, 9 Feb 2017 11:46:15 +0000

> From: Kejian Yan <yankejian@huawei.com>
> 
> This patch fixes the device being used to DMA map skb->data.
> Erroneous device assignment causes the crash when SMMU is enabled.
> This happens during TX since buffer gets DMA mapped with device
> correspondign to net_device and gets unmapped using the device
> related to DSAF.
> 
> Signed-off-by: Kejian Yan <yankejian@huawei.com>
> Reviewed-by: Yisen Zhuang <yisen.zhuang@huawei.com>
> Signed-off-by: Salil Mehta <salil.mehta@huawei.com>

Applied, thank you.
