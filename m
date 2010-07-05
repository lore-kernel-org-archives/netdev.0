From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: Fwd: Possible bug in net/ipv4/route.c?
Date: Mon, 5 Jul 2010 20:06:17 +0800
Message-ID: <20100705120617.GA6267@gondor.apana.org.au>
References: <1278049111.2597.6.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: yoshfuji@linux-ipv6.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Stephen Hemminger <shemminger@vyatta.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1278049111.2597.6.camel@edumazet-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Eric Dumazet <eric.dumazet@gmail.com> wrote:
>
>> 2) The layer using skb->cb[] should clear this area after use and
>> before handing the skb to another layer.  Ubicom should modify the
>> driver to clear the skb->cb[] area before sending it up the line.
>> 
> 
> This is the right option. If you use one word in cb[], only your driver
> knows how to clear it efficiently.

Absolutely not! No protocol stack should rely on an external skb
having a zero cb.

Please fix the bridge instead as it's doing the IP injection.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
