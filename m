From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 0/3] Netfilter fixes for net
Date: Mon,  9 May 2016 21:52:00 +0200
Message-ID: <1462823523-6682-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:53581 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751297AbcEITwO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 9 May 2016 15:52:14 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
	by mail.us.es (Postfix) with ESMTP id A9F73EAA6D
	for <netdev@vger.kernel.org>; Mon,  9 May 2016 21:52:11 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id 96C77134714
	for <netdev@vger.kernel.org>; Mon,  9 May 2016 21:52:11 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id 5810AFAB44
	for <netdev@vger.kernel.org>; Mon,  9 May 2016 21:52:07 +0200 (CEST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

The following patchset contain Netfilter simple fixes for your net tree,
two one-liner and one two-liner:

1) Oneliner to fix missing spinlock definition that triggers
   'BUG: spinlock bad magic on CPU#' when spinlock debugging is enabled,
   from Florian Westphal.

2) Fix missing workqueue cancelation on IDLETIMER removal,
   from Liping Zhang.

3) Fix insufficient validation of netlink of NFACCT_QUOTA in
   nfnetlink_acct, from Phil Turnbull.

You can pull these changes from:

  git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf.git

Thanks!

----------------------------------------------------------------

The following changes since commit f28f20da704d399fb1e4d8838ffd697a357d9cc8:

  Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net (2016-04-26 16:25:51 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf.git HEAD

for you to fetch changes up to eda3fc50daa93b08774a18d51883c5a5d8d85e15:

  netfilter: nfnetlink_acct: validate NFACCT_QUOTA parameter (2016-05-05 16:47:08 +0200)

----------------------------------------------------------------
Florian Westphal (1):
      netfilter: conntrack: init all_locks to avoid debug warning

Liping Zhang (1):
      netfilter: IDLETIMER: fix race condition when destroy the target

Phil Turnbull (1):
      netfilter: nfnetlink_acct: validate NFACCT_QUOTA parameter

 net/netfilter/nf_conntrack_core.c | 2 +-
 net/netfilter/nfnetlink_acct.c    | 2 ++
 net/netfilter/xt_IDLETIMER.c      | 1 +
 3 files changed, 4 insertions(+), 1 deletion(-)
