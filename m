From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Subject: Re: [patch 01/26] list_for_each: net-ipv6-ip6_fib.c
Date: Mon, 07 Mar 2005 06:00:38 +0900 (JST)
Message-ID: <20050307.060038.16434779.yoshfuji@linux-ipv6.org>
References: <20050306103238.86F181E46E@trashy.coderock.org>
	<20050307.014040.48352532.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, netdev@oss.sgi.com, janitor@sternwelten.at,
        yoshfuji@linux-ipv6.org
To: domen@coderock.org
In-Reply-To: <20050307.014040.48352532.yoshfuji@linux-ipv6.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <20050307.014040.48352532.yoshfuji@linux-ipv6.org> (at Mon, 07 Mar 2005 01:40:40 +0900 (JST)), YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@linux-ipv6.org> says:

> >  
> > -#define FOR_WALKERS(w) for ((w)=fib6_walker_list.next; (w) != &fib6_walker_list; (w)=(w)->next)
> > +#define FOR_WALKERS(w) list_for_each((w), &fib6_walker_list)
> >  
> >  static __inline__ u32 fib6_new_sernum(void)
> >  {
>
> Please don't. fib6_walker_list is not for fib6_walker_t but list_head.

Sorry, I meant: list_for_each is not for fib6_walker_t but list_head.

--yoshfuji
