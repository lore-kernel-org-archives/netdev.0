From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 11/11] [IPSEC]: Rename mode to outer_mode and add
 inner_mode
Date: Wed, 17 Oct 2007 21:36:03 -0700 (PDT)
Message-ID: <20071017.213603.24202620.davem@davemloft.net>
References: <20071017142940.GA23879@gondor.apana.org.au>
	<E1Ii9yV-0006Hz-00@gondolin.me.apana.org.au>
	<20071017152602.GA25116@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, kaber@trash.net, netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56805
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752624AbXJREgE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Oct 2007 00:36:04 -0400
In-Reply-To: <20071017152602.GA25116@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Wed, 17 Oct 2007 23:26:02 +0800

> On Wed, Oct 17, 2007 at 10:34:19PM +0800, Herbert Xu wrote:
> > [IPSEC]: Rename mode to outer_mode and add inner_mode
> 
> Oops.  This patch is missing two files.  Here is the correct
> version.
> 
> Cheers,
> -- 
> Visit Openswan at http://www.openswan.org/
> Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
> Home Page: http://gondor.apana.org.au/~herbert/
> PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
> --
> [IPSEC]: Rename mode to outer_mode and add inner_mode
> 
> This patch adds a new field to xfrm states called inner_mode.  The existing
> mode object is renamed to outer_mode.
> 
> This is the first part of an attempt to fix inter-family transforms.  As it
> is we always use the outer family when determining which mode to use.  As a
> result we may end up shoving IPv4 packets into netfilter6 and vice versa.
> 
> What we really want is to use the inner family for the first part of outbound
> processing and the outer family for the second part.  For inbound processing
> we'd use the opposite pairing.
> 
> I've also added a check to prevent silly combinations such as transport mode
> with inter-family transforms.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied, thanks Herbert.
