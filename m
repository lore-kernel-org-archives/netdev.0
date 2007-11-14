From: David Miller <davem@davemloft.net>
Subject: Re: [IPSEC]: Fix ip_local_out when NETFILTER is off
Date: Wed, 14 Nov 2007 00:14:51 -0800 (PST)
Message-ID: <20071114.001451.254172191.davem@davemloft.net>
References: <20071114073425.GA11815@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42130
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753870AbXKNIOw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Nov 2007 03:14:52 -0500
In-Reply-To: <20071114073425.GA11815@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Wed, 14 Nov 2007 15:34:25 +0800

> [IPSEC]: Fix ip_local_out when NETFILTER is off
> 
> Thanks for testing with NETFILTER off because I obviously didn't :)
> The code for ip_local_out/ip6_local_out is completely broken in
> that case.
> 
> This patch fixes and also makes the IPsec path use the correct
> local_out function so that the loop executes properly and we
> don't end up nesting too deep and overrun the stack.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied, thanks Herbert.
