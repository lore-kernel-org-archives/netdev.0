From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH v2] net: consolidate netif_needs_gso()
 checks
Date: Sun, 28 Feb 2010 00:29:42 -0800 (PST)
Message-ID: <20100228.002942.28812162.davem@davemloft.net>
References: <20100227155245.GB3176@gondor.apana.org.au>
	<20100227.081709.10203578.davem@davemloft.net>
	<20100228002953.GA6189@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeffrey.t.kirsher@intel.com, netdev@vger.kernel.org,
	gospo@redhat.com, john.r.fastabend@intel.com
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33178
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1031531Ab0B1I3Y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 Feb 2010 03:29:24 -0500
In-Reply-To: <20100228002953.GA6189@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Sun, 28 Feb 2010 08:29:53 +0800

> On Sat, Feb 27, 2010 at 08:17:09AM -0800, David Miller wrote:
>> From: Herbert Xu <herbert@gondor.apana.org.au>
>> Date: Sat, 27 Feb 2010 23:52:45 +0800
>> 
>> > I just did a grep on net/sched and couldn't see anything obvious
>> > that uses transport_header.
>> 
>> I think skb_checksum_help() would be such a use and I
>> see a reference in net/sched/sch_netem.c
> 
> AFAICS skb_checksum_help uses csum_start and not transport_header.
> Has this changed recently?
> 
> Once upon a time some drivers used transport_header instead of
> csum_start, but even those seem to be gone mostly so one day we
> could remove this setting completely.

Ok, then this clears up all of my concerns.  Thanks Herbert.
