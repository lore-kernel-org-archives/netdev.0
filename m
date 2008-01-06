From: David Miller <davem@davemloft.net>
Subject: Re: sparc oops in ip_fast_csum
Date: Sat, 05 Jan 2008 23:15:24 -0800 (PST)
Message-ID: <20080105.231524.204142940.davem@davemloft.net>
References: <20080105094400.GH27894@ZenIV.linux.org.uk>
	<E1JBJHA-0000hy-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: viro@ZenIV.linux.org.uk, m.kozlowski@tuxland.pl,
	sparclinux@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <sparclinux-owner@vger.kernel.org>
In-Reply-To: <E1JBJHA-0000hy-00@gondolin.me.apana.org.au>
Sender: sparclinux-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Sun, 06 Jan 2008 11:22:04 +1100

> [IPV4] raw: Strengthen check on validity of iph->ihl 
> 
> We currently check that iph->ihl is bounded by the real length and that
> the real length is greater than the minimum IP header length.  However,
> we did not check the caes where iph->ihl is less than the minimum IP
> header length.
> 
> This breaks because some ip_fast_csum implementations assume that which
> is quite reasonable.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied, I'll push this to -stable too, thanks Herbert.
