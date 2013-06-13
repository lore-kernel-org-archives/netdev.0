From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH net-next 0/4] Some SCTP cleanups/improvements
Date: Thu, 13 Jun 2013 18:04:19 +0200
Message-ID: <1371139463-12512-1-git-send-email-dborkman@redhat.com>
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:3255 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752081Ab3FMQEZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 Jun 2013 12:04:25 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

v1 -> v2:
  - Apply Neil's feedback, I'll send out the first patch at a later
    point in time though, have not included it in this set
  - Add two other patches that appear to be useful from the last
    couple of days debugging SCTP code

Daniel Borkmann (4):
  net: sctp: throw BUG if primary_path in sctp_seq_dump_local_addrs is NULL
  net: sctp: sctp_sf_do_prm_asoc: do SCTP_CMD_INIT_CHOOSE_TRANSPORT first
  net: sctp: minor: remove variable in sctp_init_sock
  net: sctp: sctp_association_init: put refs in reverse order on error

 net/sctp/associola.c    |  7 +++----
 net/sctp/proc.c         | 15 ++++++++++++---
 net/sctp/sm_statefuns.c |  8 ++++----
 net/sctp/socket.c       |  6 ++----
 4 files changed, 21 insertions(+), 15 deletions(-)

-- 
1.7.11.7
