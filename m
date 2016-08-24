From: Shmulik Ladkani <shmulik.ladkani@gmail.com>
Subject: Re: [PATCH net-next V2 2/4] net/dst: Utility functions to build
 dst_metadata without supplying an skb
Date: Wed, 24 Aug 2016 21:53:03 +0300
Message-ID: <20160824215303.099d7ce9@halley>
References: <20160824122710.30356-1-amir@vadai.me>
        <20160824122710.30356-3-amir@vadai.me>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        Jiri Benc <jbenc@redhat.com>, Jiri Pirko <jiri@mellanox.com>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        Tom Herbert <tom@herbertland.com>,
        Hadar Har-Zion <hadarh@mellanox.com>,
        Or Gerlitz <ogerlitz@mellanox.com>
To: Amir Vadai <amir@vadai.me>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:35836 "EHLO
        mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751676AbcHXTzk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 24 Aug 2016 15:55:40 -0400
Received: by mail-wm0-f68.google.com with SMTP id i5so4173557wmg.2
        for <netdev@vger.kernel.org>; Wed, 24 Aug 2016 12:55:40 -0700 (PDT)
In-Reply-To: <20160824122710.30356-3-amir@vadai.me>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On Wed, 24 Aug 2016 15:27:08 +0300 Amir Vadai <amir@vadai.me> wrote:
> Extract _ip_tun_rx_dst() and _ipv6_tun_rx_dst() out of ip_tun_rx_dst()
> and ipv6_tun_rx_dst(), to be used without supplying an skb.

Additional thing.

In subsequent patches the newly introduced '_ip_tun_rx_dst' and
'_ipv6_tun_rx_dst' are used in a non "rx" context (e.g. for constructing
a IP_TUNNEL_INFO_TX in act_tunnel_key), so the names are misleading.

Consider renaming.
