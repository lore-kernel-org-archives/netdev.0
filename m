From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: gre: minor cleanups in netlink interface
Date: Sat, 11 Oct 2008 23:18:20 +0800
Message-ID: <20081011151820.GB7520@gondor.apana.org.au>
References: <48EF7D24.6040400@trash.net> <20081011103935.GA6168@gondor.apana.org.au> <48F0BB77.6080401@trash.net> <48F0BC1C.5020005@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:46574 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752442AbYJKPS0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 11 Oct 2008 11:18:26 -0400
Content-Disposition: inline
In-Reply-To: <48F0BC1C.5020005@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Oct 11, 2008 at 04:45:48PM +0200, Patrick McHardy wrote:
>
> Its actually also what defines the difference between using
> NLM_F_REPLACE (ip link replace) and no flags (ip link change).
> The former replaces the replaces the object, the later changes
> an existing object.

That wasn't the case historically.  For routing NLM_F_REPLACE
had a real meaning because you can have routes that differ only
by scope.  So if you considered routes that are otherwise the
same to be duplicate routes, then NLM_F_REPLACE tells you whether
you're allowed to create a new route or you must modify one
of the existing ones.  Of course completely duplicate routes
where everything is equal is not allowed.

Of course NLM_F_REPLACE has since been seconded for other purposes
so I suppose it can mean whatever you want for rtnl link :)

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
