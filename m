From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCH net-next 00/11] sctp: remove typedefs from structures part 3
Date: Sun, 23 Jul 2017 09:34:25 +0800
Message-ID: <cover.1500773578.git.lucien.xin@gmail.com>
Cc: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
        Neil Horman <nhorman@tuxdriver.com>, davem@davemloft.net
To: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:38603 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752080AbdGWBep (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 22 Jul 2017 21:34:45 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As we know, typedef is suggested not to use in kernel, even checkpatch.pl
also gives warnings about it. Now sctp is using it for many structures.

All this kind of typedef's using should be removed. This patchset is the
part 3 to remove it for another 11 basic structures from linux/sctp.h.

Just as the part 1 and 2, No any code's logic would be changed in these
patches, only cleaning up.

Xin Long (11):
  sctp: remove the typedef sctp_initack_chunk_t
  sctp: remove the typedef sctp_cookie_param_t
  sctp: remove the typedef sctp_unrecognized_param_t
  sctp: remove the typedef sctp_gap_ack_block_t
  sctp: remove the typedef sctp_dup_tsn_t
  sctp: remove the typedef sctp_sack_variable_t
  sctp: remove the typedef sctp_sackhdr_t
  sctp: remove the typedef sctp_sack_chunk_t
  sctp: remove the typedef sctp_heartbeathdr_t
  sctp: remove the typedef sctp_heartbeat_chunk_t
  sctp: remove the typedef sctp_abort_chunk_t

 include/linux/sctp.h       | 53 +++++++++++++++++++++++-----------------------
 include/net/sctp/command.h |  4 ++--
 net/sctp/chunk.c           |  2 +-
 net/sctp/outqueue.c        | 10 ++++-----
 net/sctp/sm_make_chunk.c   | 18 +++++++++-------
 net/sctp/sm_statefuns.c    | 50 ++++++++++++++++++++-----------------------
 6 files changed, 68 insertions(+), 69 deletions(-)

-- 
2.1.0
