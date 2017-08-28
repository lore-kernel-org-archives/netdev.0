From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v2 1/4] net: mvpp2: fix the mac address used when
 using PPv2.2
Date: Mon, 28 Aug 2017 11:25:51 -0700 (PDT)
Message-ID: <20170828.112551.201104088584393782.davem@davemloft.net>
References: <20170825141420.14027-1-antoine.tenart@free-electrons.com>
        <20170825141420.14027-2-antoine.tenart@free-electrons.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: thomas.petazzoni@free-electrons.com, andrew@lunn.ch,
        gregory.clement@free-electrons.com, nadavh@marvell.com,
        linux@armlinux.org.uk, linux-kernel@vger.kernel.org,
        mw@semihalf.com, stefanc@marvell.com, netdev@vger.kernel.org
To: antoine.tenart@free-electrons.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170825141420.14027-2-antoine.tenart@free-electrons.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Antoine Tenart <antoine.tenart@free-electrons.com>
Date: Fri, 25 Aug 2017 16:14:17 +0200

> The mac address is only retrieved from h/w when using PPv2.1. Otherwise
> the variable holding it is still checked and used if it contains a valid
> value. As the variable isn't initialized to an invalid mac address
> value, we end up with random mac addresses which can be the same for all
> the ports handled by this PPv2 driver.
> 
> Fixes this by initializing the h/w mac address variable to {0}, which is
> an invalid mac address value. This way the random assignation fallback
> is called and all ports end up with their own addresses.
> 
> Signed-off-by: Antoine Tenart <antoine.tenart@free-electrons.com>
> Fixes: 2697582144dd ("net: mvpp2: handle misc PPv2.1/PPv2.2 differences")

Applied and queued up for -stable, thanks.
