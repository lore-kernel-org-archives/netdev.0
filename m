From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] [XFRM] IPv6: Fix dst/routing check at transformation.
Date: Fri, 21 Dec 2007 11:50:46 +0800
Message-ID: <20071221035045.GA30093@gondor.apana.org.au>
References: <11982084391595-git-send-email-nakam@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, usagi-core@linux-ipv6.org,
	"David S. Miller" <davem@davemloft.net>
To: Masahide NAKAMURA <nakam@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:4484 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1759879AbXLUDut (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Dec 2007 22:50:49 -0500
Content-Disposition: inline
In-Reply-To: <11982084391595-git-send-email-nakam@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Dec 21, 2007 at 12:40:39PM +0900, Masahide NAKAMURA wrote:
> IPv6 specific thing is wrongly removed from transformation at net-2.6.25.
> This patch recovers it with current design.
> 
> o Update "path" of xfrm_dst since IPv6 transformation should
>   care about routing changes. It is required by MIPv6 and
>   off-link destined IPsec.
> o Rename nfheader_len which is for non-fragment transformation used by
>   MIPv6 to rt6i_nfheader_len as IPv6 name space.
> 
> Signed-off-by: Masahide NAKAMURA <nakam@linux-ipv6.org>

Thanks for fixing this up.  They both look good to me.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
