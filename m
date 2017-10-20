From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: sched: cls_u32: use hash_ptr() for
 tc_u_hash
Date: Fri, 20 Oct 2017 08:36:23 +0100 (WEST)
Message-ID: <20171020.083623.347659428573746599.davem@davemloft.net>
References: <20171018083403.3236142-1-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jhs@mojatatu.com, xiyou.wangcong@gmail.com, jiri@resnulli.us,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: arnd@arndb.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20171018083403.3236142-1-arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Arnd Bergmann <arnd@arndb.de>
Date: Wed, 18 Oct 2017 10:33:37 +0200

> After the change to the tp hash, we now get a build warning
> on 32-bit architectures:
> 
> net/sched/cls_u32.c: In function 'tc_u_hash':
> net/sched/cls_u32.c:338:17: error: cast from pointer to integer of different size [-Werror=pointer-to-int-cast]
>   return hash_64((u64) tp->chain->block, U32_HASH_SHIFT);
> 
> Using hash_ptr() instead of hash_64() lets us drop the cast
> and fixes the warning while still resulting in the same hash
> value.
> 
> Fixes: 7fa9d974f3c2 ("net: sched: cls_u32: use block instead of q in tc_u_common")
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>

Applied.
