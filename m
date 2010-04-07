From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: Re: linux-next: Tree for April 7 (net/core/dev_addr_lists)
Date: Wed, 7 Apr 2010 10:50:49 -0700
Message-ID: <20100407105049.0f812b27.randy.dunlap@oracle.com>
References: <20100407174123.81b32310.sfr@canb.auug.org.au>
	<20100407095845.f29ebf48.randy.dunlap@oracle.com>
	<1270661889.8141.45.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Stephen Rothwell <sfr@canb.auug.org.au>,
	netdev <netdev@vger.kernel.org>, linux-next@vger.kernel.org,
	LKML <linux-kernel@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <1270661889.8141.45.camel@edumazet-laptop>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 07 Apr 2010 19:38:09 +0200 Eric Dumazet wrote:

> [PATCH net-next-2.6] net: include linux/proc_fs.h in dev_addr_lists.c
> 
> As pointed by Randy Dunlap, we must include linux/proc_fs.h in
> net/core/dev_addr_lists.c, regardless of CONFIG_PROC_FS
> 
> Reported-by: Randy Dunlap <randy.dunlap@oracle.com>, 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Acked-by: Randy Dunlap <randy.dunlap@oracle.com>

Thanks, Eric.


> ---
> diff --git a/net/core/dev_addr_lists.c b/net/core/dev_addr_lists.c
> index 37d5975..508f9c1 100644
> --- a/net/core/dev_addr_lists.c
> +++ b/net/core/dev_addr_lists.c
> @@ -14,6 +14,7 @@
>  #include <linux/netdevice.h>
>  #include <linux/rtnetlink.h>
>  #include <linux/list.h>
> +#include <linux/proc_fs.h>
>  
>  /*
>   * General list handling functions
> @@ -667,7 +668,6 @@ void dev_mc_init(struct net_device *dev)
>  EXPORT_SYMBOL(dev_mc_init);
>  
>  #ifdef CONFIG_PROC_FS
> -#include <linux/proc_fs.h>
>  #include <linux/seq_file.h>
>  
>  static int dev_mc_seq_show(struct seq_file *seq, void *v)
> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html


---
~Randy
