From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: Vlan interface nuisance
Date: Mon, 2 Mar 2009 14:50:07 +0800
Message-ID: <20090302065007.GA16974@gondor.apana.org.au>
References: <20090301210541.4585c199@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, kaber@trash.net, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:41401 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753343AbZCBGuR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Mar 2009 01:50:17 -0500
Content-Disposition: inline
In-Reply-To: <20090301210541.4585c199@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger <shemminger@vyatta.com> wrote:
>
> Subject: vlan: names should be consistent
> 
> Vlan's created via netlink should be the same as vlan's created
> via older interface. This patches changes is to be consistent.
> 
> One could argue this is an API change (it changes behaviour of netlink
> interface), but I argue this was a design bug when the netlink interface
> to VLAN was added.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

I don't see the point of this.  The new interface is available
through ip(8) only, vconfig remains unchanged.  So the user is
completely aware that the name may change as he's using a new
command.

In any case, ip(8) allows you to set the name to whatever you
want at creation time.  So for those nostalgics you can still
use ethX.Y through ip.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
