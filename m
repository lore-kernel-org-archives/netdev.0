From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] tcp: properly account Fast Open SYN-ACK retrans
Date: Thu, 22 Sep 2016 03:33:31 -0400 (EDT)
Message-ID: <20160922.033331.1227668027735387540.davem@davemloft.net>
References: <1474499775-26436-1-git-send-email-ycheng@google.com>
        <1474499775-26436-2-git-send-email-ycheng@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, edumazet@google.com, ncardwell@google.com,
        soheil@google.com
To: ycheng@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:56306 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750881AbcIVHde (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 22 Sep 2016 03:33:34 -0400
In-Reply-To: <1474499775-26436-2-git-send-email-ycheng@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yuchung Cheng <ycheng@google.com>
Date: Wed, 21 Sep 2016 16:16:15 -0700

> Since the TFO socket is accepted right off SYN-data, the socket
> owner can call getsockopt(TCP_INFO) to collect ongoing SYN-ACK
> retransmission or timeout stats (i.e., tcpi_total_retrans,
> tcpi_retransmits). Currently those stats are only updated
> upon handshake completes. This patch fixes it.
> 
> Signed-off-by: Yuchung Cheng <ycheng@google.com>
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Signed-off-by: Neal Cardwell <ncardwell@google.com>
> Signed-off-by: Soheil Hassas Yeganeh <soheil@google.com>

Applied.
