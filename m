From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 1/2] tcp: fix lost retransmit SNMP under-counting
Date: Wed, 05 Apr 2017 18:41:54 -0700 (PDT)
Message-ID: <20170405.184154.39729061470566665.davem@davemloft.net>
References: <20170404211540.47887-1-ycheng@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ncardwell@google.com, edumazet@google.com,
        soheil@google.com
To: ycheng@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:49012 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756315AbdDFBl4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 5 Apr 2017 21:41:56 -0400
In-Reply-To: <20170404211540.47887-1-ycheng@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yuchung Cheng <ycheng@google.com>
Date: Tue,  4 Apr 2017 14:15:39 -0700

> The lost retransmit SNMP stat is under-counting retransmission
> that uses segment offloading. This patch fixes that so all
> retransmission related SNMP counters are consistent.
> 
> Fixes: 10d3be569243 ("tcp-tso: do not split TSO packets at retransmit time")
> Signed-off-by: Yuchung Cheng <ycheng@google.com>
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Signed-off-by: Neal Cardwell <ncardwell@google.com>
> Signed-off-by: Soheil Hassas Yeganeh <soheil@google.com>

Applied.
