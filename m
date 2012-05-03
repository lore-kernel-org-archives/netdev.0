From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] skb: Add skb_head_is_locked helper function
Date: Thu, 03 May 2012 13:23:11 -0400 (EDT)
Message-ID: <20120503.132311.1913257345591054180.davem@davemloft.net>
References: <20120503110942.18281.27820.stgit@gitlad.jf.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeffrey.t.kirsher@intel.com,
	edumazet@google.com
To: alexander.h.duyck@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:45526 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753072Ab2ECRXO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 May 2012 13:23:14 -0400
In-Reply-To: <20120503110942.18281.27820.stgit@gitlad.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>
Date: Thu, 03 May 2012 04:09:42 -0700

> This patch adds support for a skb_head_is_locked helper function.  It is
> meant to be used any time we are considering transferring the head from
> skb->head to a paged frag.  If the head is locked it means we cannot remove
> the head from the skb so it must be copied or we must take the skb as a
> whole.
> 
> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>

Thanks for following up on this instead of going to sleep :-)

Applied.
