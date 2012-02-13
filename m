From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] tcp: fix range tcp_shifted_skb() passes to
 tcp_sacktag_one()
Date: Mon, 13 Feb 2012 01:01:15 -0500 (EST)
Message-ID: <20120213.010115.212510396679401761.davem@davemloft.net>
References: <1329107830-3351-1-git-send-email-ncardwell@google.com>
	<1329107830-3351-2-git-send-email-ncardwell@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ilpo.jarvinen@helsinki.fi,
	nanditad@google.com, ycheng@google.com, therbert@google.com,
	subramanian.vijay@gmail.com
To: ncardwell@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:59311 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750875Ab2BMGBa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Feb 2012 01:01:30 -0500
In-Reply-To: <1329107830-3351-2-git-send-email-ncardwell@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neal Cardwell <ncardwell@google.com>
Date: Sun, 12 Feb 2012 23:37:10 -0500

> Fix the newly-SACKed range to be the range of newly-shifted bytes.
> 
> Previously - since 832d11c5cd076abc0aa1eaf7be96c81d1a59ce41 -
> tcp_shifted_skb() incorrectly called tcp_sacktag_one() with the start
> and end sequence numbers of the skb it passes in set to the range just
> beyond the range that is newly-SACKed.
> 
> This commit also removes a special-case adjustment to lost_cnt_hint in
> tcp_shifted_skb() since the pre-existing adjustment of lost_cnt_hint
> in tcp_sacktag_one() now properly handles this things now that the
> correct start sequence number is passed in.
> 
> Signed-off-by: Neal Cardwell <ncardwell@google.com>

Looks great, applied and queued up for -stable.
