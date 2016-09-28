From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCHv3 net 0/3] sctp: a bunch of fixes for prsctp polices
Date: Thu, 29 Sep 2016 02:37:25 +0800
Message-ID: <cover.1475087147.git.lucien.xin@gmail.com>
Cc: davem@davemloft.net,
        Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
        Vlad Yasevich <vyasevich@gmail.com>, daniel@iogearbox.net
To: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:32860 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754366AbcI1Shc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 28 Sep 2016 14:37:32 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patchset is to fix 2 issues for prsctp polices:

  1. patch 1 and 2 fix "netperf-Throughput_Mbps -37.2% regression" issue
     when overloading the CPU.

  2. patch 3 fix "prsctp polices should check both sides' prsctp_capable,
     instead of only local side".

Xin Long (3):
  sctp: move sent_count to the memory hole in sctp_chunk
  sctp: remove prsctp_param from sctp_chunk
  sctp: change to check peer prsctp_capable when using prsctp polices

 include/net/sctp/structs.h | 13 +++----------
 net/sctp/chunk.c           | 11 ++++++++---
 net/sctp/outqueue.c        | 12 ++++++------
 net/sctp/sm_make_chunk.c   | 15 ---------------
 4 files changed, 17 insertions(+), 34 deletions(-)

-- 
2.1.0
