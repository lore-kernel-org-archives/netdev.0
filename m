From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tcp: fix tcp_shifted_skb() adjustment of lost_cnt_hint
 for FACK
Date: Tue, 14 Feb 2012 14:40:33 -0500 (EST)
Message-ID: <20120214.144033.848861752845052421.davem@davemloft.net>
References: <1329200528-19718-1-git-send-email-ncardwell@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ilpo.jarvinen@helsinki.fi,
	nanditad@google.com, ycheng@google.com, therbert@google.com,
	subramanian.vijay@gmail.com
To: ncardwell@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:48506 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757010Ab2BNTkr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Feb 2012 14:40:47 -0500
In-Reply-To: <1329200528-19718-1-git-send-email-ncardwell@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neal Cardwell <ncardwell@google.com>
Date: Tue, 14 Feb 2012 01:22:08 -0500

> This commit ensures that lost_cnt_hint is correctly updated in
> tcp_shifted_skb() for FACK TCP senders. The lost_cnt_hint adjustment
> in tcp_sacktag_one() only applies to non-FACK senders, so FACK senders
> need their own adjustment.
> 
> This applies the spirit of 1e5289e121372a3494402b1b131b41bfe1cf9b7f -
> except now that the sequence range passed into tcp_sacktag_one() is
> correct we need only have a special case adjustment for FACK.
> 
> Signed-off-by: Neal Cardwell <ncardwell@google.com>

Applied, and queued up for -stable, thanks Neil.
