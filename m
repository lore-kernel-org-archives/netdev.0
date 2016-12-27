From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Subject: [PATCH net-next 0/5] SCTP cleanups
Date: Tue, 27 Dec 2016 15:08:27 -0200
Message-ID: <cover.1482857832.git.marcelo.leitner@gmail.com>
Cc: linux-sctp@vger.kernel.org, Vlad Yasevich <vyasevich@gmail.com>,
        Neil Horman <nhorman@tuxdriver.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f193.google.com ([209.85.216.193]:33955 "EHLO
        mail-qt0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752673AbcL0RKe (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 27 Dec 2016 12:10:34 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Some cleanups/simplifications I've been collecting.

Marcelo Ricardo Leitner (5):
  sctp: reduce indent level at sctp_sf_tabort_8_4_8
  sctp: reduce indent level in sctp_sf_shut_8_4_5
  sctp: simplify addr copy
  sctp: remove return value from sctp_packet_init/config
  sctp: sctp_chunk_length_valid should return bool

 include/net/sctp/structs.h |   7 ++-
 net/sctp/ipv6.c            |  16 +++---
 net/sctp/output.c          |  14 ++----
 net/sctp/protocol.c        |  18 +++----
 net/sctp/sm_statefuns.c    | 122 ++++++++++++++++++++++-----------------------
 5 files changed, 81 insertions(+), 96 deletions(-)

-- 
2.9.3
