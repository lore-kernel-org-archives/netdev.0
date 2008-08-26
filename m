From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] pkt_sched: Fix dev_graft_qdisc() locking
Date: Tue, 26 Aug 2008 22:48:13 +1000
Message-ID: <E1KXxy1-0000kI-00@gondolin.me.apana.org.au>
References: <20080825224854.GA12082@ami.dom.local>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: jarkao2@gmail.com (Jarek Poplawski)
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:44174 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1756625AbYHZMsT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Aug 2008 08:48:19 -0400
In-Reply-To: <20080825224854.GA12082@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jarek Poplawski <jarkao2@gmail.com> wrote:
> pkt_sched: Fix dev_graft_qdisc() locking
> 
> During dev_graft_qdisc() dev is deactivated, so qdisc_root_lock()
> returns wrong lock of noop_qdisc instead of qdisc_sleeping.
> 
> 
> Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>

Looks good to me!

Acked-by: Herbert Xu <herbert@gondor.apana.org.au>

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
