From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] IPv6: simplify & condense a few declarations &
 statements
Date: Wed, 17 Apr 2013 13:28:18 -0400 (EDT)
Message-ID: <20130417.132818.1433580618679802344.davem@davemloft.net>
References: <1366219222.3504.8.camel@lizardlounge>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: n1ght.4nd.d4y@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1366219222.3504.8.camel@lizardlounge>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Nathaniel Yazdani <n1ght.4nd.d4y@gmail.com>
Date: Wed, 17 Apr 2013 10:20:22 -0700

> This patch combines several statements/declarations into more concise forms and removes a 
> couple of unnecessary local variables within a few functions, mostly inline.

Please make commit messages with 80 column long lines maximum.

> @@ -111,10 +111,7 @@ static inline void fib6_walker_unlink(struct fib6_walker_t *w)
>  }
>  static __inline__ u32 fib6_new_sernum(void)
>  {
> -	u32 n = ++rt_sernum;
> -	if ((__s32)n <= 0)
> -		rt_sernum = n = 1;
> -	return n;
> +	return (__s32)++rt_sernum <= 0 ? rt_sernum = 1 : rt_sernum;

Like your commit message, I find this unreadable, and definitely not
an improvement.

I'm not applying this even with the long lines in the commit message
fixes, sorry.
