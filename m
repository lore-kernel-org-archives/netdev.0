From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] tcp: use TS opt on RTTs for congestion control
Date: Fri, 02 Jun 2017 14:19:46 -0400 (EDT)
Message-ID: <20170602.141946.1392617306892884152.davem@davemloft.net>
References: <20170531183053.16602-1-ycheng@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ncardwell@google.com, edumazet@google.com,
        soheil@google.com
To: ycheng@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:46142 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750966AbdFBSTs (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 2 Jun 2017 14:19:48 -0400
In-Reply-To: <20170531183053.16602-1-ycheng@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yuchung Cheng <ycheng@google.com>
Date: Wed, 31 May 2017 11:30:53 -0700

> Currently when a data packet is retransmitted, we do not compute an
> RTT sample for congestion control due to Kern's check. Therefore the
> congestion control that uses RTT signals may not receive any update
> during loss recovery which could last many round trips. For example,
> BBR and Vegas may not be able to update its min RTT estimation if the
> network path has shortened until it recovers from losses. This patch
> mitigates that by using TCP timestamp options for RTT measurement
> for congestion control. Note that we already use timestamps for
> RTT estimation.
> 
> Signed-off-by: Yuchung Cheng <ycheng@google.com>
> Signed-off-by: Soheil Hassas Yeganeh <soheil@google.com>
> Signed-off-by: Neal Cardwell <ncardwell@google.com>
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Also applied, thank you.
