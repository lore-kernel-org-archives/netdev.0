From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] tcp: allow tcp_sacktag_one() to tag ranges not
 aligned with skbs
Date: Mon, 13 Feb 2012 01:00:57 -0500 (EST)
Message-ID: <20120213.010057.1117432957253511382.davem@davemloft.net>
References: <1329107830-3351-1-git-send-email-ncardwell@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ilpo.jarvinen@helsinki.fi,
	nanditad@google.com, ycheng@google.com, therbert@google.com,
	subramanian.vijay@gmail.com
To: ncardwell@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:59305 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750698Ab2BMGBQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Feb 2012 01:01:16 -0500
In-Reply-To: <1329107830-3351-1-git-send-email-ncardwell@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neal Cardwell <ncardwell@google.com>
Date: Sun, 12 Feb 2012 23:37:09 -0500

> This commit allows callers of tcp_sacktag_one() to pass in sequence
> ranges that do not align with skb boundaries, as tcp_shifted_skb()
> needs to do in an upcoming fix in this patch series.
> 
> In fact, now tcp_sacktag_one() does not need to depend on an input skb
> at all, which makes its semantics and dependencies more clear.
> 
> Signed-off-by: Neal Cardwell <ncardwell@google.com>

Applied and queued up for -stable.
