From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] 8139too: harden against TX ring overflow
Date: Fri, 06 Apr 2007 11:48:32 +1000
Message-ID: <E1HZdZ2-000620-00@gondolin.me.apana.org.au>
References: <200704052350.59464.sshtylyov@ru.mvista.com>
Cc: jgarzik@pobox.com, netdev@vger.kernel.org, mhuth@mvista.com,
	kgdb-bugreport@lists.sourceforge.net
To: sshtylyov@ru.mvista.com (Sergei Shtylyov)
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:4115 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1767398AbXDFBsu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Apr 2007 21:48:50 -0400
In-Reply-To: <200704052350.59464.sshtylyov@ru.mvista.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Sergei Shtylyov <sshtylyov@ru.mvista.com> wrote:
> This driver's 4-packet deep TX queue is too sensible to the "careless" callers
> ignoring its state (like netpoll in trapped mode), so add "queue full" check at
> the start of the hard_start_xmit() method (only under #ifndef RTL8139_NDEBUG,
> otherwise the queue will get stuck once dirty pointer gets out of sync); switch
> to using appropriate mnemonics for the return values while at it.

Could you please describe this netpoll scenario in more detail?
More importantly, why wouldn't we fix netpoll instead?

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
