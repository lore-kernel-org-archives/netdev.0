From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] act_nat: the checksum of ICMP doesn't have pseudo
 header
Date: Sat, 31 Jul 2010 22:05:18 -0700 (PDT)
Message-ID: <20100731.220518.212680999.davem@davemloft.net>
References: <20100730102409.GA8590@gondor.apana.org.au>
	<AANLkTimKXsgmOSVmw-cP6Zw6UoK5CSshK38Oo5tLuAeA@mail.gmail.com>
	<20100730143016.GA10543@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xiaosuo@gmail.com, hadi@cyberus.ca, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, kaber@trash.net
To: herbert@gondor.apana.org.au
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100730143016.GA10543@gondor.apana.org.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Fri, 30 Jul 2010 22:30:16 +0800

> On Fri, Jul 30, 2010 at 10:16:05PM +0800, Changli Gao wrote:
>> 
>> I know we need to update the ICMP checksum if we alter the payload(the
>> inner IP header here) of ICMP. But I doubt if the update is really
>> necessary if the checksum is partial, as the   checksum will be done
>> later(by ether skb_checksum_help() or NIC hardware). In fact, as there
>> isn't any pseudo header, the icmph->checksum should be always ZERO,
>> otherwise skb_checksum_help() or NIC will give the wrong checksums,
>> when the checksum is partial.
> 
> Actually you are right.  I suppose the only reason this has never
> shown up is because CHEKSUM_PARTIAL doesn't usually occur with
> forwarded packets.
> 
> Acked-by: Herbert Xu <herbert@gondor.apana.org.au>

Also applied, thanks.
