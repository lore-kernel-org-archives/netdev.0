From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCH net 0/5] sctp: some fixes of prsctp polices
Date: Mon, 26 Sep 2016 17:47:49 +0800
Message-ID: <cover.1474883200.git.lucien.xin@gmail.com>
Cc: davem@davemloft.net,
        Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
        Vlad Yasevich <vyasevich@gmail.com>, daniel@iogearbox.net
To: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f67.google.com ([209.85.220.67]:34603 "EHLO
        mail-pa0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1030209AbcIZJr6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 26 Sep 2016 05:47:58 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patchset is to improve some codes about prsctp polices, and also
to fix some issues.

Xin Long (5):
  sctp: move sent_count to the memory hole in sctp_chunk
  sctp: reuse sent_count to avoid retransmitted chunks for RTT
    measurements
  sctp: remove prsctp_param from sctp_chunk
  sctp: change to check peer prsctp_capable when using prsctp polices
  sctp: remove the old ttl expires policy

 include/net/sctp/structs.h | 15 +++------------
 net/sctp/chunk.c           | 31 ++++++++++---------------------
 net/sctp/output.c          |  6 ++----
 net/sctp/outqueue.c        | 16 +++++++---------
 net/sctp/sm_make_chunk.c   | 15 ---------------
 5 files changed, 22 insertions(+), 61 deletions(-)

-- 
2.1.0
