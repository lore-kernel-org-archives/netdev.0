From: "David S. Miller" <davem@davemloft.net>
Subject: Re: kernel BUG at net/ipv6/exthdrs_core.c:80!
Date: Sun, 24 Apr 2005 20:17:06 -0700
Message-ID: <20050424201706.20d3e129.davem@davemloft.net>
References: <20050422.204610.96031992.yoshfuji@linux-ipv6.org>
	<E1DOyg4-0000iB-00@gondolin.me.apana.org.au>
	<20050422141950.GA2791@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, matti.aarnio@zmailer.org,
	linux-net@vger.kernel.org, netdev@oss.sgi.com
Return-path: <linux-net-owner@vger.kernel.org>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20050422141950.GA2791@gondor.apana.org.au>
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 23 Apr 2005 00:19:50 +1000
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> I was just reading ipv6_skip_exthdr and it occured to me that we can
> get rid of len altogether.  The only place where len is used is to
> check whether the skb has two bytes for ipv6_opt_hdr.  This check
> is done by skb_header_pointer/skb_copy_bits anyway.
> 
> Now it might appear that we've made the code slower by deferring
> the check to skb_copy_bits.  However, this check should not trigger
> in the common case so this is OK.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

This looks great, applied.

Thanks Herbert.
