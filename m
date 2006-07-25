From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] clear skb cb on IP input
Date: Mon, 24 Jul 2006 23:45:37 -0700 (PDT)
Message-ID: <20060724.234537.67563456.davem@davemloft.net>
References: <44BD2636.1010105@yahoo.fr>
	<20060718194318.GA15572@gondor.apana.org.au>
	<44BE2703.8060907@yahoo.fr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, chas3@users.sourceforge.net,
	shemminger@osdl.org, netdev@vger.kernel.org,
	yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:20929
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1751463AbWGYGpi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 25 Jul 2006 02:45:38 -0400
To: guichaz@yahoo.fr
In-Reply-To: <44BE2703.8060907@yahoo.fr>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Guillaume Chazarain <guichaz@yahoo.fr>
Date: Wed, 19 Jul 2006 14:35:15 +0200

> Herbert Xu wrote :
> > Probably. Patches are welcome :)
> Here are they, in both case I checked that the stuff to clear
> was not already cleared, but I could not produce any misbehavior
> by writing random junk instead of clearing the data. All my tests
> were on the loopback using UML.
> 
> For IPv4, the added safety seems worth, but for IPv6 it's less clear.

Both patches applied, thanks Guillaume.
