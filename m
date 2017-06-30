From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCH net-next 00/11] sctp: remove typedefs from structures part 1
Date: Fri, 30 Jun 2017 11:52:11 +0800
Message-ID: <cover.1498794481.git.lucien.xin@gmail.com>
Cc: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
        Neil Horman <nhorman@tuxdriver.com>, davem@davemloft.net
To: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:34164 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751722AbdF3Dwg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 29 Jun 2017 23:52:36 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As we know, typedef is suggested not to use in kernel, even checkpatch.pl
also gives warnings about it. Now sctp is using it for many structures.

All this kind of typedef's using should be removed. As the 1st part, this
patchset is to remove it for 11 basic structures in linux/sctp.h. It is
also to fix some indents.

No any code's logic is changed in these patches, only cleaning up.

Xin Long (11):
  sctp: remove the typedef sctp_sctphdr_t
  sctp: remove the typedef sctp_chunkhdr_t
  sctp: remove the typedef sctp_cid_t
  sctp: remove the typedef sctp_cid_action_t
  sctp: remove the typedef sctp_paramhdr_t
  sctp: remove the typedef sctp_param_t
  sctp: remove the typedef sctp_param_action_t
  sctp: remove the typedef sctp_datahdr_t
  sctp: remove the typedef sctp_data_chunk_t
  sctp: remove the typedef sctp_inithdr_t
  sctp: remove the typedef sctp_init_chunk_t

 include/linux/sctp.h                    | 118 ++++++++++++++--------------
 include/net/sctp/auth.h                 |   6 +-
 include/net/sctp/command.h              |   4 +-
 include/net/sctp/constants.h            |   6 +-
 include/net/sctp/sctp.h                 |   4 +-
 include/net/sctp/sm.h                   |  16 ++--
 include/net/sctp/structs.h              |   9 ++-
 net/netfilter/ipset/ip_set_getport.c    |   4 +-
 net/netfilter/ipvs/ip_vs_core.c         |  10 +--
 net/netfilter/ipvs/ip_vs_proto_sctp.c   |  21 +++--
 net/netfilter/nf_conntrack_proto_sctp.c |  33 ++++----
 net/netfilter/nf_nat_proto_sctp.c       |   2 +-
 net/netfilter/xt_sctp.c                 |  20 ++---
 net/sctp/associola.c                    |   6 +-
 net/sctp/auth.c                         |  28 ++++---
 net/sctp/endpointola.c                  |   7 +-
 net/sctp/input.c                        |  24 +++---
 net/sctp/inqueue.c                      |  15 ++--
 net/sctp/output.c                       |   4 +-
 net/sctp/sm_make_chunk.c                |  80 +++++++++----------
 net/sctp/sm_sideeffect.c                |   7 +-
 net/sctp/sm_statefuns.c                 | 132 ++++++++++++++++----------------
 net/sctp/sm_statetable.c                |   4 +-
 net/sctp/socket.c                       |   7 +-
 net/sctp/stream.c                       |   4 +-
 net/sctp/ulpevent.c                     |   2 +-
 net/sctp/ulpqueue.c                     |   2 +-
 27 files changed, 292 insertions(+), 283 deletions(-)

-- 
2.1.0
