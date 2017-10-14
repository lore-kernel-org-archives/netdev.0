From: Koichiro Den <den@klaipeden.com>
Subject: [net-next 0/3] optimisations and reorganisations of tcp_collapse
Date: Sat, 14 Oct 2017 16:27:42 +0900
Message-ID: <20171014072745.23462-1-den@klaipeden.com>
Cc: davem@davemloft.net, kuznet@ms2.inr.ac.ru, yoshfuji@linux-ipv6.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from sender-of-o52.zoho.com ([135.84.80.217]:21406 "EHLO
        sender-of-o52.zoho.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751737AbdJNH16 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 14 Oct 2017 03:27:58 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch series removes possible useless copying and collapsing while
not missing the chance when it is worth the effort. Also reorganizes it
and do some cleanups.

Koichiro Den (3):
  tcp: avoid useless copying and collapsing of just one skb
  tcp: do not tcp_collapse once SYN or FIN found
  tcp: keep tcp_collapse controllable even after processing starts

 net/ipv4/tcp_input.c | 193 ++++++++++++++++++++++++---------------------------
 1 file changed, 90 insertions(+), 103 deletions(-)

-- 
2.9.4
