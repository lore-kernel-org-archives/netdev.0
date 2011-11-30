From: David Miller <davem@davemloft.net>
Subject: Re: 3.2.0-rc3+ (Linus git -
 883381d9f1c5a6329bbb796e23ae52c939940310) - INFO: suspicious RCU usage
Date: Wed, 30 Nov 2011 17:24:46 -0500 (EST)
Message-ID: <20111130.172446.1238507297139601019.davem@davemloft.net>
References: <CAHFgRy-hAMF344eChZ9tLnFB7qUS_v3m0LvtBKWjbFmBeeASsA@mail.gmail.com>
	<1322632602.23721.0.camel@edumazet-laptop>
	<1322633155.23721.5.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: miles.lane@gmail.com, linux-kernel@vger.kernel.org,
	kuznet@ms2.inr.ac.ru, dipankar@in.ibm.com,
	paulmck@linux.vnet.ibm.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1322633155.23721.5.camel@edumazet-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 30 Nov 2011 07:05:55 +0100

> [PATCH] ipv4: fix lockdep splat in rt_cache_seq_show
> 
> After commit f2c31e32b378 (fix NULL dereferences in check_peer_redir()),
> dst_get_neighbour() should be guarded by rcu_read_lock() /
> rcu_read_unlock() section.
> 
> Reported-by: Miles Lane <miles.lane@gmail.com>
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied, thanks Eric.
