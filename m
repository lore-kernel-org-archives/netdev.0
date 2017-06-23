From: Yunsheng Lin <linyunsheng@huawei.com>
Subject: Re: [PATCH NET v2 0/2] Add loopback support in phy_driver and hns
 ethtool fix
Date: Fri, 23 Jun 2017 16:18:53 +0800
Message-ID: <2c145fde-eb2a-a3e6-4c3e-53b3c00ee830@huawei.com>
References: <1498204473-194648-1-git-send-email-linyunsheng@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <liguozhu@hisilicon.com>, <linuxarm@huawei.com>,
        <linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>,
        <tremyfr@gmail.com>
To: <davem@davemloft.net>, <andrew@lunn.ch>, <f.fainelli@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1498204473-194648-1-git-send-email-linyunsheng@huawei.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

My apology, this patch set have a bug in hns mac driver which is not
calling phy_loopback enable and disable in pair, I will send a v3 to
fix it. Please ignore this patch set.

Best Regards
Yunsheng Lin

On 2017/6/23 15:54, Lin Yun Sheng wrote:
> This Patch Set add set_loopback in phy_driver and use it to setup loopback
> when doing ethtool phy self_test.
> 
> Patch V2:
> 	1. Add phy_loopback in phy_device.c.
> 	2. Do error checking and do the read and write once in genphy_loopback.
> 	3. Remove gen10g_loopback in phy_device.c.
> 
> Patch V1: Initial Submit
> 
> Lin Yun Sheng (2):
>   net: phy: Add phy loopback support in net phy framework
>   net: hns: Use phy_driver to setup Phy loopback
> 
>  drivers/net/ethernet/hisilicon/hns/hns_ethtool.c | 68 +++++-------------------
>  drivers/net/phy/marvell.c                        |  1 +
>  drivers/net/phy/phy_device.c                     | 41 ++++++++++++++
>  include/linux/phy.h                              |  5 ++
>  4 files changed, 61 insertions(+), 54 deletions(-)
> 
