From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH][XFRM] Statistics: Add outbound-dropping error.
Date: Tue, 8 Jan 2008 15:33:18 +1100
Message-ID: <20080108043318.GA1844@gondor.apana.org.au>
References: <11997665683729-git-send-email-nakam@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Masahide NAKAMURA <nakam@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:3717 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753483AbYAHEdY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Jan 2008 23:33:24 -0500
Content-Disposition: inline
In-Reply-To: <11997665683729-git-send-email-nakam@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 08, 2008 at 01:29:28PM +0900, Masahide NAKAMURA wrote:
>
> P.S.
> I don't touch XFRM_LOOKUP_ICMP related error at __xfrm_lookup()
> since it may not drop the packet.
> Correct me if it is wrong or comments are welcomed.

Right, whether the packet is dropped would be decided by the caller.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
