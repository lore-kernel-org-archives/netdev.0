From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] GRO: fix merging a paged skb after non-paged skbs
Date: Wed, 9 Feb 2011 07:54:53 +1100
Message-ID: <20110208205453.GA590@gondor.apana.org.au>
References: <20110124184752.1d0947dd@delilah> <1295918675.4105.5.camel@localhost> <1297111160.4077.14.camel@bwh-desktop> <20110208084928.GA27505@gondor.apana.org.au> <1297177484.3325.1.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Michal Schmidt <mschmidt@redhat.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-net-drivers@solarflare.com
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.apana.org.au ([209.40.204.226]:52326 "EHLO
	fornost.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755328Ab1BHUzC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Feb 2011 15:55:02 -0500
Content-Disposition: inline
In-Reply-To: <1297177484.3325.1.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Feb 08, 2011 at 03:04:44PM +0000, Ben Hutchings wrote:
>
> That would work, though it looks like Michal has managed to make it
> tolerate switches.  (I haven't yet tested the result myself.)

Well the question is do we really want to still keep merging
in case of a switch? It could potentially get messy if it switches
back over and over again.

However, I suppose other merging criteria will stop the merging
in such cases so it's probably not a big deal.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
