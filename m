From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 0/3] Netfilter fixes for net
Date: Wed,  4 Nov 2015 15:00:35 +0100
Message-ID: <1446645638-3625-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:44225 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750746AbbKDNxp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Nov 2015 08:53:45 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

The following patchset contains Netfilter fixes for your net tree,
they are:

1) Fix crash when TEE target is used with no --oif, from Eric Dumazet.

2) Oneliner to fix a crash on the redirect traffic to localhost
   infrastructure when interface has not yet an address, from
   Munehisa Kamata.

3) Oneliner not to request module all the time from nfnetlink due to
   wrong type value, from Florian Westphal.

I'll make sure these patches 1 and 2 hit -stable.

You can pull these changes from:

  git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf.git

Thanks!

----------------------------------------------------------------

The following changes since commit 104eb270e665f4fcd8cb8c8ab4c4d4538c604e92:

  net: sun4i-emac: Properly free resources on probe failure and remove (2015-10-21 19:47:45 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf.git HEAD

for you to fetch changes up to dbc3617f4c1f9fcbe63612048cb9583fea1e11ab:

  netfilter: nfnetlink: don't probe module if it exists (2015-10-28 03:40:50 +0100)

----------------------------------------------------------------
Eric Dumazet (1):
      netfilter: xt_TEE: fix NULL dereference

Florian Westphal (1):
      netfilter: nfnetlink: don't probe module if it exists

Munehisa Kamata (1):
      netfilter: nf_nat_redirect: add missing NULL pointer check

 net/netfilter/nf_nat_redirect.c | 2 +-
 net/netfilter/nfnetlink.c       | 2 +-
 net/netfilter/xt_TEE.c          | 6 ++++--
 3 files changed, 6 insertions(+), 4 deletions(-)
