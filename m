From: David Miller <davem@davemloft.net>
Subject: Re: [3/5] [NET]: Add software TSOv4
Date: Thu, 22 Jun 2006 14:32:06 -0700 (PDT)
Message-ID: <20060622.143206.111203586.davem@davemloft.net>
References: <20060622081211.GA22505@gondor.apana.org.au>
	<20060622081400.GC22671@gondor.apana.org.au>
	<20060623.000403.47759894.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:49857
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S932659AbWFVVcN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Jun 2006 17:32:13 -0400
To: yoshfuji@linux-ipv6.org
In-Reply-To: <20060623.000403.47759894.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date: Fri, 23 Jun 2006 00:04:03 +0900 (JST)

> In article <20060622081400.GC22671@gondor.apana.org.au> (at Thu, 22 Jun 2006 18:14:00 +1000), Herbert Xu <herbert@gondor.apana.org.au> says:
> 
> > [NET]: Add software TSOv4
> > 
> > This patch adds the GSO implementation for IPv4 TCP.
> > 
> > Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
> 
> I'd appreciate if you code up IPv6 TCP as well. :-)

To my understanding doing IPV6 TCP TSO is a non-trivial task, even in
software.

The header editing is a lot more complicated because things like
routing and other extension headers can sit between IPV6 and TCP
header.

It is probably why IPV6 TSO hardware does not exist yet :)

Do not take this to mean I think it should not be implemented, I think
it should.
