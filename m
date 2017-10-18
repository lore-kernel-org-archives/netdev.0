From: Paolo Abeni <pabeni@redhat.com>
Subject: [PATCH net-next v2 0/2] ipv6: fixes for RTF_CACHE entries
Date: Wed, 18 Oct 2017 22:23:30 +0200
Message-ID: <cover.1508358132.git.pabeni@redhat.com>
Cc: "David S. Miller" <davem@davemloft.net>,
        Wei Wang <weiwan@google.com>, Martin KaFai Lau <kafai@fb.com>,
        Eric Dumazet <edumazet@google.com>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:41060 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751769AbdJRUXn (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 18 Oct 2017 16:23:43 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series addresses 3 different but related issues with RTF_CACHE introduced
by the recent refactory.

patch 1 restore the gc timer for such routes
patch 2 removes the aged out dst from the fib tree

v1 -> v2:
 - dropped the  for ip route show cache
 - avoid touching dst.obsolete when the dst is aged out

Paolo Abeni (2):
  ipv6: start fib6 gc on RTF_CACHE dst creation
  ipv6: remove from fib tree aged out RTF_CACHE dst

 net/ipv6/route.c | 11 ++++++++---
 1 file changed, 8 insertions(+), 3 deletions(-)

-- 
2.13.6
