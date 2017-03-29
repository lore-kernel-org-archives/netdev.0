From: Parthasarathy Bhuvaragan <parthasarathy.bhuvaragan@ericsson.com>
Subject: [PATCH net-next v1 0/2] tipc: add socketpair support
Date: Wed, 29 Mar 2017 11:22:15 +0200
Message-ID: <1490779337-6392-1-git-send-email-parthasarathy.bhuvaragan@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <tipc-discussion@lists.sourceforge.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sesbmg22.ericsson.net ([193.180.251.48]:43961 "EHLO
        sesbmg22.ericsson.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754724AbdC2JWa (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 29 Mar 2017 05:22:30 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We add socketpair support for connection oriented sockets in
the first patch and for connection less in the second.

Erik Hugne (2):
  tipc: add support for stream/seqpacket socketpairs
  tipc: allow rdm/dgram socketpairs

 net/tipc/socket.c | 28 +++++++++++++++++++++++++---
 1 file changed, 25 insertions(+), 3 deletions(-)

-- 
2.1.4
