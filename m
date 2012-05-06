From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/3] skb: Add inline helper for getting the skb end
 offset from head
Date: Sun, 06 May 2012 13:13:55 -0400 (EDT)
Message-ID: <20120506.131355.715946277868436740.davem@davemloft.net>
References: <20120505001059.21292.31647.stgit@gitlad.jf.intel.com>
	<20120505002656.21292.89799.stgit@gitlad.jf.intel.com>
	<1336196361.3752.485.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: alexander.h.duyck@intel.com, netdev@vger.kernel.org,
	jeffrey.t.kirsher@intel.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:41705 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754010Ab2EFRN6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 6 May 2012 13:13:58 -0400
In-Reply-To: <1336196361.3752.485.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Sat, 05 May 2012 07:39:21 +0200

> On Fri, 2012-05-04 at 17:26 -0700, Alexander Duyck wrote:
>> With the recent changes for how we compute the skb truesize it occurs to me
>> we are probably going to have a lot of calls to skb_end_pointer -
>> skb->head.  Instead of running all over the place doing that it would make
>> more sense to just make it a separate inline skb_end_offset(skb) that way
>> we can return the correct value without having gcc having to do all the
>> optimization to cancel out skb->head - skb->head.
>> 
>> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
 ...
> Acked-by: Eric Dumazet <edumazet@google.com>

Applied.
