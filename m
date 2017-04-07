From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH net-next 3/3] net: dsa: Factor bottom tag receive functions
Date: Fri, 07 Apr 2017 16:54:00 -0400
Message-ID: <8737dkvt07.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
References: <20170407204154.9651-1-f.fainelli@gmail.com> <20170407204154.9651-4-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: davem@davemloft.net, andrew@lunn.ch,
        Florian Fainelli <f.fainelli@gmail.com>
To: Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:42632 "EHLO
        mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756381AbdDGUza (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 7 Apr 2017 16:55:30 -0400
In-Reply-To: <20170407204154.9651-4-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Florian Fainelli <f.fainelli@gmail.com> writes:

> All DSA tag receive functions do strictly the same thing after they have located
> the originating source port from their tag specific protocol:
>
> - push ETH_HLEN bytes
> - set pkt_type to PACKET_HOST
> - call eth_type_trans()
> - bump up counters
> - call netif_receive_skb()
>
> Factor all of that into dsa_switch_rcv(). This also makes us return a pointer to
> a sk_buff, which makes us symetric with the xmit function.
>
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>

Reviewed-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
