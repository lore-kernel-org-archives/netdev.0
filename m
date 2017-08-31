From: Tom Herbert <tom@quantonium.net>
Subject: [PATCH net-next 0/2] flow_dissector: Flow dissector fixes
Date: Thu, 31 Aug 2017 15:22:37 -0700
Message-ID: <20170831222239.21509-1-tom@quantonium.net>
Cc: netdev@vger.kernel.org, alex.popov@linux.com,
        hannes@stressinduktion.org, Tom Herbert <tom@quantonium.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f41.google.com ([74.125.83.41]:38148 "EHLO
        mail-pg0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751755AbdHaWXJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 31 Aug 2017 18:23:09 -0400
Received: by mail-pg0-f41.google.com with SMTP id b8so2693842pgn.5
        for <netdev@vger.kernel.org>; Thu, 31 Aug 2017 15:23:09 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch set fixes some basic issues with __skb_flow_dissect function.

Items addressed:
  - Cleanup control flow in the fucntion; in particular eliminate a
    bunch of goto's and implement a simplified control flow model
  - Add limits for number of encapsulations of extension headers that
    can be dissected

Tested:

Ran normal traffic, GUE, and VXLAN traffic.


Tom Herbert (2):
  flow_dissector: Cleanup control flow
  flow_dissector: Add limits for encapsulation and EH

 include/net/flow_dissector.h |   9 ++
 net/core/flow_dissector.c    | 267 ++++++++++++++++++++++++++++++-------------
 2 files changed, 198 insertions(+), 78 deletions(-)

-- 
2.11.0
