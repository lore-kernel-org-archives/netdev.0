From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCH net-next 00/14] sctp: remove typedefs from structures part 6
Date: Fri, 11 Aug 2017 10:23:44 +0800
Message-ID: <cover.1502417340.git.lucien.xin@gmail.com>
Cc: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
        Neil Horman <nhorman@tuxdriver.com>, davem@davemloft.net
To: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:38196 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751439AbdHKCYF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 10 Aug 2017 22:24:05 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As we know, typedef is suggested not to use in kernel, even checkpatch.pl
also gives warnings about it. Now sctp is using it for many structures.

All this kind of typedef's using should be removed. This patchset is the
part 6 to remove all typedefs in include/net/sctp/structs.h, command.h
and sm.h.

Just as the part 1-5, No any code's logic would be changed in these patches,
only cleaning up.

Note that this is the last part for this typedef cleaning up. after this
patchset, no more inappropriate typedefs in sctp. It's also to tidy some
codes when removing them, like fixing many indents, reodering some local
params, especially in the last 2 patches.

Xin Long (14):
  sctp: remove the unused typedef sctp_packet_phandler_t
  sctp: remove the typedef sctp_sender_hb_info_t
  sctp: remove the typedef sctp_endpoint_type_t
  sctp: remove the typedef sctp_cmsgs_t
  sctp: remove the typedef sctp_dbg_objcnt_entry_t
  sctp: remove the typedef sctp_socket_type_t
  sctp: remove the typedef sctp_cmd_t
  sctp: remove the typedef sctp_cmd_seq_t
  sctp: remove the typedef sctp_arg_t
  sctp: remove the typedef sctp_verb_t
  sctp: remove the unused typedef sctp_sm_command_t
  sctp: remove the typedef sctp_sm_table_entry_t
  sctp: remove the typedef sctp_disposition_t
  sctp: fix some indents in sm_make_chunk.c

 include/net/sctp/command.h |   58 +-
 include/net/sctp/sctp.h    |    3 +-
 include/net/sctp/sm.h      |  188 +++---
 include/net/sctp/structs.h |   26 +-
 net/sctp/objcnt.c          |    2 +-
 net/sctp/probe.c           |   13 +-
 net/sctp/sm_make_chunk.c   |  354 ++++++------
 net/sctp/sm_sideeffect.c   |  106 ++--
 net/sctp/sm_statefuns.c    | 1368 +++++++++++++++++++++++---------------------
 net/sctp/sm_statetable.c   |   42 +-
 net/sctp/socket.c          |   16 +-
 11 files changed, 1104 insertions(+), 1072 deletions(-)

-- 
2.1.0
