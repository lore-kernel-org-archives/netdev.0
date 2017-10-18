From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next] net: sched: cls_u32: use hash_ptr() for
 tc_u_hash
Date: Wed, 18 Oct 2017 10:39:29 +0200
Message-ID: <20171018083929.GE2028@nanopsycho>
References: <20171018083403.3236142-1-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jamal Hadi Salim <jhs@mojatatu.com>,
        Cong Wang <xiyou.wangcong@gmail.com>,
        "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20171018083403.3236142-1-arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Wed, Oct 18, 2017 at 10:33:37AM CEST, arnd@arndb.de wrote:
>After the change to the tp hash, we now get a build warning
>on 32-bit architectures:
>
>net/sched/cls_u32.c: In function 'tc_u_hash':
>net/sched/cls_u32.c:338:17: error: cast from pointer to integer of different size [-Werror=pointer-to-int-cast]
>  return hash_64((u64) tp->chain->block, U32_HASH_SHIFT);
>
>Using hash_ptr() instead of hash_64() lets us drop the cast
>and fixes the warning while still resulting in the same hash
>value.
>
>Fixes: 7fa9d974f3c2 ("net: sched: cls_u32: use block instead of q in tc_u_common")
>Signed-off-by: Arnd Bergmann <arnd@arndb.de>

Acked-by: Jiri Pirko <jiri@mellanox.com>

Thanks.
