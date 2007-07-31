From: David Miller <davem@davemloft.net>
Subject: Re: [IPSEC]: Ensure that state inner family is set
Date: Tue, 31 Jul 2007 02:04:49 -0700 (PDT)
Message-ID: <20070731.020449.88702547.davem@davemloft.net>
References: <20070731085356.GA22900@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46869
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751757AbXGaJEu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 Jul 2007 05:04:50 -0400
In-Reply-To: <20070731085356.GA22900@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Tue, 31 Jul 2007 16:53:56 +0800

> Hi Dave:
> 
> [IPSEC]: Ensure that state inner family is set
> 
> Similar to the issue we had with template families which
> specified the inner families of policies, we need to set
> the inner families of states as the main xfrm user Openswan
> leaves it as zero.
> 
> af_key is unaffected because the inner family is set by it
> and not the KM.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied, thanks Herbert.
