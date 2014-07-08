From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] tcp: switch snt_synack back to measuring
 transmit time of first SYNACK
Date: Mon, 07 Jul 2014 19:26:52 -0700 (PDT)
Message-ID: <20140707.192652.2078847253054450980.davem@davemloft.net>
References: <1404155389-22927-1-git-send-email-ncardwell@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ycheng@google.com,
	octavian.purdila@intel.com, hkchu@google.com
To: ncardwell@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48302 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752230AbaGHC0x (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Jul 2014 22:26:53 -0400
In-Reply-To: <1404155389-22927-1-git-send-email-ncardwell@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neal Cardwell <ncardwell@google.com>
Date: Mon, 30 Jun 2014 15:09:49 -0400

> Always store in snt_synack the time at which the server received the
> first client SYN and attempted to send the first SYNACK.
> 
> Recent commit aa27fc501 ("tcp: tcp_v[46]_conn_request: fix snt_synack
> initialization") resolved an inconsistency between IPv4 and IPv6 in
> the initialization of snt_synack. This commit brings back the idea
> from 843f4a55e (tcp: use tcp_v4_send_synack on first SYN-ACK), which
> was going for the original behavior of snt_synack from the commit
> where it was added in 9ad7c049f0f79 ("tcp: RFC2988bis + taking RTT
> sample from 3WHS for the passive open side") in v3.1.
> 
> In addition to being simpler (and probably a tiny bit faster),
> unconditionally storing the time of the first SYNACK attempt has been
> useful because it allows calculating a performance metric quantifying
> how long it took to establish a passive TCP connection.
> 
> Signed-off-by: Neal Cardwell <ncardwell@google.com>
> Signed-off-by: Yuchung Cheng <ycheng@google.com>

Applied, thanks.
