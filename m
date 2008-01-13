From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH v2] Documentation: add a guideline for hard_start_xmit method
Date: Mon, 14 Jan 2008 08:45:13 +1100
Message-ID: <E1JEAdl-00040W-00@gondolin.me.apana.org.au>
References: <13447.65555.qm@web52011.mail.re2.yahoo.com>
Cc: jgarzik@pobox.com, netdev@vger.kernel.org
To: mattilinnanvuori@yahoo.com (Matti Linnanvuori)
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:2824 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754035AbYAMVpY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Jan 2008 16:45:24 -0500
In-Reply-To: <13447.65555.qm@web52011.mail.re2.yahoo.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Matti Linnanvuori <mattilinnanvuori@yahoo.com> wrote:
>
> -3) Do not forget that once you return 0 from your hard_start_xmit
> +3) A hard_start_xmit method must not modify the shared parts of the SKB.

Only if it's cloned.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
