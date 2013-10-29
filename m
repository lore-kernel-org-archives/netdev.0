From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH] netfilter fix for net
Date: Tue, 29 Oct 2013 13:13:15 +0100
Message-ID: <1383048796-7964-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:35368 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752547Ab3J2MN2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Oct 2013 08:13:28 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

This pull request contains the following netfilter fix:

* fix --queue-bypass in xt_NFQUEUE revision 3. While adding the
  revision 3 of this target, the bypass flags were not correctly
  handled anymore, thus, breaking packet bypassing if no application
  is listening from userspace, patch from Holger Eitzenberger,
  reported by Florian Westphal.

You can pull this change from:

  git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf.git master

Thanks!

----------------------------------------------------------------

The following changes since commit fecda03493646b53f53892fa3c38c75ba9310374:

  net: sctp: fix ASCONF to allow non SCTP_ADDR_SRC addresses in ipv6 (2013-10-23 16:57:14 -0400)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf.git master

for you to fetch changes up to d954777324ffcba0b2f8119c102237426c654eeb:

  netfilter: xt_NFQUEUE: fix --queue-bypass regression (2013-10-29 13:05:54 +0100)

----------------------------------------------------------------
Holger Eitzenberger (1):
      netfilter: xt_NFQUEUE: fix --queue-bypass regression

 net/netfilter/xt_NFQUEUE.c |    7 ++++++-
 1 file changed, 6 insertions(+), 1 deletion(-)
