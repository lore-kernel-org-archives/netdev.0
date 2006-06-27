From: David Miller <davem@davemloft.net>
Subject: Re: [NET]: Make illegal_highdma more anal
Date: Tue, 27 Jun 2006 13:33:42 -0700 (PDT)
Message-ID: <20060627.133342.58788770.davem@davemloft.net>
References: <20060620234938.GC30522@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:31458
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1161295AbWF0Udm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Jun 2006 16:33:42 -0400
To: herbert@gondor.apana.org.au
In-Reply-To: <20060620234938.GC30522@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Wed, 21 Jun 2006 09:49:38 +1000

> [NET]: Make illegal_highdma more anal
> 
> Rather than having illegal_highdma as a macro when HIGHMEM is off, we
> can turn it into an inline function that returns zero.  This will catch
> callers that give it bad arguments.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Looks sane, applied.
