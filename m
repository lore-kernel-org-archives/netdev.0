From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 0/2] Netfilter/IPVS fixes for net
Date: Tue,  7 Jun 2016 00:38:15 +0200
Message-ID: <1465252697-1986-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:50780 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751973AbcFFWic (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 6 Jun 2016 18:38:32 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
	by mail.us.es (Postfix) with ESMTP id C9036CD6F0F
	for <netdev@vger.kernel.org>; Tue,  7 Jun 2016 00:38:30 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id B92979EBA3
	for <netdev@vger.kernel.org>; Tue,  7 Jun 2016 00:38:30 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id B88B09EBA4
	for <netdev@vger.kernel.org>; Tue,  7 Jun 2016 00:38:25 +0200 (CEST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

The following patchset contains two Netfilter/IPVS fixes for your net
tree, they are:

1) Fix missing alignment in next offset calculation for standard
   targets, introduced in the previous merge window, patch from
   Florian Westphal.

2) Fix to correct the handling of outgoing connections which use the
   SIP-pe such that the binding of a real-server is updated when needed.
   This was an omission from changes introduced by Marco Angaroni in
   the previous merge window too, to allow handling of outgoing
   connections by the SIP-pe. Patch and report came via Simon Horman.

You can pull these changes from:

  git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf.git

Thanks!

----------------------------------------------------------------

The following changes since commit 14b84e8654c89ed59f433654e6bb64c886d095cd:

  qed: fix qed_fill_link() error handling (2016-06-01 22:04:54 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf.git HEAD

for you to fetch changes up to 3ec10d3a2ba591c87da94219c1e46b02ae97757a:

  ipvs: update real-server binding of outgoing connections in SIP-pe (2016-06-06 09:47:25 +0900)

----------------------------------------------------------------
Florian Westphal (1):
      netfilter: x_tables: don't reject valid target size on some architectures

Marco Angaroni (1):
      ipvs: update real-server binding of outgoing connections in SIP-pe

 include/net/ip_vs.h             | 2 +-
 net/netfilter/ipvs/ip_vs_conn.c | 5 +++--
 net/netfilter/ipvs/ip_vs_core.c | 5 +++--
 net/netfilter/x_tables.c        | 4 ++--
 4 files changed, 9 insertions(+), 7 deletions(-)
