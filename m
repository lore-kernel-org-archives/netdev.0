From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] tcp_output: Re: rare bad TCP checksum with 2.6.19?
Date: Sat, 20 Jan 2007 08:10:27 +1100
Message-ID: <20070119211027.GA16626@gondor.apana.org.au>
References: <45AE2EDF.4060709@tls.msk.ru> <20070119110641.GA3135@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Michael Tokarev <mjt@tls.msk.ru>, netdev@vger.kernel.org,
	Patrick McHardy <kaber@trash.net>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:1982 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S964852AbXASVKq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Jan 2007 16:10:46 -0500
To: Jarek Poplawski <jarkao2@o2.pl>
Content-Disposition: inline
In-Reply-To: <20070119110641.GA3135@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jan 19, 2007 at 12:06:41PM +0100, Jarek Poplawski wrote:
> 
> [PATCH][NET] tcp_output: rare bad TCP checksum with 2.6.19
> 
> The patch "Replace CHECKSUM_HW by CHECKSUM_PARTIAL/CHECKSUM_COMPLETE"
> changed to unconditional copying of ip_summed field from collapsed
> skb. This patch reverts this change.   
> 
> All substantial work including heavy testing and diagnosing by:
> Michael Tokarev <mjt@tls.msk.ru>
> 
> Signed-off-by: Jarek Poplawski <jarkao2@o2.pl>

Acked-by: Herbert Xu <herbert@gondor.apana.org.au>

Thanks for catching this! I'll take the credit for adding this bug :)

Dave, we'll need this fix for 2.6.20 as well as 2.6.19.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
