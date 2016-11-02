From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v3 2/2] ip6_udp_tunnel: remove unused IPCB related
 codes
Date: Wed, 02 Nov 2016 15:19:29 -0400 (EDT)
Message-ID: <20161102.151929.363882124050177255.davem@davemloft.net>
References: <20161101154513.30347-1-elicooper@gmx.com>
        <20161101154513.30347-2-elicooper@gmx.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, shmulik.ladkani@gmail.com,
        tom@herbertland.com
To: elicooper@gmx.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:45408 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752815AbcKBTTa (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 2 Nov 2016 15:19:30 -0400
In-Reply-To: <20161101154513.30347-2-elicooper@gmx.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eli Cooper <elicooper@gmx.com>
Date: Tue,  1 Nov 2016 23:45:13 +0800

> Some IPCB fields are currently set in udp_tunnel6_xmit_skb(), which are
> never used before it reaches ip6tunnel_xmit(), and past that point the
> control buffer is no longer interpreted as IPCB.
> 
> This clears these unused IPCB related codes. Currently there is no skb
> scrubbing in ip6_udp_tunnel, otherwise IPCB(skb)->opt might need to be
> cleared for IPv4 packets, as shown in 5146d1f1511
> ("tunnel: Clear IPCB(skb)->opt before dst_link_failure called").
> 
> Signed-off-by: Eli Cooper <elicooper@gmx.com>

Applied.
