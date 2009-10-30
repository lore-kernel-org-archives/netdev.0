From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: Connection tracking and vlan
Date: Fri, 30 Oct 2009 12:55:00 -0400
Message-ID: <20091030165500.GA8789@gondor.apana.org.au>
References: <20091030152054.GA7936@gondor.apana.org.au> <4AEB06E6.6020206@gmail.com> <20091030154639.GA8197@gondor.apana.org.au> <4AEB1212.6010905@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Adayadil Thomas <adayadil.thomas@gmail.com>,
	netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:59812 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S932668AbZJ3Qy6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Oct 2009 12:54:58 -0400
Content-Disposition: inline
In-Reply-To: <4AEB1212.6010905@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 30, 2009 at 05:19:30PM +0100, Eric Dumazet wrote:
>
> No, Abayadi needs firewall rules (or RPF), before entering conntrack.

rp_filter doesn't help because routing occurs after conntrack,
so IP fragments from the untrusted side may have already been
folded into a fragment from the trusted side.

Yes netfilter rules pre-conntrack would help but I bet there
are a lot folks out there who don't have them.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
