From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/3] skb: Drop "fastpath" variable for skb_cloned check
 in pskb_expand_head
Date: Sun, 06 May 2012 13:13:47 -0400 (EDT)
Message-ID: <20120506.131347.877282124188376733.davem@davemloft.net>
References: <20120505001059.21292.31647.stgit@gitlad.jf.intel.com>
	<20120505002651.21292.19680.stgit@gitlad.jf.intel.com>
	<1336196244.3752.484.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: alexander.h.duyck@intel.com, netdev@vger.kernel.org,
	jeffrey.t.kirsher@intel.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:41698 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754010Ab2EFRNv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 6 May 2012 13:13:51 -0400
In-Reply-To: <1336196244.3752.484.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Sat, 05 May 2012 07:37:24 +0200

> On Fri, 2012-05-04 at 17:26 -0700, Alexander Duyck wrote:
>> Since there is now only one spot that actually uses "fastpath" there isn't
>> much point in carrying it.  Instead we can just use a check for skb_cloned
>> to verify if we can perform the fast-path free for the head or not.
>> 
>> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
 ...
> Acked-by: Eric Dumazet <edumazet@google.com>

Applied.
