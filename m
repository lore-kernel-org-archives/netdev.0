From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/3] [UDP]: Restore missing inDatagrams increments
Date: Wed, 05 Dec 2007 02:02:48 -0800 (PST)
Message-ID: <20071205.020248.50886654.davem@davemloft.net>
References: <20071205021559.GA27707@gondor.apana.org.au>
	<47567128.2060008@cosmosbay.com>
	<20071205095159.GA16860@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dada1@cosmosbay.com, wangchen@cn.fujitsu.com,
	netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34315
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750896AbXLEKCt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Dec 2007 05:02:49 -0500
In-Reply-To: <20071205095159.GA16860@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Wed, 5 Dec 2007 20:51:59 +1100

> On Wed, Dec 05, 2007 at 10:36:40AM +0100, Eric Dumazet wrote:
> > 
> > Hum, what happens if I have in my .config file :
> > 
> > CONFIG_IPV6=n
> 
> Thanks.  Obviously I shouldn't have touched this stuff at all :)
> Let's hope this is the last problem.
> 
> [UDP]: Restore missing inDatagrams increments
> 
> The previous move of the the UDP inDatagrams counter caused the
> counting of encapsulated packets, SUNRPC data (as opposed to call)
> packets and RXRPC packets to go missing.
> 
> This patch restores all of these.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Herbert, I applied the buggered patch and pushed it out
already, can you send me this fix relative?

I'll combine them on my next rebase, thanks.
