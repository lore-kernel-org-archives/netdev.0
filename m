From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: gre: minor cleanups in netlink interface
Date: Sat, 11 Oct 2008 18:39:35 +0800
Message-ID: <20081011103935.GA6168@gondor.apana.org.au>
References: <48EF7D24.6040400@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:53151 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751670AbYJKKjm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 11 Oct 2008 06:39:42 -0400
Content-Disposition: inline
In-Reply-To: <48EF7D24.6040400@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 10, 2008 at 06:04:52PM +0200, Patrick McHardy wrote:
> Some minor cleanups, there doesn't seem to be a reason for not
> using the typeful helpers everywhere.

The reason for that was future IPv6 support.  But I suppose having
it as a be32 for now doesn't prevent us from changing it later, or
does it?

> I noticed the interface expects to always get a full configuration
> on change requests. Is there are particular reason for not
> supporting incremental changes, lets say
>
> "ip link change dev gre0 type gre remote <new remote>"
>
> ? It looks easy enough to change, so I could take care of this.

I think this should be done in iproute.  That way the user (or
rather the user-space programmer) gets to choose the behaviour.
This is also how the existing interface works too.

I'll update the iproute change to do this.

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
