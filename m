From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] inet: limit length of fragment queue hash table
 bucket lists
Date: Tue, 19 Mar 2013 10:29:24 -0400 (EDT)
Message-ID: <20130319.102924.1157536946553626661.davem@davemloft.net>
References: <20130315213230.GB24041@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com, jbrouer@redhat.com
To: hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43221 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756501Ab3CSO30 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Mar 2013 10:29:26 -0400
In-Reply-To: <20130315213230.GB24041@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Date: Fri, 15 Mar 2013 22:32:30 +0100

> This patch introduces a constant limit of the fragment queue hash
> table bucket list lengths. Currently the limit 128 is choosen somewhat
> arbitrary and just ensures that we can fill up the fragment cache with
> empty packets up to the default ip_frag_high_thresh limits. It should
> just protect from list iteration eating considerable amounts of cpu.
> 
> If we reach the maximum length in one hash bucket a warning is printed.
> This is implemented on the caller side of inet_frag_find to distinguish
> between the different users of inet_fragment.c.
> 
> I dropped the out of memory warning in the ipv4 fragment lookup path,
> because we already get a warning by the slab allocator.
> 
> Cc: Eric Dumazet <eric.dumazet@gmail.com>
> Cc: Jesper Dangaard Brouer <jbrouer@redhat.com>
> Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>

Applied and queued up for -stable, thanks.
