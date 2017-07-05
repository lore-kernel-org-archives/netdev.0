From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCH net-next 00/11] sctp: remove typedefs from structures part 2
Date: Wed,  5 Jul 2017 08:32:18 +0800
Message-ID: <cover.1499214692.git.lucien.xin@gmail.com>
Cc: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
        Neil Horman <nhorman@tuxdriver.com>, davem@davemloft.net
To: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:36311 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752229AbdGEAci (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 4 Jul 2017 20:32:38 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As we know, typedef is suggested not to use in kernel, even checkpatch.pl
also gives warnings about it. Now sctp is using it for many structures.

All this kind of typedef's using should be removed. This patchset is the
part 2 to remove it for another 11 basic structures.

Just as the part 1, No any code's logic would be changed in these patches,
only cleaning up.

Xin Long (11):
  sctp: remove the typedef sctp_ipv4addr_param_t
  sctp: remove the typedef sctp_ipv6addr_param_t
  sctp: remove the typedef sctp_cookie_preserve_param_t
  sctp: remove the typedef sctp_hostname_param_t
  sctp: remove the typedef sctp_supported_addrs_param_t
  sctp: remove struct sctp_ecn_capable_param
  sctp: remove the typedef sctp_adaptation_ind_param_t
  sctp: remove the typedef sctp_supported_ext_param_t
  sctp: remove the typedef sctp_random_param_t
  sctp: remove the typedef sctp_chunks_param_t
  sctp: remove the typedef sctp_hmac_algo_param_t

 include/linux/sctp.h       | 49 +++++++++++++++++++++-------------------------
 include/net/sctp/structs.h |  6 +++---
 net/sctp/auth.c            | 13 ++++++------
 net/sctp/endpointola.c     |  8 ++++----
 net/sctp/ipv6.c            |  2 +-
 net/sctp/protocol.c        |  2 +-
 net/sctp/sm_make_chunk.c   | 32 ++++++++++++------------------
 net/sctp/sm_statefuns.c    | 11 +++++------
 8 files changed, 55 insertions(+), 68 deletions(-)

-- 
2.1.0
