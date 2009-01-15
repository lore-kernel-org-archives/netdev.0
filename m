From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH]IPv6:remove duplicate check of optlen when setsockopt
	with IPV6_PKTINFO option
Date: Thu, 15 Jan 2009 16:48:56 +1100
Message-ID: <20090115054856.GA30523@gondor.apana.org.au>
References: <20090114.210242.163189105.davem@davemloft.net> <496ECACB.5090300@cn.fujitsu.com> <20090115053702.GA30403@gondor.apana.org.au> <20090114.214521.132298096.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: yanghy@cn.fujitsu.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:49442 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754224AbZAOFtD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Jan 2009 00:49:03 -0500
Content-Disposition: inline
In-Reply-To: <20090114.214521.132298096.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 14, 2009 at 09:45:21PM -0800, David Miller wrote:
>
> I agree with Herbert, but of course we have to adhere to cases
> where APIs actually define a user NULL pointer to have a specific
> meaning.

Absolutely.  Although AFAIK the relevant RFCs here only use the
notion of a zero option length for such purposes rather than
NULL pointers (presumably because the meaning of NULL pointers
are context dependent).

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
