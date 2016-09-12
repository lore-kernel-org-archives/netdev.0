From: Parthasarathy Bhuvaragan <parthasarathy.bhuvaragan@ericsson.com>
Subject: [PATCH iproute2 net-next v1 0/7] tipc: updates for neighbour monitor
Date: Mon, 12 Sep 2016 17:17:14 +0200
Message-ID: <1473693441-14254-1-git-send-email-parthasarathy.bhuvaragan@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <tipc-discussion@lists.sourceforge.net>, <jon.maloy@ericsson.com>,
        <maloy@donjonn.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sessmg22.ericsson.net ([193.180.251.58]:61441 "EHLO
        sessmg22.ericsson.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932983AbcILPRf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 12 Sep 2016 11:17:35 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We add configuration support for the new link monitoring attributes.

Parthasarathy Bhuvaragan (7):
  tipc: remove dead code
  tipc: add link monitor set threshold
  tipc: add link monitor get threshold
  tipc: add link monitor summary
  tipc: refractor bearer to facilitate link monitor
  tipc: add link monitor list
  tipc: update man page for link monitor

 man/man8/tipc-link.8 | 104 +++++++++++++
 tipc/bearer.c        |  75 ++++++----
 tipc/bearer.h        |   4 +
 tipc/link.c          | 408 ++++++++++++++++++++++++++++++++++++++++++++++++++-
 4 files changed, 556 insertions(+), 35 deletions(-)

-- 
2.1.4
