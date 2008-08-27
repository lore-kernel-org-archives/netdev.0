From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] pkt_sched: Destroy gen estimators under rtnl_lock().
Date: Wed, 27 Aug 2008 02:32:40 -0700 (PDT)
Message-ID: <20080827.023240.41876858.davem@davemloft.net>
References: <20080824202922.2cc9b9f6@speedy>
	<20080826073508.GA1039@gondor.apana.org.au>
	<20080826074702.GA1102@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, jarkao2@gmail.com, netdev@vger.kernel.org,
	denys@visp.net.lb, jussi.kivilinna@mbnet.fi
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44900
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752214AbYH0Jcp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Aug 2008 05:32:45 -0400
In-Reply-To: <20080826074702.GA1102@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Tue, 26 Aug 2008 17:47:02 +1000

> BTW, the use of the CB area conflicts with the new pkt_len stuff
> so either netem or the pkt_len code needs to be fixed.

Netem should be just fine, it's using the opaque ->data[]
blob at the end of qdisc_skb_cb which was created exactly
for this purpose I imagine. :)

Let me know if I missed something.

