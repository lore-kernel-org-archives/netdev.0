From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tcp: fix comment for tp->highest_sack
Date: Mon, 27 Feb 2012 17:53:02 -0500 (EST)
Message-ID: <20120227.175302.1770614594950704120.davem@davemloft.net>
References: <1330383070-10367-1-git-send-email-ncardwell@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ilpo.jarvinen@helsinki.fi,
	nanditad@google.com, ycheng@google.com, therbert@google.com
To: ncardwell@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:37688 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754945Ab2B0WxO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Feb 2012 17:53:14 -0500
In-Reply-To: <1330383070-10367-1-git-send-email-ncardwell@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neal Cardwell <ncardwell@google.com>
Date: Mon, 27 Feb 2012 17:51:10 -0500

> There was an off-by-one error in the comments describing the
> highest_sack field in struct tcp_sock. The comments previously claimed
> that it was the "start sequence of the highest skb with SACKed
> bit". This commit fixes the comments to note that it is the "start
> sequence of the skb just *after* the highest skb with SACKed bit".
> 
> Signed-off-by: Neal Cardwell <ncardwell@google.com>

Applied, thanks Neal.
