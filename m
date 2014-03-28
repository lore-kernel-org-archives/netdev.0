From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH net-next v2 3/3] ipv6: fix checkpatch errors of "foo*"
 and "foo * bar"
Date: Thu, 27 Mar 2014 21:22:01 -0700
Message-ID: <1395980521.19009.8.camel@joe-AO722>
References: <1395979624-8544-1-git-send-email-wangyufen@huawei.com>
	 <1395979624-8544-4-git-send-email-wangyufen@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Wangyufen <wangyufen@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0096.hostedemail.com ([216.40.44.96]:60797 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751057AbaC1EWF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Mar 2014 00:22:05 -0400
In-Reply-To: <1395979624-8544-4-git-send-email-wangyufen@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2014-03-28 at 12:07 +0800, Wangyufen wrote:
[]
> diff --git a/net/ipv6/ip6_fib.c b/net/ipv6/ip6_fib.c
[]
> @@ -143,7 +143,7 @@ static __inline__ __be32 addr_bit_set(const void *token, int fn_bit)
>  	       addr[fn_bit >> 5];
>  }

Perhaps all the __inline__ uses could be changed to inline too.

> -static __inline__ struct fib6_node * node_alloc(void)
> +static __inline__ struct fib6_node *node_alloc(void)
>  {
>  	struct fib6_node *fn;
>  
> @@ -152,7 +152,7 @@ static __inline__ struct fib6_node * node_alloc(void)
>  	return fn;
>  }
>  
> -static __inline__ void node_free(struct fib6_node * fn)
> +static __inline__ void node_free(struct fib6_node *fn)
>  {
>  	kmem_cache_free(fib6_node_kmem, fn);
>  }
