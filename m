From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [Bugme-new] [Bug 11316] New: severe performance regression for iptables nat routing
Date: Sat, 16 Aug 2008 10:25:36 +1000
Message-ID: <20080816002536.GA11019@gondor.apana.org.au>
References: <20080815073343.GA20644@gondor.apana.org.au> <20080815081442.GA20971@gondor.apana.org.au> <20080815103235.GA31963@gondor.apana.org.au> <20080815.135851.231414180.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: alex.williamson@hp.com, kaber@trash.net, akpm@linux-foundation.org,
	buytenh@marvell.com, netdev@vger.kernel.org,
	bugme-daemon@bugzilla.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:33336 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752093AbYHPA0N (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Aug 2008 20:26:13 -0400
Content-Disposition: inline
In-Reply-To: <20080815.135851.231414180.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Aug 15, 2008 at 01:58:51PM -0700, David Miller wrote:
> 
> This, effectively, "enables" LRO on loopback.
> 
> And sure it's pretty obscure to shape, NAT, and end up forwarding
> loopback received packets, but do you want to be the user trying to do
> something like that and trying to find this particular patch which is
> causing it to not work? :-)
> 
> I really don't know whether it's worth worrying about, I just wanted
> to mention it.

Well the same code path is also used by Xen and virtio (apart
from the netfilter bits which caused this particular bug), so
we should be pretty safe here.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
