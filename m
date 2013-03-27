From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH 2/3] net: use the frag lru_lock to protect
 netns_frags.nqueues update
Date: Wed, 27 Mar 2013 13:10:11 -0400 (EDT)
Message-ID: <20130327.131011.171896328243899567.davem@davemloft.net>
References: <20130327155238.15203.6688.stgit@dragon>
	<20130327155530.15203.45784.stgit@dragon>
	<1364401308.15753.23.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: brouer@redhat.com, netdev@vger.kernel.org, fw@strlen.de,
	dborkman@redhat.com, hannes@stressinduktion.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58079 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752138Ab3C0RKO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Mar 2013 13:10:14 -0400
In-Reply-To: <1364401308.15753.23.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 27 Mar 2013 09:21:48 -0700

> On Wed, 2013-03-27 at 16:55 +0100, Jesper Dangaard Brouer wrote:
>> Move the protection of netns_frags.nqueues updates under the LRU_lock,
>> instead of the write lock.  As they are located on the same cacheline,
>> and this is also needed when transitioning to use per hash bucket locking.
>> 
>> Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
>> ---
> 
> Acked-by: Eric Dumazet <edumazet@google.com>

Applied.
