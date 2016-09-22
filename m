From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] net: ethernet: hisilicon: hns: use phydev from
 struct net_device
Date: Thu, 22 Sep 2016 02:12:02 -0400 (EDT)
Message-ID: <20160922.021202.1167465769111094114.davem@davemloft.net>
References: <1474403412-18748-1-git-send-email-tremyfr@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yisen.zhuang@huawei.com, salil.mehta@huawei.com,
        yankejian@huawei.com, huangdaode@hisilicon.com,
        lisheng011@huawei.com, xieqianqian@huawei.com, arnd@arndb.de,
        lipeng321@huawei.com, andrew@lunn.ch, chenny.xu@huawei.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: tremyfr@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1474403412-18748-1-git-send-email-tremyfr@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Philippe Reynes <tremyfr@gmail.com>
Date: Tue, 20 Sep 2016 22:30:11 +0200

> The private structure contain a pointer to phydev, but the structure
> net_device already contain such pointer. So we can remove the pointer
> phydev in the private structure, and update the driver to use the
> one contained in struct net_device.
> 
> Signed-off-by: Philippe Reynes <tremyfr@gmail.com>

Applied.
