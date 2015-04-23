From: David Miller <davem@davemloft.net>
Subject: Re: CCM/GCM implementation defect
Date: Wed, 22 Apr 2015 23:36:58 -0400 (EDT)
Message-ID: <20150422.233658.2254137104297879050.davem@davemloft.net>
References: <20150423032619.GA17648@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: steffen.klassert@secunet.com, netdev@vger.kernel.org,
	pwouters@redhat.com, linux-crypto@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <linux-crypto-owner@vger.kernel.org>
In-Reply-To: <20150423032619.GA17648@gondor.apana.org.au>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Thu, 23 Apr 2015 11:26:20 +0800

> In order to fix this without breaking backwards compatibility,
> my plan is to introduce new templates such as rfc4106v2 which
> implement the RFC correctly.  The existing templates will be
> retained so that current users aren't broken by the fix.
> 
> Once the kernel side is complete we could then get the user-space
> implementors to update their tools to request for the new v2
> templates.
> 
> Comments?

At first glance this seems like a very reasonable approach.
