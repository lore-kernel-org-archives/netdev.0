From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: [SCTP PULL Request]: Bug fixes for 2.6.23
Date: Mon, 24 Sep 2007 16:59:25 -0400
Message-ID: <46F8252D.3090803@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	"lksctp-developers@lists.sourceforge.net"
	<lksctp-developers@lists.sourceforge.net>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel9.hp.com ([156.153.255.214]:51598 "EHLO atlrel9.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753245AbXIXU71 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 24 Sep 2007 16:59:27 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi David

Can you please pull the following changes since commit a41d3015c11a4e864b95cb57f579f2d8f40cd41b:
  David S. Miller (1):
        Revert "PCI: disable MSI by default on systems with Serverworks HT1000 chips"

which are available in the git repository at:

  vxy@master.kernel.org:/pub/scm/linux/kernel/git/vxy/lksctp-dev.git master

Vlad Yasevich (4):
      SCTP: Validate buffer room when processing sequential chunks
      SCTP: Explicitly discard OOTB chunks
      SCTP: Clean up OOTB handling and fix infinite loop processing
      SCTP: Discard OOTB packets with bundled INIT early.

Wei Yongjun (2):
      SCTP: Send ABORT chunk with correct tag in response to INIT ACK
      SCTP : Add paramters validity check for ASCONF chunk

 include/net/sctp/sm.h      |    4 +-
 include/net/sctp/structs.h |    1 +
 net/sctp/input.c           |    8 ++
 net/sctp/inqueue.c         |    8 ++
 net/sctp/sm_make_chunk.c   |   46 ++++++++
 net/sctp/sm_statefuns.c    |  243 +++++++++++++++++++++++++++++++++++++-------
 net/sctp/sm_statetable.c   |   16 ++--
 7 files changed, 278 insertions(+), 48 deletions(-)
