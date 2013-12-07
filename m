From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 0/3] Netfilter fixes for net
Date: Sun,  8 Dec 2013 00:13:27 +0100
Message-ID: <1386458010-4615-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:43620 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754183Ab3LGXNo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 7 Dec 2013 18:13:44 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

The following patchset contains three Netfilter fixes for your net tree,
they are:

* fix incorrect comparison in the new netnet hash ipset type, from
  Dave Jones.

* fix splat in hashlimit due to missing removal of the content of its
  proc entry in netnamespaces, from Sergey Popovich.

* fix missing rule flushing operation by table in nf_tables. Table
  flushing was already discussed back in October but this got lost and
  no patch has hit the tree to address this issue so far, from me.

You can pull these changes from:

  git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf.git master

Thanks!

----------------------------------------------------------------

The following changes since commit 2c7a9dc1641664173211c4ebc5db510a08684c46:

  be2net: Avoid programming permenant MAC by BE3-R VFs (2013-11-23 15:11:07 -0800)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf.git master

for you to fetch changes up to cf9dc09d0949f0b5953fb08caa10bba0dc7ee71f:

  netfilter: nf_tables: fix missing rules flushing per table (2013-12-07 22:55:48 +0100)

----------------------------------------------------------------
Dave Jones (1):
      netfilter: ipset: fix incorret comparison in hash_netnet4_data_equal()

Pablo Neira Ayuso (1):
      netfilter: nf_tables: fix missing rules flushing per table

Sergey Popovich (1):
      netfilter: xt_hashlimit: fix proc entry leak in netns destroy path

 net/netfilter/ipset/ip_set_hash_netnet.c |    2 +-
 net/netfilter/nf_tables_api.c            |   46 +++++++++++++++++++++---------
 net/netfilter/xt_hashlimit.c             |   25 +++++++---------
 3 files changed, 45 insertions(+), 28 deletions(-)
