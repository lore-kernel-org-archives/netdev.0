From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: tx-checksumming for an Intel Corporation 82540EP Gigabit Ethernet Controller (Mobile)
Date: Mon, 21 Apr 2008 12:50:34 +0800
Message-ID: <20080421045034.GA7550@gondor.apana.org.au>
References: <47EB8C5C.7060007@isomerica.net> <E1Jnn9e-0001tP-00@gondolin.me.apana.org.au> <20080420.212451.10825959.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: dpn@isomerica.net, toralf.foerster@gmx.de, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:46346 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751229AbYDUEul (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Apr 2008 00:50:41 -0400
Content-Disposition: inline
In-Reply-To: <20080420.212451.10825959.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Apr 20, 2008 at 09:24:51PM -0700, David Miller wrote:
>
> But every time we say this they keep coming back at us that they can't
> change the tcpdump raw dump file format that's been used for
> centuries, and naturally it was designed without any extensibility in
> mind so there's nowhere to store the checksum indication.

They could always fix up the checksums if it has to be written
out.  Alternatively it could notice that the checksum is exactly
that of the pseudo-header and flag it differently versus just any
checksum error.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
