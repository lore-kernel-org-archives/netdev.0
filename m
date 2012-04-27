From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tcp: clean up use of jiffies in tcp_rcv_rtt_measure()
Date: Fri, 27 Apr 2012 12:35:15 -0400 (EDT)
Message-ID: <20120427.123515.881990026294758581.davem@davemloft.net>
References: <1335540577-32554-1-git-send-email-ncardwell@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, edumazet@google.com, nanditad@google.com,
	ycheng@google.com, ilpo.jarvinen@helsinki.fi, therbert@google.com
To: ncardwell@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:43524 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758980Ab2D0Qf0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Apr 2012 12:35:26 -0400
In-Reply-To: <1335540577-32554-1-git-send-email-ncardwell@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neal Cardwell <ncardwell@google.com>
Date: Fri, 27 Apr 2012 11:29:37 -0400

> Clean up a reference to jiffies in tcp_rcv_rtt_measure() that should
> instead reference tcp_time_stamp. Since the result of the subtraction
> is passed into a function taking u32, this should not change any
> behavior (and indeed the generated assembly does not change on
> x86_64). However, it seems worth cleaning this up for consistency and
> clarity (and perhaps to avoid bugs if this is copied and pasted
> somewhere else).
> 
> Signed-off-by: Neal Cardwell <ncardwell@google.com>

Applied, thanks.
