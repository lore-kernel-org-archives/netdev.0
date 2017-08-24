From: Parthasarathy Bhuvaragan <parthasarathy.bhuvaragan@ericsson.com>
Subject: [PATCH net v1 0/3] tipc: buffer reassignment fixes
Date: Thu, 24 Aug 2017 16:31:21 +0200
Message-ID: <1503585084-14079-1-git-send-email-parthasarathy.bhuvaragan@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <tipc-discussion@lists.sourceforge.net>,
        <jon.maloy@ericsson.com>, <maloy@donjonn.com>,
        <ying.xue@windriver.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sessmg22.ericsson.net ([193.180.251.58]:42381 "EHLO
        sessmg22.ericsson.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753228AbdHXObb (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 24 Aug 2017 10:31:31 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains fixes for buffer reassignments and a context imbalance.

Parthasarathy Bhuvaragan (3):
  tipc: perform skb_linearize() before parsing the inner header
  tipc: reassign pointers after skb reallocation / linearization
  tipc: context imbalance at node read unlock

 net/tipc/msg.c  | 7 +++++--
 net/tipc/node.c | 4 +++-
 2 files changed, 8 insertions(+), 3 deletions(-)

-- 
2.1.4
