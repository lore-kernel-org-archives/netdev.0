From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCHv2 net-next 0/3] sctp: prepare asoc stream for stream reconf
Date: Tue,  3 Jan 2017 13:59:45 +0800
Message-ID: <cover.1483422833.git.lucien.xin@gmail.com>
Cc: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
        Neil Horman <nhorman@tuxdriver.com>,
        Vlad Yasevich <vyasevich@gmail.com>, davem@davemloft.net
To: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:34838 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755610AbdACF7z (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 3 Jan 2017 00:59:55 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

sctp stream reconf, described in RFC 6525, needs a structure to
save per stream information in assoc, like stream state.

In the future, sctp stream scheduler also needs it to save some
stream scheduler params and queues.

This patchset is to prepare the stream array in assoc for stream
reconf.

v1->v2:
  put these patches into a smaller group.

Xin Long (3):
  sctp: add stream arrays in asoc
  sctp: replace ssnmap with asoc stream arrays
  sctp: remove asoc ssnmap and ssnmap.c

 include/net/sctp/sctp.h    |   1 -
 include/net/sctp/structs.h |  70 +++++++++----------------
 net/sctp/Makefile          |   3 +-
 net/sctp/associola.c       |  23 ++++++---
 net/sctp/objcnt.c          |   2 -
 net/sctp/sm_make_chunk.c   |  24 ++++++---
 net/sctp/sm_statefuns.c    |   3 +-
 net/sctp/ssnmap.c          | 125 ---------------------------------------------
 net/sctp/ulpqueue.c        |  33 ++++--------
 9 files changed, 69 insertions(+), 215 deletions(-)
 delete mode 100644 net/sctp/ssnmap.c

-- 
2.1.0
