From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/3] skb: Drop bad code from pskb_expand_head
Date: Sun, 06 May 2012 13:13:37 -0400 (EDT)
Message-ID: <20120506.131337.363109018749374511.davem@davemloft.net>
References: <20120505001059.21292.31647.stgit@gitlad.jf.intel.com>
	<20120505002645.21292.38368.stgit@gitlad.jf.intel.com>
	<1336196130.3752.483.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: alexander.h.duyck@intel.com, netdev@vger.kernel.org,
	jeffrey.t.kirsher@intel.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:41691 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754010Ab2EFRNk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 6 May 2012 13:13:40 -0400
In-Reply-To: <1336196130.3752.483.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Sat, 05 May 2012 07:35:30 +0200

> On Fri, 2012-05-04 at 17:26 -0700, Alexander Duyck wrote:
>> The fast-path for pskb_expand_head contains a check where the size plus the
>> unaligned size of skb_shared_info is compared against the size of the data
>> buffer.  This code path has two issues.  First is the fact that after the
>> recent changes by Eric Dumazet to __alloc_skb and build_skb the shared info
>> is always placed in the optimal spot for a buffer size making this check
>> unnecessary.  The second issue is the fact that the check doesn't take into
>> account the aligned size of shared info.  As a result the code burns cycles
>> doing a memcpy with nothing actually being shifted.
>> 
>> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
 ...
> Acked-by: Eric Dumazet <edumazet@google.com>

Applied.
