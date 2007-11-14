From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 19/24] [IPSEC]: Merge most of the output path
Date: Wed, 14 Nov 2007 17:16:42 +0800
Message-ID: <20071114091642.GA12711@gondor.apana.org.au>
References: <E1Ipla8-0001IO-00@gondolin.me.apana.org.au> <4732F1B1.204@trash.net> <20071108112921.GB16688@gondor.apana.org.au> <20071114.010722.141237256.davem@davemloft.net> <473ABC73.30807@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:4843 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753060AbXKNJQy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Nov 2007 04:16:54 -0500
Content-Disposition: inline
In-Reply-To: <473ABC73.30807@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Nov 14, 2007 at 10:14:27AM +0100, Patrick McHardy wrote:
>
> Thanks Dave. As luck would have it, my HIFN card should arrive
> within the next few hours, so I'll try to convert esp over to
> async crypto and give this all some good testing :)

Actually I'm already working on that :)

I'm not just converting ESP over to async, I'm also changing
it to use the AEAD interface which is needed for it to properly
support algorithms such as CCM.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
