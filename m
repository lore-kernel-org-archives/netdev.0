From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] (revised) Interfamily IPSec BEET
Date: Wed, 06 Aug 2008 02:40:31 -0700 (PDT)
Message-ID: <20080806.024031.78921650.davem@davemloft.net>
References: <200808051235.47624.joakim.koskela@hiit.fi>
	<20080805105406.GC21786@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: joakim.koskela@hiit.fi, netdev@vger.kernel.org, yoshfuji@wide.ad.jp
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53717
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1756859AbYHFJkb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Aug 2008 05:40:31 -0400
In-Reply-To: <20080805105406.GC21786@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Tue, 5 Aug 2008 18:54:06 +0800

> On Tue, Aug 05, 2008 at 12:35:47PM +0300, Joakim Koskela wrote:
> > 
> > Here's a revised version, based on Herbert's comments, of a fix for
> > the ipv4-inner, ipv6-outer interfamily ipsec beet mode. It fixes the
> > network header adjustment during interfamily, as well as makes sure
> > that we reserve enough room for the new ipv6 header if we might have
> > something else as the inner family. Also, the ipv4 pseudo header
> > construction was added.
> > 
> > Signed-off-by: Joakim Koskela <jookos@gmail.com>
> 
> Acked-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied.
