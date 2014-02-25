From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] ipv6: reuse ip6_frag_id from ip6_ufo_append_data
Date: Tue, 25 Feb 2014 14:09:11 -0500 (EST)
Message-ID: <20140225.140911.2000856357656473477.davem@davemloft.net>
References: <20140221015535.GB28822@order.stressinduktion.org>
	<20140222.002855.2055879239461145413.davem@davemloft.net>
	<20140222055231.GA6598@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57125 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752844AbaBYTJQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Feb 2014 14:09:16 -0500
In-Reply-To: <20140222055231.GA6598@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Date: Sat, 22 Feb 2014 06:52:31 +0100

> Hi David!
> 
> On Sat, Feb 22, 2014 at 12:28:55AM -0500, David Miller wrote:
>> From: Hannes Frederic Sowa <hannes@stressinduktion.org>
>> Date: Fri, 21 Feb 2014 02:55:35 +0100
>> 
>> > Currently we generate a new fragmentation id on UFO segmentation. It
>> > is pretty hairy to identify the correct net namespace and dst there.
>> > Especially tunnels use IFF_XMIT_DST_RELEASE and thus have no skb_dst
>> > available at all.
>> > 
>> > This causes unreliable or very predictable ipv6 fragmentation id
>> > generation while segmentation.
>> > 
>> > Luckily we already have pregenerated the ip6_frag_id in
>> > ip6_ufo_append_data and can use it here.
>> > 
>> > Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
>> 
>> Applied, thanks Hannes.
> 
> Could you also get this at least into 3.13, as sit tunnels enable gso
> by default there?

Queueud up for -stable, thanks Hannes.
