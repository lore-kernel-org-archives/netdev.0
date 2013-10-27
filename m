From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] tcp: fix SYNACK RTT estimation in Fast Open
Date: Sun, 27 Oct 2013 16:51:27 -0400 (EDT)
Message-ID: <20131027.165127.1930968854676042241.davem@davemloft.net>
References: <1382629465-20310-1-git-send-email-ycheng@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ncardwell@google.com, edumazet@google.com, panweiping3@gmail.com,
	netdev@vger.kernel.org
To: ycheng@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53873 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754164Ab3J0Uv2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 27 Oct 2013 16:51:28 -0400
In-Reply-To: <1382629465-20310-1-git-send-email-ycheng@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yuchung Cheng <ycheng@google.com>
Date: Thu, 24 Oct 2013 08:44:25 -0700

> tp->lsndtime may not always be the SYNACK timestamp if a passive
> Fast Open socket sends data before handshake completes. And if the
> remote acknowledges both the data and the SYNACK, the RTT sample
> is already taken in tcp_ack(), so no need to call
> tcp_update_ack_rtt() in tcp_synack_rtt_meas() aagain.
> 
> Signed-off-by: Yuchung Cheng <ycheng@google.com>

Applied and queued up for -stable.
