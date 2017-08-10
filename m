From: Ilya Lesokhin <ilyal@mellanox.com>
Subject: [PATCH 0/3] tls: Use correct sk->sk_prot for IPV6
Date: Thu, 10 Aug 2017 13:33:13 +0300
Message-ID: <1502361196-127278-1-git-send-email-ilyal@mellanox.com>
Cc: davejwatson@fb.com, aviadye@mellanox.com,
        Ilya Lesokhin <ilyal@mellanox.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:33013 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1752461AbdHJKd0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 10 Aug 2017 06:33:26 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix tls code to use the correct sk->sk_prot for IPV6.
Previously it was tcp_prot of IPV4 was used.

Boris Pismenny (1):
  net: Export tcpv6_prot

Ilya Lesokhin (2):
  ipv6: Prevent unexpected sk->sk_prot changes
  tls: Use correct sk->sk_prot for IPV6

 net/ipv6/ipv6_sockglue.c | 12 ++++++++++
 net/ipv6/tcp_ipv6.c      |  1 +
 net/tls/tls_main.c       | 61 ++++++++++++++++++++++++++++++++++++++----------
 3 files changed, 62 insertions(+), 12 deletions(-)

-- 
1.8.3.1
