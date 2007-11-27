From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [XFRM]: Fix leak of expired xfrm_states
Date: Tue, 27 Nov 2007 11:11:28 +0800
Message-ID: <20071127031128.GB1444@gondor.apana.org.au>
References: <474AE0B7.5010709@trash.net> <20071126154625.GI28022@gondor.apana.org.au> <474AEB8E.9040903@trash.net> <20071126155408.GA29097@gondor.apana.org.au> <474AEC91.5090907@trash.net> <20071126162223.GA29293@gondor.apana.org.au> <474AF9BF.2050603@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:1434 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753383AbXK0DLe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Nov 2007 22:11:34 -0500
Content-Disposition: inline
In-Reply-To: <474AF9BF.2050603@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Nov 26, 2007 at 05:52:15PM +0100, Patrick McHardy wrote:
>
> OK, here's a patch to use xfrm_state_put in __xfrm_state_delete().
> I've checked the other callers and it should be fine. lock ordering
> between x->lock and xfrm_state_gc_lock also doesn't seem to be an
> issue.

Patch applied.  Thanks a lot Patrick!
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
