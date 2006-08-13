From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] cleanup of the NETIF_F_* flag definitions
Date: Sun, 13 Aug 2006 23:06:19 +1000
Message-ID: <E1GCFfX-0007lk-00@gondolin.me.apana.org.au>
References: <44DE2DFC.5030902@garzik.org>
Cc: a.p.zijlstra@chello.nl, davem@redhat.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:61450 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S1751239AbWHMNGl
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 13 Aug 2006 09:06:41 -0400
To: jeff@garzik.org (Jeff Garzik)
In-Reply-To: <44DE2DFC.5030902@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jeff Garzik <jeff@garzik.org> wrote:
> Peter Zijlstra wrote:
>> Cleanup the NETIF_F_ flag definitions
>> 
>> Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
> 
> If you are going to do a cleanup here, you should use the form that 
> makes it _immediately_ obvious which bit(s) are being used:

Also, please avoid changing the values if possible.

It shouldn't really break anything as far as I know, but it does
change a user-visible interface since we export (for some reason
unbeknownst to me) the features value to user-space via sysfs.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
