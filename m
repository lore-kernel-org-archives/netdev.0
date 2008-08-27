From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] pkt_sched: Destroy gen estimators under rtnl_lock().
Date: Wed, 27 Aug 2008 19:56:28 +1000
Message-ID: <20080827095628.GB12583@gondor.apana.org.au>
References: <20080824202922.2cc9b9f6@speedy> <20080826073508.GA1039@gondor.apana.org.au> <20080826074702.GA1102@gondor.apana.org.au> <20080827.023240.41876858.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: shemminger@vyatta.com, jarkao2@gmail.com, netdev@vger.kernel.org,
	denys@visp.net.lb, jussi.kivilinna@mbnet.fi
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:60646 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755084AbYH0J4g (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Aug 2008 05:56:36 -0400
Content-Disposition: inline
In-Reply-To: <20080827.023240.41876858.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 27, 2008 at 02:32:40AM -0700, David Miller wrote:
> From: Herbert Xu <herbert@gondor.apana.org.au>
> Date: Tue, 26 Aug 2008 17:47:02 +1000
> 
> > BTW, the use of the CB area conflicts with the new pkt_len stuff
> > so either netem or the pkt_len code needs to be fixed.
> 
> Netem should be just fine, it's using the opaque ->data[]
> blob at the end of qdisc_skb_cb which was created exactly
> for this purpose I imagine. :)
> 
> Let me know if I missed something.

You're right I missed that bit :)
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
