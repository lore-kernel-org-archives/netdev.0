From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH][net-next] LRO: improve aggregation in case of zero
	TSecr packets
Date: Fri, 25 Sep 2009 14:33:38 -0700
Message-ID: <20090925213338.GA3204@gondor.apana.org.au>
References: <200908270208.31581.opurdila@ixiacom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: themann@de.ibm.com, raisch@de.ibm.com, eric.dumazet@gmail.com,
	netdev@vger.kernel.org
To: Octavian Purdila <opurdila@ixiacom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:55740 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751775AbZIYVdm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Sep 2009 17:33:42 -0400
Content-Disposition: inline
In-Reply-To: <200908270208.31581.opurdila@ixiacom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Octavian Purdila <opurdila@ixiacom.com> wrote:
> 
> This fixes a temporary performance issue we noticed in back to back
> TSO - LRO tests when such tests are run within five minutes after
> boot.

Sorry for responding to old emails again but just for the record,
please keep in mind that LRO is going away so you really should
run your tests with GRO (and update the driver if necessary) as
otherwise your efforts may end up being wasted.

In this particular instance, you're trying to fix an issue that
GRO already fixes.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
