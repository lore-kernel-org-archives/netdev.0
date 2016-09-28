From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCHv2 net 0/5] sctp: some fixes of prsctp polices
Date: Wed, 28 Sep 2016 18:46:27 +0800
Message-ID: <cover.1475059350.git.lucien.xin@gmail.com>
Cc: davem@davemloft.net,
        Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
        Vlad Yasevich <vyasevich@gmail.com>, daniel@iogearbox.net
To: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f67.google.com ([209.85.220.67]:36722 "EHLO
        mail-pa0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752258AbcI1Kqg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 28 Sep 2016 06:46:36 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patchset is to improve some codes about prsctp polices, and also
to fix some issues.

v1->v2:
  - wrap the check of chunk->sent_count in a macro:
    sctp_chunk_retransmitted in patch 2/5.

Xin Long (5):
  sctp: move sent_count to the memory hole in sctp_chunk
  sctp: reuse sent_count to avoid retransmitted chunks for RTT
    measurements
  sctp: remove prsctp_param from sctp_chunk
  sctp: change to check peer prsctp_capable when using prsctp polices
  sctp: remove the old ttl expires policy

 include/net/sctp/structs.h | 16 ++++------------
 net/sctp/chunk.c           | 31 ++++++++++---------------------
 net/sctp/output.c          |  6 ++----
 net/sctp/outqueue.c        | 16 +++++++---------
 net/sctp/sm_make_chunk.c   | 15 ---------------
 5 files changed, 23 insertions(+), 61 deletions(-)

-- 
2.1.0
