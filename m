From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: pull request: sctp updates for net-next
Date: Wed, 03 Jun 2009 10:33:27 -0400
Message-ID: <4A2689B7.3030101@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux SCTP Dev Mailing list <linux-sctp@vger.kernel.org>
To: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0026.austin.hp.com ([15.216.28.33]:31650 "EHLO
	g1t0026.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753406AbZFCOd0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Jun 2009 10:33:26 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David

The following changes since commit 047584ce94108012288554a5f84585d792cc7f8f:
  Haiying Wang (1):
        net/ucc_geth: Add SGMII support for UEC GETH driver

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/vxy/lksctp-dev.git net-next

Jean-Mickael Guerin (1):
      sctp: fix sack_timeout sysctl min and max types

Vlad Yasevich (1):
      sctp: support non-blocking version of the new sctp_connectx() API

Wei Yongjun (8):
      sctp: fix error cause codes of ADD-IP extension
      sctp: fix report unrecognized parameter in ACSONF-ACK
      sctp: fix the error code when ASCONF is received with invalid address
      sctp: fix a typo in net/sctp/sm_statetable.c
      sctp: fix to only enable IPv6 address support on PF_INET6 socket
      sctp: fix panic when T2-shutdown timer expire on removed transport
      sctp: fix panic when T4-rto timer expire on removed transport
      sctp: fix to choose alternate destination when retransmit ASCONF chunk

 include/linux/sctp.h       |   20 +++++++-------
 include/net/sctp/structs.h |    6 +---
 include/net/sctp/user.h    |    2 +
 net/sctp/associola.c       |   64 +++++++++++++++++++------------------------
 net/sctp/sm_make_chunk.c   |   16 +++++-----
 net/sctp/sm_sideeffect.c   |    8 +++--
 net/sctp/sm_statefuns.c    |   14 +++++++---
 net/sctp/sm_statetable.c   |    2 +-
 net/sctp/socket.c          |   42 ++++++++++++++++++++++++++++-
 net/sctp/sysctl.c          |    6 ++--
 10 files changed, 110 insertions(+), 70 deletions(-)


Please pull into net-next-2.6.

Thanks
-vlad
