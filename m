From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCH net-next 0/2] sctp: improve asoc streams management
Date: Wed, 31 May 2017 16:36:30 +0800
Message-ID: <cover.1496219741.git.lucien.xin@gmail.com>
Cc: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
        Neil Horman <nhorman@tuxdriver.com>, davem@davemloft.net
To: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:36237 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751053AbdEaIgl (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 31 May 2017 04:36:41 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patchset changes to define asoc->stream as an object, and also
improve some codes to make it more clearly.

Xin Long (2):
  sctp: define the member stream as an object instead of pointer in asoc
  sctp: merge sctp_stream_new and sctp_stream_init

 include/net/sctp/structs.h |  7 ++--
 net/sctp/associola.c       | 16 ++++----
 net/sctp/chunk.c           |  4 +-
 net/sctp/outqueue.c        | 10 ++---
 net/sctp/proc.c            |  4 +-
 net/sctp/sm_make_chunk.c   |  5 ++-
 net/sctp/sm_statefuns.c    |  8 ++--
 net/sctp/socket.c          | 14 +++----
 net/sctp/stream.c          | 93 ++++++++++++++++++++--------------------------
 net/sctp/ulpqueue.c        |  8 ++--
 10 files changed, 78 insertions(+), 91 deletions(-)

-- 
2.1.0
