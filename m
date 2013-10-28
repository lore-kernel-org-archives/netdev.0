From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/8] farsync: Fix confusion about DMA address and
 buffer offset types
Date: Mon, 28 Oct 2013 00:59:20 -0400 (EDT)
Message-ID: <20131028.005920.1658700440523107416.davem@davemloft.net>
References: <1382910704.2994.46.camel@deadeye.wl.decadent.org.uk>
	<20131028.002627.2095063739326406659.davem@davemloft.net>
	<1382935885.3524.38.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kevin.curtis@farsite.co.uk, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: ben@decadent.org.uk
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1382935885.3524.38.camel@deadeye.wl.decadent.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ben Hutchings <ben@decadent.org.uk>
Date: Mon, 28 Oct 2013 04:51:25 +0000

> On Mon, 2013-10-28 at 00:26 -0400, David Miller wrote:
>> From: Ben Hutchings <ben@decadent.org.uk>
>> Date: Sun, 27 Oct 2013 21:51:44 +0000
>> 
>> > -     dbg(DBG_TX, "In fst_tx_dma %p %p %d\n", skb, mem, len);
>> > +     dbg(DBG_TX, "In fst_tx_dma %x %x %d\n", (u32)skb, mem, len);
>> 
>> Please use %p for the skb pointer instead of casting it (which btw
>> will introduce a warning on 64-bit).
> 
> skb is the DMA address of the data in the sk_buff.  Yes, this is really
> unusual naming.

Hmmm, Ok then I guess. :-/
