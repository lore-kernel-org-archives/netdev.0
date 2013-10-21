From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: fix build warnings because of
 net_get_random_once merge
Date: Mon, 21 Oct 2013 16:27:29 -0400 (EDT)
Message-ID: <20131021.162729.2297054111992380683.davem@davemloft.net>
References: <20131020042602.GC27787@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: hannes@stressinduktion.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20131020042602.GC27787@order.stressinduktion.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Date: Sun, 20 Oct 2013 06:26:02 +0200

> This patch fixes the following warning:
> 
>    In file included from include/linux/skbuff.h:27:0,
>                     from include/linux/netfilter.h:5,
>                     from include/net/netns/netfilter.h:5,
>                     from include/net/net_namespace.h:20,
>                     from include/linux/init_task.h:14,
>                     from init/init_task.c:1:
> include/linux/net.h:243:14: warning: 'struct static_key' declared inside parameter list [enabled by default]
>           struct static_key *done_key);
> 
> on x86_64 allnoconfig, um defconfig and ia64 allmodconfig and maybe others as well.
> 
> Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>

Applied, thanks Hannes.
