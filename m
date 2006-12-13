From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: examples of setting ip address/netmask/etc.. on a device
Date: Wed, 13 Dec 2006 15:48:17 +1100
Message-ID: <E1GuM2T-0004GU-00@gondolin.me.apana.org.au>
References: <A02AEA26-70F9-4B55-A88A-235B3FF4C9F9@kernel.crashing.org>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:4798 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S964929AbWLMF26 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Dec 2006 00:28:58 -0500
To: galak@kernel.crashing.org (Kumar Gala)
In-Reply-To: <A02AEA26-70F9-4B55-A88A-235B3FF4C9F9@kernel.crashing.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Kumar Gala <galak@kernel.crashing.org> wrote:
> I was wondering if there were any examples of net devices that expect  
> to be told the ip information for their connection (things doing  
> forms of offload).  If so can someone point me at a driver that does  
> this.

Try drivers/s390/net/qeth_main.c.  Of course, it's best to avoid this
if at all possible.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
