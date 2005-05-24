From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Subject: Re: [XFRM] Call dst_check() with appropriate cookie
Date: Tue, 24 May 2005 16:30:18 +0900 (JST)
Message-ID: <20050524.163018.29919354.yoshfuji@linux-ipv6.org>
References: <20050524.124919.00464304.yoshfuji@linux-ipv6.org>
	<E1DaTeW-00085B-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@oss.sgi.com, yoshfuji@linux-ipv6.org,
        kazunori@miyazawa.org
Return-path: <netdev-bounce@oss.sgi.com>
To: herbert@gondor.apana.org.au
In-Reply-To: <E1DaTeW-00085B-00@gondolin.me.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <E1DaTeW-00085B-00@gondolin.me.apana.org.au> (at Tue, 24 May 2005 17:16:36 +1000), Herbert Xu <herbert@gondor.apana.org.au> says:

> > This fixes infinite loop issue with IPv6 tunnel mode.
> 
> Can someone please tell me where this infinite loop is?

Honestly speaking, we haven't tracked down deeply where it is,
but that patch is logically reauired and it definetely solves grave
"freeze" issue with ipv6 tunnel mode xfrm.

--yoshfuji
