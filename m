From: David Miller <davem@davemloft.net>
Subject: Re: [NET]: Treat CHECKSUM_PARTIAL as CHECKSUM_UNNECESSARY
Date: Mon, 09 Apr 2007 12:00:02 -0700 (PDT)
Message-ID: <20070409.120002.38298607.davem@davemloft.net>
References: <20070404020530.GA30050@gondor.apana.org.au>
	<20070404020647.GA30077@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60308
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S965028AbXDITAE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Apr 2007 15:00:04 -0400
In-Reply-To: <20070404020647.GA30077@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Wed, 4 Apr 2007 12:06:47 +1000

> Hi:
> 
> Here's the other patch.
> 
> [NET]: Treat CHECKSUM_PARTIAL as CHECKSUM_UNNECESSARY
> 
> When a transmitted packet is looped back directly, CHECKSUM_PARTIAL
> maps to the semantics of CHECKSUM_UNNECESSARY.  Therefore we should
> treat it as such in the stack.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Also applied, thanks Herbert.
