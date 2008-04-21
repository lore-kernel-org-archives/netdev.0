From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: tx-checksumming for an Intel Corporation 82540EP Gigabit Ethernet Controller (Mobile)
Date: Mon, 21 Apr 2008 11:57:22 +0800
Message-ID: <E1Jnn9e-0001tP-00@gondolin.me.apana.org.au>
References: <47EB8C5C.7060007@isomerica.net>
Cc: toralf.foerster@gmx.de, netdev@vger.kernel.org
To: dpn@isomerica.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:49313 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754751AbYDUD5a (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Apr 2008 23:57:30 -0400
In-Reply-To: <47EB8C5C.7060007@isomerica.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Daniel Noe <dpn@isomerica.net> wrote:
>
> 2) Tell Wireshark not to verify the checksums.  See 
> http://wiki.wireshark.org/TCP_Checksum_Verification.  This works if you 
> don't really care about the checksums and are looking at other things. 
> If you suspect incorrect checksums, you can always turn off checksum 
> offloading manually.

Better yet fix Wireshark to use the info that the kernel supplies
and ignore checksums only on those packets generated locally for
hardware offload.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
