From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v4 3/3] tcp: early retransmit: delayed fast retransmit
Date: Wed, 02 May 2012 20:56:37 -0400 (EDT)
Message-ID: <20120502.205637.19625325390404925.davem@davemloft.net>
References: <1336001404-21879-1-git-send-email-ycheng@google.com>
	<1336001404-21879-3-git-send-email-ycheng@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ilpo.jarvinen@helsinki.fi, ncardwell@google.com,
	nanditad@google.com, netdev@vger.kernel.org
To: ycheng@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:38201 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754802Ab2ECA4r (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 May 2012 20:56:47 -0400
In-Reply-To: <1336001404-21879-3-git-send-email-ycheng@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yuchung Cheng <ycheng@google.com>
Date: Wed,  2 May 2012 16:30:04 -0700

> Implementing the advanced early retransmit (sysctl_tcp_early_retrans==2).
> Delays the fast retransmit by an interval of RTT/4. We borrow the
> RTO timer to implement the delay. If we receive another ACK or send
> a new packet, the timer is cancelled and restored to original RTO
> value offset by time elapsed.  When the delayed-ER timer fires,
> we enter fast recovery and perform fast retransmit.
> 
> Signed-off-by: Yuchung Cheng <ycheng@google.com>

Applied.
