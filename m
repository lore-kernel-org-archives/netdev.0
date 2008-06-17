From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: IPSEC in 2.6.25 causes stalled connections
Date: Tue, 17 Jun 2008 15:39:09 +1000
Message-ID: <E1K8TuP-0002Qd-00@gondolin.me.apana.org.au>
References: <20080608010858.GA8877@swan.nt.tuwien.ac.at>
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: tzeitlho+lkml@nt.tuwien.ac.at (Thomas Zeitlhofer)
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:47838 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751443AbYFQFjN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Jun 2008 01:39:13 -0400
In-Reply-To: <20080608010858.GA8877@swan.nt.tuwien.ac.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thomas Zeitlhofer <tzeitlho+lkml@nt.tuwien.ac.at> wrote:
> 
> Is this a known issue?

Not to me.  When a connection gets stuck does the SA in question
still function? For instance, can you send a ping through that
exact SA?

Please send us the ip -s x s and ip -s x p output (with your
serect keys removed/obscured).

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
