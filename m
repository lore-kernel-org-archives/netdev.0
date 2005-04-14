From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH] IPV6_CHECKSUM socket option can corrupt kernel memory
Date: Thu, 14 Apr 2005 21:34:32 +0900 (JST)
Message-ID: <20050414.213432.123958433.yoshfuji@linux-ipv6.org>
References: <OF618A0572.CA254DA0-ON88256FE1.0080DB81-88256FE1.0082220B@us.ibm.com>
	<E1DM3QD-00045e-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dlstevens@us.ibm.com, netdev@oss.sgi.com, yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: herbert@gondor.apana.org.au, davem@davemloft.net
In-Reply-To: <E1DM3QD-00045e-00@gondolin.me.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <E1DM3QD-00045e-00@gondolin.me.apana.org.au> (at Thu, 14 Apr 2005 22:26:13 +1000), Herbert Xu <herbert@gondor.apana.org.au> says:

> So here is a patch that introduces skb_store_bits -- the opposite of
> skb_copy_bits, and uses them to read/write the csum field in rawv6.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

(I re-review this later, but anyway,) I basically agree;
this is what I wanted.

Signed-off-by: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>

--yoshfuji
