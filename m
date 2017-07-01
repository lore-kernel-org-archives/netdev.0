From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH NET V5 2/2] net: hns: Use phy_driver to setup Phy loopback
Date: Sat, 1 Jul 2017 17:17:07 +0200
Message-ID: <20170701151707.GA5859@lunn.ch>
References: <1498443039-134503-3-git-send-email-linyunsheng@huawei.com>
 <20170626134235.GC2623@lunn.ch>
 <17132762-9b94-bc32-fee8-e90a6db5762a@huawei.com>
 <20170627132958.GA9921@lunn.ch>
 <3d382bc6-f7b6-9df3-8bb0-fee55b72ac74@huawei.com>
 <20170628202819.GA22815@lunn.ch>
 <1bff07ed-d423-dfa2-61e3-3f35c4536632@huawei.com>
 <20170629135648.GD9244@lunn.ch>
 <e53994a8-25df-a7dc-cbf0-cbc4063e734c@huawei.com>
 <20170630133915.GD17212@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem <davem@davemloft.net>, "f.fainelli" <f.fainelli@gmail.com>,
        huangdaode <huangdaode@hisilicon.com>,
        "xuwei (O)" <xuwei5@hisilicon.com>,
        "Liguozhu (Kenneth)" <liguozhu@hisilicon.com>,
        "Zhuangyuzeng (Yisen)" <yisen.zhuang@huawei.com>,
        Gabriele Paoloni <gabriele.paoloni@huawei.com>,
        John Garry <john.garry@huawei.com>,
        Linuxarm <linuxarm@huawei.com>,
        Salil Mehta <salil.mehta@huawei.com>,
        "lipeng (Y)" <lipeng321@huawei.com>, tremyfr <tremyfr@gmail.com>,
        netdev <netdev@vger.kernel.org>,
        linux-kernel <linux-kernel@vger.kernel.org>
To: linyunsheng <linyunsheng@huawei.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Jul 01, 2017 at 11:57:32AM +0000, linyunsheng wrote:
> Hi, Andrew
> 
> I am agreed wih you on this.
> But self test is also a feature of our product, and our
> customer way choose to diagnose a problem using
> self test, even if self test does not give a clear
> reason to the problem.
> we don't want to remove a feature that we don't
> know when our customer will be using.

Far enough. So please take a close look at the code and try to fix
it. The corner cases are your problem, a down'ed interface, WOL, etc.
It is issues like this which can result in phy_resume() being called
without there first being a phy_suspend.

	Andrew
