From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH V2 net-next] net: Cleanup skb cloning by adding
 SKB_FCLONE_FREE
Date: Sat, 04 Oct 2014 20:34:38 -0400 (EDT)
Message-ID: <20141004.203438.1232569604952304673.davem@davemloft.net>
References: <1412269243-5583-1-git-send-email-subramanian.vijay@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, edumazet@google.com
To: subramanian.vijay@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44170 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751033AbaJEAek (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 4 Oct 2014 20:34:40 -0400
In-Reply-To: <1412269243-5583-1-git-send-email-subramanian.vijay@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vijay Subramanian <subramanian.vijay@gmail.com>
Date: Thu,  2 Oct 2014 10:00:43 -0700

> SKB_FCLONE_UNAVAILABLE has overloaded meaning depending on type of skb.
> 1: If skb is allocated from head_cache, it indicates fclone is not available.
> 2: If skb is a companion fclone skb (allocated from fclone_cache), it indicates
> it is available to be used.
> 
> To avoid confusion for case 2 above, this patch  replaces
> SKB_FCLONE_UNAVAILABLE with SKB_FCLONE_FREE where appropriate. For fclone
> companion skbs, this indicates it is free for use.
> 
> SKB_FCLONE_UNAVAILABLE will now simply indicate skb is from head_cache and
> cannot / will not have a companion fclone.
> 
> Signed-off-by: Vijay Subramanian <subramanian.vijay@gmail.com>
> ---
> V1-->V2: Comment all states

Applied, thank you.
