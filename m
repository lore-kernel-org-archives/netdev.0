From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 4/5] net_sched: fix use of uninitialized ethertype
 variable in cls_flower
Date: Mon, 29 Aug 2016 00:30:56 -0400 (EDT)
Message-ID: <20160829.003056.872235296198766893.davem@davemloft.net>
References: <20160826152546.604384-1-arnd@arndb.de>
        <20160826152546.604384-5-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, torvalds@linux-foundation.org,
        hadarh@mellanox.com, jiri@mellanox.com, netdev@vger.kernel.org
To: arnd@arndb.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160826152546.604384-5-arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Arnd Bergmann <arnd@arndb.de>
Date: Fri, 26 Aug 2016 17:25:45 +0200

> The addition of VLAN support caused a possible use of uninitialized
> data if we encounter a zero TCA_FLOWER_KEY_ETH_TYPE key, as pointed
> out by "gcc -Wmaybe-uninitialized":
> 
> net/sched/cls_flower.c: In function 'fl_change':
> net/sched/cls_flower.c:366:22: error: 'ethertype' may be used uninitialized in this function [-Werror=maybe-uninitialized]
> 
> This changes the code to only set the ethertype field if it
> was nonzero, as before the patch.
> 
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>
> Fixes: 9399ae9a6cb2 ("net_sched: flower: Add vlan support")

Applied.
