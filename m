From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tcp: detect SYN/data drop when F-RTO is disabled
Date: Thu, 31 Jan 2013 14:21:22 -0500 (EST)
Message-ID: <20130131.142122.1136050451546171164.davem@davemloft.net>
References: <1359659806-29556-1-git-send-email-ycheng@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ncardwell@google.com, edumazet@google.com, netdev@vger.kernel.org
To: ycheng@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56636 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753928Ab3AaTV0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Jan 2013 14:21:26 -0500
In-Reply-To: <1359659806-29556-1-git-send-email-ycheng@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yuchung Cheng <ycheng@google.com>
Date: Thu, 31 Jan 2013 11:16:46 -0800

> On receiving the SYN-ACK, Fast Open checks icsk_retransmit for SYN
> retransmission to detect SYN/data drops. But if F-RTO is disabled,
> icsk_retransmit is reset at step D of tcp_fastretrans_alert() (
> under tcp_ack()) before tcp_rcv_fastopen_synack(). The fix is to use
> total_retrans instead which accounts for SYN retransmission regardless
> the use of F-RTO.
> 
> Signed-off-by: Yuchung Cheng <ycheng@google.com>

Applied, thanks.
