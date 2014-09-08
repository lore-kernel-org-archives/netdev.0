From: Tom Herbert <therbert@google.com>
Subject: [PATCH net-next 0/5] net: Changes to GRO for encapsulation
Date: Sun,  7 Sep 2014 22:26:24 -0700
Message-ID: <1410153989-23837-1-git-send-email-therbert@google.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f170.google.com ([209.85.192.170]:64993 "EHLO
	mail-pd0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751202AbaIHF0y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Sep 2014 01:26:54 -0400
Received: by mail-pd0-f170.google.com with SMTP id r10so20088623pdi.29
        for <netdev@vger.kernel.org>; Sun, 07 Sep 2014 22:26:53 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch set has some fixes for encapsulation and GRO.

Tom Herbert (5):
  net: Fix GRE RX to use skb_transport_header for GRE header offset
  ipip: Add gro callbacks to ipip offload
  sit: Add gro callbacks to sit offload
  udp: Add try convert checksum is case of skb_steal_sock
  net: Export inet_offloads and inet6_offloads

 net/ipv4/af_inet.c     | 2 ++
 net/ipv4/gre_demux.c   | 5 ++---
 net/ipv4/protocol.c    | 1 +
 net/ipv4/udp.c         | 4 ++++
 net/ipv6/ip6_offload.c | 2 ++
 net/ipv6/protocol.c    | 1 +
 6 files changed, 12 insertions(+), 3 deletions(-)

-- 
2.1.0.rc2.206.gedb03e5
