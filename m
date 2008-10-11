From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: gre: minor cleanups in netlink interface
Date: Sat, 11 Oct 2008 23:26:11 +0800
Message-ID: <20081011152611.GC7520@gondor.apana.org.au>
References: <48EF7D24.6040400@trash.net> <20081011103935.GA6168@gondor.apana.org.au> <48F0BB77.6080401@trash.net> <20081011150340.GA7520@gondor.apana.org.au> <48F0C31C.8080501@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:40318 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753935AbYJKP0Q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 11 Oct 2008 11:26:16 -0400
Content-Disposition: inline
In-Reply-To: <48F0C31C.8080501@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Oct 11, 2008 at 05:15:40PM +0200, Patrick McHardy wrote:
>
> We usually use two values (value + mask) for flags.

Aha that should handle it nicely.

>> Also, for ikey/okey we'll need to introduce another attribute to
>> indicate their presence as well as their value.
>
> The flags already indicate whether keys should be used, don't
> they? So if you want to unset them, you can simply unset the
> GRE_KEY flag.

Right if you have the flag then it's not an issue.

> I'll give it a shot and will post a patch, probably tommorrow.

Thanks!

>> Hmm, it seems that there is a bug in how we treat a zero key.
>> You can't have a tunnel with a zero key and one with no key at
>> the same time.
>>
>> In fact my latest iproute patch has a similar problem.  You
>> can't unset the ikey/okey except by deleting the tunnel.  On
>> the other hand the old ip tunnel interface has the same bug :)
>
> I can't find it :)

If you mean the patch, then you're on the cc list :)

If you mean the bug in ip tunnel, I was going by the fact that
there is nothing that unsets the GRE_KEY flag.  Actually let's
not worry about this one too much because you can't unset the
checksum flags either and nobody has complained about either
of these problems for a decade.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
