From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: [GIT PATCHES] SCTP fixes
Date: Thu, 28 Jun 2007 10:34:57 -0400
Message-ID: <11830412972450-git-send-email-vladislav.yasevich@hp.com>
Cc: lksctp-developers@lists.sourceforge.net, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel6.hp.com ([156.153.255.205]:39664 "EHLO atlrel6.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755891AbXF1OfP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 Jun 2007 10:35:15 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Hi David

Please pull the following changes:

The following changes since commit 19e6454ca778e11e81497bd87c930dc0defd03d7:
  David Howells (1):
        [AF_RXRPC]: Return the number of bytes buffered in rxrpc_send_data()

are found in the git repository at:

  master.kernel.org:/pub/scm/linux/kernel/git/vxy/lksctp-dev.git

Neil Horman (2):
      SCTP: update sctp_getsockopt helpers to allow oversized buffers
      SCTP: Fix sctp_getsockopt_get_peer_addrs

Zach Brown (1):
      SCTP: lock_sock_nested in sctp_sock_migrate

 net/sctp/socket.c |  120 +++++++++++++++++++++++++++++++++++-----------------
 1 files changed, 81 insertions(+), 39 deletions(-)

Thanks
-vlad
