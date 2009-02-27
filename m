From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [net-next PATCH] igb: remove skb_orphan calls
Date: Fri, 27 Feb 2009 11:14:21 +0800
Message-ID: <20090227031421.GA21036@gondor.apana.org.au>
References: <80769D7B14936844A23C0C43D9FBCF0F283B6220@orsmsx501.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jeffrey.t.kirsher@intel.com, davem@davemloft.net,
	emil.s.tantilov@intel.com, patrick.ohly@intel.com,
	netdev@vger.kernel.org, gospo@redhat.com,
	mitch.a.williams@intel.com
To: "Duyck, Alexander H" <alexander.h.duyck@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:51369 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752477AbZB0DO2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Feb 2009 22:14:28 -0500
Content-Disposition: inline
In-Reply-To: <80769D7B14936844A23C0C43D9FBCF0F283B6220@orsmsx501.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Duyck, Alexander H <alexander.h.duyck@intel.com> wrote:
>
> This patch was meant to be more general than just timestamping.  I was just using timestamping as one example of where things can go wrong due to the skb_orphan call.  The main problem is triggering desctructors and removing the sk can cause multiple issues with any custom use of the skb.  It is easiest to avoid those by not calling skb_orphan in the first place.

It doesn't matter what those custom uses are, what Dave was saying
is that we're thinking of killing skb->sk before it even gets to
the driver.  So even if such custom uses existed (which AFAIK do
not), we'd been looking at killing them as well.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
