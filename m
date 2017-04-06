From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: ipv4: fix multipath RTM_GETROUTE behavior when
 iif is given
Date: Thu, 06 Apr 2017 12:19:43 -0700 (PDT)
Message-ID: <20170406.121943.2291300582139303531.davem@davemloft.net>
References: <20170403144609.18716-1-fl@n621.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: fl@n621.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:36594 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756503AbdDFTTs (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 6 Apr 2017 15:19:48 -0400
In-Reply-To: <20170403144609.18716-1-fl@n621.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Larysch <fl@n621.de>
Date: Mon,  3 Apr 2017 16:46:09 +0200

> inet_rtm_getroute synthesizes a skeletal ICMP skb, which is passed to
> ip_route_input when iif is given. If a multipath route is present for
> the designated destination, ip_multipath_icmp_hash ends up being called,
> which uses the source/destination addresses within the skb to calculate
> a hash. However, those are not set in the synthetic skb, causing it to
> return an arbitrary and incorrect result.
> 
> Instead, use UDP, which gets no such special treatment.
> 
> Signed-off-by: Florian Larysch <fl@n621.de>

Applied and queued up for -stable.

Please submit the net-next variant you mentioned, thank you.
