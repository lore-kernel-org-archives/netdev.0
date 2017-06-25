From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 net] net: ipv6: reset daddr and dport in sk if
 connect() fails
Date: Sun, 25 Jun 2017 11:46:51 -0400 (EDT)
Message-ID: <20170625.114651.1973887687669104262.davem@davemloft.net>
References: <20170623222537.130493-1-tracywwnj@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-2
Content-Transfer-Encoding: 8BIT
Cc: netdev@vger.kernel.org, maze@google.com, subashab@codeaurora.org,
        weiwan@google.com
To: tracywwnj@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:40482 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751020AbdFYPq4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 25 Jun 2017 11:46:56 -0400
In-Reply-To: <20170623222537.130493-1-tracywwnj@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Wang <tracywwnj@gmail.com>
Date: Fri, 23 Jun 2017 15:25:37 -0700

> From: Wei Wang <weiwan@google.com>
> 
> In __ip6_datagram_connect(), reset sk->sk_v6_daddr and inet->dport if
> error occurs.
> In udp_v6_early_demux(), check for sk_state to make sure it is in
> TCP_ESTABLISHED state.
> Together, it makes sure unconnected UDP socket won't be considered as a
> valid candidate for early demux.
> 
> Fixes: 5425077d73e0 ("net: ipv6: Add early demux handler for UDP unicast")
> 
> v3: add TCP_ESTABLISHED state check in udp_v6_early_demux()
> v2: fix compilation error
> 
> Signed-off-by: Wei Wang <weiwan@google.com>
> Acked-by: Maciej ¯enczykowski <maze@google.com>

Please don't format the tag area like this, if you want to put a change
log put it first.

Then put all of the tags (Fixes:, Signed-off-by:, Acked-by:, etc.)
together with no empty line separators, at the end.

I fixed it up this time.

Applied and queued up for -stable, thanks.
