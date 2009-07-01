From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] bridge: make bridge-nf-call-*tables default configurable
Date: Wed, 1 Jul 2009 17:07:36 +0800
Message-ID: <20090701090736.GA32306@gondor.apana.org.au>
References: <1246379267.3749.42.camel@blaa> <20090630170027.GA22691@gondor.apana.org.au> <4A4B24DE.10103@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Mark McLoughlin <markmc@redhat.com>,
	netdev <netdev@vger.kernel.org>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:53872 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752907AbZGAJHi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Jul 2009 05:07:38 -0400
Content-Disposition: inline
In-Reply-To: <4A4B24DE.10103@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 01, 2009 at 10:57:02AM +0200, Patrick McHardy wrote:
>
> People are apparently using this for stateful tracking and even
> NAT on bridges, so I'm afraid we can't get rid of it completely.

I think we should print out a nasty message warning the user
if we detect that conntrack is used by bridge netfilter for the
first time.  If the user persists then at least they can't sue
us for not warning them :)

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
