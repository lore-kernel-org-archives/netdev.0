From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 2/2] tcp: mark skbs with SCM_TIMESTAMPING_OPT_STATS
Date: Tue, 21 Mar 2017 18:45:05 -0700 (PDT)
Message-ID: <20170321.184505.1293299114093848920.davem@davemloft.net>
References: <20170318210300.163288-1-soheil.kdev@gmail.com>
        <20170318210300.163288-2-soheil.kdev@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, zzoru007@gmail.com, soheil@google.com,
        edumazet@google.com, willemb@google.com
To: soheil.kdev@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:59838 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756711AbdCVBpM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 21 Mar 2017 21:45:12 -0400
In-Reply-To: <20170318210300.163288-2-soheil.kdev@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Soheil Hassas Yeganeh <soheil.kdev@gmail.com>
Date: Sat, 18 Mar 2017 17:03:00 -0400

> From: Soheil Hassas Yeganeh <soheil@google.com>
> 
> SOF_TIMESTAMPING_OPT_STATS can be enabled and disabled
> while packets are collected on the error queue.
> So, checking SOF_TIMESTAMPING_OPT_STATS in sk->sk_tsflags
> is not enough to safely assume that the skb contains
> OPT_STATS data.
> 
> Add a bit in sock_exterr_skb to indicate whether the
> skb contains opt_stats data.
> 
> Fixes: 1c885808e456 ("tcp: SOF_TIMESTAMPING_OPT_STATS option for SO_TIMESTAMPING")
> Reported-by: JongHwan Kim <zzoru007@gmail.com>
> Signed-off-by: Soheil Hassas Yeganeh <soheil@google.com>
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Signed-off-by: Willem de Bruijn <willemb@google.com>

Also applied and queued up for -stable.
