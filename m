From: David Miller <davem@davemloft.net>
Subject: Re: 2.6.18-rc2 tg3 Dead loop on netdevice eth0 fix it urgently!
Date: Wed, 19 Jul 2006 12:54:05 -0700 (PDT)
Message-ID: <20060719.125405.48804152.davem@davemloft.net>
References: <20060719110439.GJ23431@puettmann.net>
	<E1G3E0V-0006e2-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ruben@puettmann.net, sergio@sergiomb.no-ip.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:63662
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1030260AbWGSTyF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Jul 2006 15:54:05 -0400
To: herbert@gondor.apana.org.au
In-Reply-To: <E1G3E0V-0006e2-00@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Thu, 20 Jul 2006 01:30:39 +1000

> [NET]: Fix reversed error test in netif_tx_trylock
> 
> A non-zero return value indicates success from spin_trylock,
> not error.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied, thanks Herbert.
