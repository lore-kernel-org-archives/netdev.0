From: David Miller <davem@davemloft.net>
Subject: Re: linux-next: build failure after merge of the final tree
 (net-next tree related)
Date: Wed, 14 Dec 2011 13:35:56 -0500 (EST)
Message-ID: <20111214.133556.1607219773146640400.davem@davemloft.net>
References: <20111214180752.7893d5460c6fca84d63cab0e@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-next@vger.kernel.org,
	linux-kernel@vger.kernel.org, glommer@parallels.com, tj@kernel.org,
	akpm@linux-foundation.org
To: sfr@canb.auug.org.au
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20111214180752.7893d5460c6fca84d63cab0e@canb.auug.org.au>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Rothwell <sfr@canb.auug.org.au>
Date: Wed, 14 Dec 2011 18:07:52 +1100

> After merging the final tree, today's linux-next build (powerpc
> allnoconfig) failed like this:
> 
> In file included from include/linux/tcp.h:211:0,
>                  from include/linux/ipv6.h:221,
>                  from include/net/ipv6.h:16,
>                  from include/linux/sunrpc/clnt.h:26,
>                  from include/linux/nfs_fs.h:50,
>                  from init/do_mounts.c:20:
> include/net/sock.h: In function 'memcg_memory_allocated_add':
> include/net/sock.h:1000:20: error: 'OVER_LIMIT' undeclared (first use in this function)
> 
> And several other similar ones.
> 
> Caused by commit e1aab161e013 ("socket: initial cgroup code") from the
> net-next tree. OVER_LIMIT is only defined it CONFIG_INET is set.
> 
> I applied the following (stupid) patch for today (just because reverting
> the above commit would probably be too hard - we have cgroup stuff all
> over the place :-( ):

Glauber, please fix this properly.
