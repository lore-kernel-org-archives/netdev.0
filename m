From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: Error: an inet prefix is expected rather than "0/0".
Date: Tue, 14 Oct 2008 22:01:27 +0800
Message-ID: <E1KpkSl-00087W-GB@gondolin.me.apana.org.au>
References: <alpine.LNX.1.10.0810082331010.13921@bizon.gios.gov.pl>
Cc: netdev@vger.kernel.org, shemminger@vyatta.com
To: ole@ans.pl (Krzysztof Oledzki)
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:59807 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751324AbYJNOBn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Oct 2008 10:01:43 -0400
In-Reply-To: <alpine.LNX.1.10.0810082331010.13921@bizon.gios.gov.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Krzysztof Oledzki <ole@ans.pl> wrote:
>
> http://git.kernel.org/?p=linux/kernel/git/shemminger/iproute2.git;a=commitdiff_plain;h=2ca4abdcb823e708b88156f947fa5b493055618a
> 
> ;)

Hmm, this breaks several scripts of mine that use 10/8.  Couldn't
we just fall back to the old loop when inet_aton fails?

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
