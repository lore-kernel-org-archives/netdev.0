From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] NET: Fix ipv6 GSO payload length
Date: Mon, 03 Jul 2006 19:41:26 -0700 (PDT)
Message-ID: <20060703.194126.102579077.davem@davemloft.net>
References: <1151708208.3645.2.camel@rh4>
	<20060701034446.GA30258@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mchan@broadcom.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:37319
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1751381AbWGDClL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 3 Jul 2006 22:41:11 -0400
To: herbert@gondor.apana.org.au
In-Reply-To: <20060701034446.GA30258@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Sat, 1 Jul 2006 13:44:46 +1000

> On Fri, Jun 30, 2006 at 03:56:47PM -0700, Michael Chan wrote:
> > Fix ipv6 GSO payload length calculation.
> > 
> > The ipv6 payload length excludes the ipv6 base header length and so
> > must be subtracted.
> > 
> > Signed-off-by: Michael Chan <mchan@broadcom.com>
> 
> Looks good to me.  Thanks for cathcing this!

Applied, thanks Michael.
