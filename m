From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] pkt_sched: Fix qdisc state in net_tx_action()
Date: Fri, 5 Sep 2008 20:26:00 +1000
Message-ID: <20080905102600.GA30417@gondor.apana.org.au>
References: <200809050143.27998.denys@visp.net.lb> <20080905082915.GA7320@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	Denys Fedoryshchenko <denys@visp.net.lb>,
	netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:47593 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751708AbYIEK0K (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Sep 2008 06:26:10 -0400
Content-Disposition: inline
In-Reply-To: <20080905082915.GA7320@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Sep 05, 2008 at 08:29:15AM +0000, Jarek Poplawski wrote:
> 
> pkt_sched: Fix qdisc state in net_tx_action()
> 
> net_tx_action() can skip __QDISC_STATE_SCHED bit clearing while qdisc
> is neither ran nor rescheduled, which may cause endless loop in
> dev_deactivate().
> 
> Reported-by: Denys Fedoryshchenko <denys@visp.net.lb>
> Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>

Good catch!

Acked-by: Herbert Xu <herbert@gondor.apana.org.au>

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
