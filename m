From: David Miller <davem@davemloft.net>
Subject: Re: [v2 PATCH 2/4] tcp: Move code related to head frag in
 tcp_try_coalesce
Date: Thu, 03 May 2012 04:22:08 -0400 (EDT)
Message-ID: <20120503.042208.77446769957842911.davem@davemloft.net>
References: <20120503071141.13636.37564.stgit@gitlad.jf.intel.com>
	<20120503071904.13636.61130.stgit@gitlad.jf.intel.com>
	<1336031456.3503.24.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: alexander.h.duyck@intel.com, netdev@vger.kernel.org,
	jeffrey.t.kirsher@intel.com, edumazet@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:41088 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753877Ab2ECIWN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 May 2012 04:22:13 -0400
In-Reply-To: <1336031456.3503.24.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 03 May 2012 09:50:56 +0200

> On Thu, 2012-05-03 at 00:19 -0700, Alexander Duyck wrote:
>> This change reorders the code related to the use of an skb->head_frag so it
>> is placed before we check the rest of the frags.  This allows the code to
>> read more linearly instead of like some sort of loop.
>> 
>> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
 ...
> Acked-by: Eric Dumazet <edumazet@google.com>

Applied.
