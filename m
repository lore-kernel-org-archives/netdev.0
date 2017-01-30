From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/2] tcp: record pkts sent and retransmistted
Date: Sun, 29 Jan 2017 19:17:34 -0500 (EST)
Message-ID: <20170129.191734.2105157180908856084.davem@davemloft.net>
References: <20170128002439.128487-1-ycheng@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ncardwell@google.com, edumazet@google.com,
        soheil@google.com
To: ycheng@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:42776 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751688AbdA3ARm (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 29 Jan 2017 19:17:42 -0500
In-Reply-To: <20170128002439.128487-1-ycheng@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yuchung Cheng <ycheng@google.com>
Date: Fri, 27 Jan 2017 16:24:38 -0800

> Add two stats in SCM_TIMESTAMPING_OPT_STATS:
> 
> TCP_NLA_DATA_SEGS_OUT: total data packets sent including retransmission
> TCP_NLA_TOTAL_RETRANS: total data packets retransmitted
> 
> The names are picked to be consistent with corresponding fields in
> TCP_INFO. This allows applications that are using the timestamping
> API to measure latency stats to also retrive retransmission rate
> of application write.
> 
> Signed-off-by: Yuchung Cheng <ycheng@google.com>
> Signed-off-by: Soheil Hassas Yeganeh <soheil@google.com>
> Acked-by: Neal Cardwell <ncardwell@google.com>
> Acked-by: Eric Dumazet <edumazet@google.com>

Applied.
