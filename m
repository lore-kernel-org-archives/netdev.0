From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH v2 net 0/2] ipv6: fix ip6_tnl_parse_tlv_enc_lim() issues
Date: Mon, 23 Jan 2017 16:43:04 -0800
Message-ID: <20170124004306.19236-1-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
        Eric Dumazet <edumazet@google.com>,
        Willem de Bruijn <willemb@google.com>,
        Alexei Starovoitov <ast@kernel.org>,
        Eric Dumazet <eric.dumazet@gmail.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f47.google.com ([74.125.83.47]:34727 "EHLO
        mail-pg0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750715AbdAXAnK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 23 Jan 2017 19:43:10 -0500
Received: by mail-pg0-f47.google.com with SMTP id 14so49308096pgg.1
        for <netdev@vger.kernel.org>; Mon, 23 Jan 2017 16:43:09 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

First patch fixes ip6_tnl_parse_tlv_enc_lim() callers,
bug added in linux-3.7

Second patch fixes ip6_tnl_parse_tlv_enc_lim() itself,
bug predates linux-2.6.12

Based on a report from Dmitry Vyukov, thanks to KASAN.


Eric Dumazet (2):
  ip6_tunnel: must reload ipv6h in ip6ip6_tnl_xmit()
  ipv6: fix ip6_tnl_parse_tlv_enc_lim()

 net/ipv6/ip6_gre.c    |  3 +++
 net/ipv6/ip6_tunnel.c | 36 ++++++++++++++++++++++++------------
 2 files changed, 27 insertions(+), 12 deletions(-)

-- 
2.11.0.483.g087da7b7c-goog
