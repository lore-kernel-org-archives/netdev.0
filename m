From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] packet: avoid panic in packet_getsockopt()
Date: Sat, 21 Oct 2017 01:50:08 +0100 (WEST)
Message-ID: <20171021.015008.162706023967923091.davem@davemloft.net>
References: <1508364504.31614.150.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, willemb@google.com, edumazet@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:45874 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752971AbdJUAuM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 20 Oct 2017 20:50:12 -0400
In-Reply-To: <1508364504.31614.150.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 18 Oct 2017 15:08:24 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> syzkaller got crashes in packet_getsockopt() processing
> PACKET_ROLLOVER_STATS command while another thread was managing
> to change po->rollover
> 
> Using RCU will fix this bug. We might later add proper RCU annotations
> for sparse sake.
> 
> Fixes: a9b6391814d5 ("packet: rollover statistics")
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied and queued up for -stable, but:

> Willem de Bruijn <willemb@google.com>

I didn't know what kind of tag you intended to use here for Willem
so just deleted the line.
