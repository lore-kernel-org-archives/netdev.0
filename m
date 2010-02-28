From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [net-next-2.6 PATCH v2] net: consolidate netif_needs_gso()
	checks
Date: Sun, 28 Feb 2010 08:29:53 +0800
Message-ID: <20100228002953.GA6189@gondor.apana.org.au>
References: <20100227001954.32474.62766.stgit@localhost.localdomain> <20100227.032725.158512690.davem@davemloft.net> <20100227155245.GB3176@gondor.apana.org.au> <20100227.081709.10203578.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jeffrey.t.kirsher@intel.com, netdev@vger.kernel.org,
	gospo@redhat.com, john.r.fastabend@intel.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:45106 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1030954Ab0B1A36 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 27 Feb 2010 19:29:58 -0500
Content-Disposition: inline
In-Reply-To: <20100227.081709.10203578.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Feb 27, 2010 at 08:17:09AM -0800, David Miller wrote:
> From: Herbert Xu <herbert@gondor.apana.org.au>
> Date: Sat, 27 Feb 2010 23:52:45 +0800
> 
> > I just did a grep on net/sched and couldn't see anything obvious
> > that uses transport_header.
> 
> I think skb_checksum_help() would be such a use and I
> see a reference in net/sched/sch_netem.c

AFAICS skb_checksum_help uses csum_start and not transport_header.
Has this changed recently?

Once upon a time some drivers used transport_header instead of
csum_start, but even those seem to be gone mostly so one day we
could remove this setting completely.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
