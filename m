From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH][NET-2.6.24] Remove double dev->flags checking when calling dev_close()
Date: Wed, 10 Oct 2007 09:33:46 +0800
Message-ID: <E1IfQSI-0006jh-00@gondolin.me.apana.org.au>
References: <470B66FA.80006@garzik.org>
Cc: xemul@openvz.org, davem@davemloft.net, netdev@vger.kernel.org,
	devel@openvz.org
To: jeff@garzik.org (Jeff Garzik)
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:2137 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753881AbXJJBeF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Oct 2007 21:34:05 -0400
In-Reply-To: <470B66FA.80006@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jeff Garzik <jeff@garzik.org> wrote:
>
> One side effect of this patch:  might_sleep() is now called unconditionally.

That would be seem to be a good thing :)
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
