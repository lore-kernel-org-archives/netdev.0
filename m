From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: Problems with xfrm (IPSec) and multicast
Date: Tue, 11 Jul 2006 23:02:59 +1000
Message-ID: <20060711130259.GA12879@gondor.apana.org.au>
References: <44900AA7.90800@tihlde.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:12804 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S1750741AbWGKNDV
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 11 Jul 2006 09:03:21 -0400
To: Roar Bj?rgum Rotvik <roarbr@tihlde.org>
Content-Disposition: inline
In-Reply-To: <44900AA7.90800@tihlde.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jun 14, 2006 at 01:09:59PM +0000, Roar Bj?rgum Rotvik wrote:
> 
> So I cannot make encrypted multicast traffic to flow both ways at the same 
> time, and has no clue as to why the first packets after changing direction 
> is dropped somewhere.

Sounds like conntrack.  Check /proc/net/ip_conntrack when this happens.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
