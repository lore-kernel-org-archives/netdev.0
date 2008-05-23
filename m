From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [VLAN]: Use bitmask of feature flags instead of seperate feature bits
Date: Fri, 23 May 2008 17:09:45 +1000
Message-ID: <20080523070945.GB6615@gondor.apana.org.au>
References: <48366C0F.4020905@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:48266 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S932553AbYEWHJv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 May 2008 03:09:51 -0400
Content-Disposition: inline
In-Reply-To: <48366C0F.4020905@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, May 23, 2008 at 09:02:39AM +0200, Patrick McHardy wrote:
> 
>     [VLAN]: Use bitmask of feature flags instead of seperate feature bits
>     
>     Herbert Xu points out that the use of seperate feature bits for features
>     to be propagated to VLAN devices is going to get messy real soon.
>     Replace the VLAN feature bits by a bitmask of feature flags to be
>     propagated and restore the old GSO_SHIFT/MASK values.
>     
>     Signed-off-by: Patrick McHardy <kaber@trash.net>

Looks great Patrick, thanks!

Acked-by: Herbert Xu <herbert@gondor.apana.org.au>

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
