From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: rare bad TCP checksum with 2.6.19?
Date: Mon, 15 Jan 2007 20:39:36 +1100
Message-ID: <E1H6OJU-0001EC-00@gondolin.me.apana.org.au>
References: <45AAB5C4.8010002@tls.msk.ru>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:1656 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S932156AbXAOJjy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Jan 2007 04:39:54 -0500
To: mjt@tls.msk.ru (Michael Tokarev)
In-Reply-To: <45AAB5C4.8010002@tls.msk.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Michael Tokarev <mjt@tls.msk.ru> wrote:
>
> Note there's no funny/interesting hardware involved, like network cards with
> tcp checksumming offload capabilities (this is plain dumb 8139 card).

The 8139 card might be dumb, but the driver isn't :) It emulates
checksum offload in software, meaning that tcpdump will show bogus
checksums.

So please disable hardware checksum offload with ethtool -K and
then try again.

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
