From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Subject: Re: [patch 01/26] list_for_each: net-ipv6-ip6_fib.c
Date: Mon, 07 Mar 2005 01:40:40 +0900 (JST)
Message-ID: <20050307.014040.48352532.yoshfuji@linux-ipv6.org>
References: <20050306103238.86F181E46E@trashy.coderock.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, netdev@oss.sgi.com, janitor@sternwelten.at,
        yoshfuji@linux-ipv6.org
To: domen@coderock.org
In-Reply-To: <20050306103238.86F181E46E@trashy.coderock.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <20050306103238.86F181E46E@trashy.coderock.org> (at Sun, 06 Mar 2005 11:32:38 +0100), domen@coderock.org says:

> s/for/list_for_each/
> Compile tested.
:
> +++ kj-domen/net/ipv6/ip6_fib.c	2005-03-05 16:09:09.000000000 +0100
> @@ -99,7 +99,7 @@ struct fib6_walker_t fib6_walker_list = 
>  	.next	= &fib6_walker_list, 
>  };
>  
> -#define FOR_WALKERS(w) for ((w)=fib6_walker_list.next; (w) != &fib6_walker_list; (w)=(w)->next)
> +#define FOR_WALKERS(w) list_for_each((w), &fib6_walker_list)
>  
>  static __inline__ u32 fib6_new_sernum(void)
>  {

Please don't. fib6_walker_list is not for fib6_walker_t but list_head.
(Or, why don't you convert fib6_walker_t to use list_head families?)

--yoshfuji
