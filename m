From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 2/5] [IPV6]: Multiple Routing Tables
Date: Tue, 01 Aug 2006 00:01:03 +1000
Message-ID: <E1G7YKN-0007Ao-00@gondolin.me.apana.org.au>
References: <44CE0BE6.1070108@tcs.hut.fi>
Cc: tgraf@suug.ch, netdev@vger.kernel.org, usagi-core@linux-ipv6.org,
	yoshfuji@linux-ipv6.org, davem@davemloft.net, anttit@tcs.hut.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:28677 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S932308AbWGaOB0
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 31 Jul 2006 10:01:26 -0400
To: vnuorval@tcs.hut.fi (Ville Nuorvala)
In-Reply-To: <44CE0BE6.1070108@tcs.hut.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ville Nuorvala <vnuorval@tcs.hut.fi> wrote:
> 
>> When locating routes for redirects only the main table is
>> searched for now. Since policy rules will not be reversible
>> it is unclear whether it makes sense to change this.
> 
> This is a good point. You are absolutely correct about the policy rules.
> 
> IIRC, I initially looked through all the tables, but skipped this
> behavior when I rewrote the code for 2.6.11. Currently I'm once again
> in favor of looping through them all. This is IMO at least closer to the
> spirit of RFC 2461 section 8.3. where a host SHOULD update its
> destination cache upon receiving a redirect. If we don't look through
> all tables, we can't ensure this happens.

Without a route cache, I think our only choice is to search through
all tables.  The same thing applies to PMTU updates as well.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
