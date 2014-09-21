From: YOSHIFUJI Hideaki <hideaki@yoshifuji.org>
Subject: Re: [PATCH net-next 1/8] ipv6: support for fib6_clean_* to update
 fn_sernum
Date: Sun, 21 Sep 2014 11:07:37 +0900
Message-ID: <541E32E9.2040409@yoshifuji.org>
References: <cover.1411249633.git.hannes@stressinduktion.org> <d63a1ee6a3dee0d2a08f38e1e8a11a120b6ce3f5.1411249633.git.hannes@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, vyasevich@gmail.com,
	nicolas.dichtel@6wind.com, kafai@fb.com,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 94.43.138.210.xn.2iij.net ([210.138.43.94]:48664 "EHLO
	mail.st-paulia.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751704AbaIUCP1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 20 Sep 2014 22:15:27 -0400
In-Reply-To: <d63a1ee6a3dee0d2a08f38e1e8a11a120b6ce3f5.1411249633.git.hannes@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Hannes Frederic Sowa wrote:

> @@ -71,7 +72,8 @@ static DEFINE_RWLOCK(fib6_walker_lock);
>  #define FWS_INIT FWS_L
>  #endif
>  
> -static void fib6_prune_clones(struct net *net, struct fib6_node *fn);
> +static void fib6_prune_clones(struct net *net, struct fib6_node *fn,
> +			      u32 sernum);
>  static struct rt6_info *fib6_find_prefix(struct net *net, struct fib6_node *fn);
>  static struct fib6_node *fib6_repair_tree(struct net *net, struct fib6_node *fn);
>  static int fib6_walk(struct fib6_walker_t *w);
> @@ -84,7 +86,7 @@ static int fib6_walk_continue(struct fib6_walker_t *w);
>   *	result of redirects, path MTU changes, etc.
>   */
>  
> -static __u32 rt_sernum;
> +static u32 rt_sernum;
>  
>  static void fib6_gc_timer_cb(unsigned long arg);
>  

I don't think you do really convert __u32 to u32
in this series.

--yoshfuji
