From: Vlad Yasevich <vyasevich@verizon.net>
Subject: [GIT PULL] sctp updates
Date: Thu, 02 Aug 2007 13:55:33 -0400
Message-ID: <46B21A95.80103@verizon.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	lksctp-developers <lksctp-developers@lists.sourceforge.net>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vms046pub.verizon.net ([206.46.252.46]:33947 "EHLO
	vms046pub.verizon.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755443AbXHBRzx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Aug 2007 13:55:53 -0400
Received: from [15.235.249.70] by vms046.mailsrvcs.net
 (Sun Java System Messaging Server 6.2-6.01 (built Apr  3 2006))
 with ESMTPA id <0JM500DKJR4LM4D0@vms046.mailsrvcs.net> for
 netdev@vger.kernel.org; Thu, 02 Aug 2007 12:55:35 -0500 (CDT)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi David

Please pull the following changes since commit fc34f6c617bf2a845d793af12b96bcc0afd472c4:
 Andrew Morton (1):
       Fix up "remove the arm26 port"

which are found in branch 'master' of the git repository at:

 master.kernel.org:/pub/scm/linux/kernel/git/vxy/lksctp-dev.git

Dave Johnson (1):
      SCTP: IPv4 mapped addr not returned in SCTPv6 accept()

Sebastian Siewior (2):
      sctp: try to fix readlock
      sctp: fix shadow symbol in net/sctp/tsnmap.c

Vlad Yasevich (1):
      SCTP: IPv4 mapped addr not returned in SCTPv6 accept()

Wei Yongjun (2):
      SCTP: drop SACK if ctsn is not less than the next tsn of assoc
      SCTP: remove useless code in function sctp_init_cause

sebastian@breakpoint.cc (3):
      sctp: make locally used function static
      sctp: move global declaration to header file.
      sctp: remove shadowed symbols

 include/net/sctp/sctp.h  |   10 ++++
 net/sctp/input.c         |    2 +-
 net/sctp/ipv6.c          |    2 +
 net/sctp/sm_make_chunk.c |    6 ---
 net/sctp/sm_statefuns.c  |  103 ++++++++++++++++++++++++++++++++++-----------
 net/sctp/socket.c        |   45 +++++++++++---------
 net/sctp/tsnmap.c        |   14 +++---
 7 files changed, 123 insertions(+), 59 deletions(-)

Thanks
-vlad


