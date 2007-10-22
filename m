From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [RFC][PATCH 0/3][XFRM]: Support packet processing error statistics.
Date: Mon, 22 Oct 2007 16:50:40 +0800
Message-ID: <20071022085040.GA17954@gondor.apana.org.au>
References: <20071017.213523.58458049.davem@davemloft.net> <11930334662094-git-send-email-nakam@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Masahide NAKAMURA <nakam@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:4136 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751907AbXJVIuq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Oct 2007 04:50:46 -0400
Content-Disposition: inline
In-Reply-To: <11930334662094-git-send-email-nakam@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Oct 22, 2007 at 03:11:06PM +0900, Masahide NAKAMURA wrote:
> This patch introduces statistics about transformation error (or almost error)
> factor at packet processing for developer.
> It is not a SNMP/MIB specification from IPsec/MIPv6 but a counter
> designed from current transformation source code.
> 
> Comment please.

Looks fine to me.  But could you hold onto this for a few days?
I'm in the process of merging the input paths of IPv4 and IPv6.
Once that's done you'll only need to count things once rather
than once for IPv4 and again for IPv6.

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
