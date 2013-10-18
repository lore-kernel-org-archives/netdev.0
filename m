From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] tcp: remove redundant code in
 __tcp_retransmit_skb()
Date: Fri, 18 Oct 2013 16:22:29 -0400 (EDT)
Message-ID: <20131018.162229.431923064763994923.davem@davemloft.net>
References: <1381941411-30645-1-git-send-email-ncardwell@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, edumazet@google.com, ycheng@google.com
To: ncardwell@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58130 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751735Ab3JRUWb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Oct 2013 16:22:31 -0400
In-Reply-To: <1381941411-30645-1-git-send-email-ncardwell@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neal Cardwell <ncardwell@google.com>
Date: Wed, 16 Oct 2013 12:36:51 -0400

> Remove the specialized code in __tcp_retransmit_skb() that tries to trim
> any ACKed payload preceding a FIN before we retransmit (this was added
> in 1999 in v2.2.3pre3). This trimming code was made unreachable by the
> more general code added above it that uses tcp_trim_head() to trim any
> ACKed payload, with or without a FIN (this was added in "[NET]: Add
> segmentation offload support to TCP." in 2002 circa v2.5.33).
> 
> Signed-off-by: Neal Cardwell <ncardwell@google.com>

Applied, thanks Neal.
