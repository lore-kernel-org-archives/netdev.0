From: Paolo Abeni <pabeni@redhat.com>
Subject: [PATCH net-next 0/3] ipv6: fixes for RTF_CACHE entries
Date: Tue, 17 Oct 2017 19:40:55 +0200
Message-ID: <cover.1508261949.git.pabeni@redhat.com>
Cc: "David S. Miller" <davem@davemloft.net>,
        Wei Wang <weiwan@google.com>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:56372 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753215AbdJQRpb (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 17 Oct 2017 13:45:31 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series addresses 3 different but related issues with RTF_CACHE introduced
by the recent refactory.

patch 1 restore redirect and pmtu route update dump
patch 2 restore the gc timer for such routes
patch 3 obsoletes the dst on removal from exception tables

Paolo Abeni (3):
  ipv6: fix route cache dump
  ipv6: start fib6 gc on RTF_CACHE dst creation
  ipv6: obsolete cached dst when removing them from fib tree

 net/ipv6/route.c | 47 ++++++++++++++++++++++++++++++++++++++++-------
 1 file changed, 40 insertions(+), 7 deletions(-)

-- 
2.13.6
