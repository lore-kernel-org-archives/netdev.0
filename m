From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] gro: Handle inline VLAN tags
Date: Mon, 19 Nov 2012 19:10:02 -0500 (EST)
Message-ID: <20121119.191002.1995098917961576324.davem@davemloft.net>
References: <1353111414.10798.64.camel@edumazet-glaptop>
	<1353112324.2743.81.camel@bwh-desktop.uk.solarflarecom.com>
	<1353114559.10798.66.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bhutchings@solarflare.com, netdev@vger.kernel.org,
	linux-net-drivers@solarflare.com, gallatin@myri.com,
	herbert@gondor.apana.org.au
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34798 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753236Ab2KTAKE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Nov 2012 19:10:04 -0500
In-Reply-To: <1353114559.10798.66.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 16 Nov 2012 17:09:19 -0800

> On Sat, 2012-11-17 at 00:32 +0000, Ben Hutchings wrote:
>> On Fri, 2012-11-16 at 16:16 -0800, Eric Dumazet wrote:
>> > On Sat, 2012-11-17 at 00:00 +0000, Ben Hutchings wrote:
>> > 
>> > > I'm not sure what you mean by this.  Is your point that the
>> > > copy-on-write is never needed?  It is still possible for pskb_may_pull()
>> > > to fail.
>> > > 
>> > 
>> > A packet sniffer should have a copy of bad frames, even if dropped later
>> > in our stacks.
>> > 
>> > GRO layer is not allowed to drop a frame, even if not 'correct'.
>> 
>> What do you think the accelerated hardware does with frames that have a
>> truncated VLAN tag?
> 
> The hardware should send us the frame, exactly like when RX checksum is
> wrong.

I agree with Eric, and therefore will not apply this patch.
