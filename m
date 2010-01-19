From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH][XFRM] Use the simple  name when adding SAD with ip
	xfrm state
Date: Tue, 19 Jan 2010 15:20:33 +1300
Message-ID: <20100119022033.GA18155@gondor.apana.org.au>
References: <4B541EE9.9010803@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Li Yewang <lyw@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:39089 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753852Ab0ASCUh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Jan 2010 21:20:37 -0500
Content-Disposition: inline
In-Reply-To: <4B541EE9.9010803@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Li Yewang <lyw@cn.fujitsu.com> wrote:
> The encryption name such as "rfc3686(ctr(aes))" is too complex.
> I think simple name is better for user when using "ip xfrm state ..." command.
> 
> 
> Signed-off-by: Li Yewang <lyw@cn.fujitsu.com>

Nack.  If we want to support simple names such as these, they
should be done in the crypto layer.  Otherwise every crypto user
that wants this would have to reinvent it.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
