From: David Miller <davem@davemloft.net>
Subject: Re: GRO/GSO hiding PMTU?
Date: Thu, 10 Feb 2011 23:06:01 -0800 (PST)
Message-ID: <20110210.230601.112607712.davem@davemloft.net>
References: <20110210.222216.104050992.davem@davemloft.net>
	<20110210.223544.189709102.davem@davemloft.net>
	<20110211064138.GB29940@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20110211064138.GB29940@gondor.apana.org.au>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Fri, 11 Feb 2011 17:41:38 +1100

> I think we need to do some length verifications here because for
> a malicious guest-generated packet the TCP header may not be present.

Indeed, good catch.
