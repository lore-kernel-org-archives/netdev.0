From: David Miller <davem@davemloft.net>
Subject: Re: [patch net] udp6: respect IPV6_DONTFRAG sockopt in case there
 are pending frames
Date: Wed, 02 Oct 2013 16:00:28 -0400 (EDT)
Message-ID: <20131002.160028.1472026531076506821.davem@davemloft.net>
References: <20130930175640.GF10771@order.stressinduktion.org>
	<20130930212155.GG10771@order.stressinduktion.org>
	<20131001220354.GK10771@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jiri@resnulli.us, netdev@vger.kernel.org, kuznet@ms2.inr.ac.ru,
	jmorris@namei.org, kaber@trash.net, yoshfuji@linux-ipv6.org
To: hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48597 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753527Ab3JBUAb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Oct 2013 16:00:31 -0400
In-Reply-To: <20131001220354.GK10771@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Date: Wed, 2 Oct 2013 00:03:54 +0200

> Hi David!
> 
> On Mon, Sep 30, 2013 at 11:21:55PM +0200, Hannes Frederic Sowa wrote:
>> Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
> 
> (for patchwork correspondence)
> 
> I still think this patch is perfectly fine but it opens up a hole in the
> ip6_append_data logic where it is possible to crash the kernel. Jiri and me
> will look after it in the thread " ipv6: udp packets following an UFO enqueued
> packet need also be handled by UFO".
> 
> So, for the time being, I would like to withdraw my Acked-by until this is
> sorted out.

Jiri please repost the IPV6_DONTFRAG patch once things are sorted, thanks.
