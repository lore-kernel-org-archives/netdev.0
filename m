From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH net-next v3 0/4] Some SCTP cleanups/improvements
Date: Fri, 14 Jun 2013 18:24:03 +0200
Message-ID: <1371227047-16852-1-git-send-email-dborkman@redhat.com>
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:54108 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753023Ab3FNQYK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Jun 2013 12:24:10 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

v2 -> v3:
  - Applied feedback from Vlad in first patch, rest is unchanged

v1 -> v2:
  - Applied Neil's feedback, I'll send out the first patch at a later
    point in time though, have not included it in this set
  - Add two other patches that appear to be useful from the last
    couple of days debugging SCTP code

Let it run through lksctp-tools and also my recent stress test tool,
all looks good.

Daniel Borkmann (4):
  net: sctp: sideeffect: throw BUG if primary_path is NULL
  net: sctp: sctp_sf_do_prm_asoc: do SCTP_CMD_INIT_CHOOSE_TRANSPORT first
  net: sctp: minor: remove variable in sctp_init_sock
  net: sctp: sctp_association_init: put refs in reverse order

 net/sctp/associola.c     |  7 +++----
 net/sctp/proc.c          | 19 ++++++++++++++++---
 net/sctp/sm_sideeffect.c |  5 ++++-
 net/sctp/sm_statefuns.c  |  8 ++++----
 net/sctp/socket.c        |  6 ++----
 5 files changed, 29 insertions(+), 16 deletions(-)

-- 
1.7.11.7
