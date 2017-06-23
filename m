From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH NET 2/2] net: hns: Use phy_driver to setup Phy loopback
Date: Fri, 23 Jun 2017 06:05:44 +0200
Message-ID: <20170623040544.GC5432@lunn.ch>
References: <1498121613-64572-1-git-send-email-linyunsheng@huawei.com>
 <20170623032011.GB5432@lunn.ch>
 <d4130f27-6373-b909-e23f-4c26520a9093@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, f.fainelli@gmail.com,
        huangdaode@hisilicon.com, xuwei5@hisilicon.com,
        liguozhu@hisilicon.com, Yisen.Zhuang@huawei.com,
        gabriele.paoloni@huawei.com, john.garry@huawei.com,
        linuxarm@huawei.com, salil.mehta@huawei.com, lipeng321@huawei.com,
        tremyfr@gmail.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Yunsheng Lin <linyunsheng@huawei.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <d4130f27-6373-b909-e23f-4c26520a9093@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> what should the Mac driver do when it receive the error? I assume that it
> will return it to userspace. because the rtnl_lock ensure only one ethtool
> is executing, if the function return error, it means some bug in the mac
> driver, am I right?

Yes, return it. It could be there are other use cases of loopback,
which are not protected by the rtnl_lock.

      Andrew
