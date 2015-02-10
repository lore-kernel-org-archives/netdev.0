From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 0/2] Netfilter updates for net-next
Date: Tue, 10 Feb 2015 06:34:32 +0100
Message-ID: <1423546474-3539-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:36686 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750892AbbBJFb2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Feb 2015 00:31:28 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

The following patchset contains two small Netfilter updates for your
net-next tree, they are:

1) Add ebtables support to nft_compat, from Arturo Borrero.

2) Fix missing validation of the SET_ID attribute in the lookup
   expressions, from Patrick McHardy.

You can pull these changes from:

  git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf-next.git

Thanks!

----------------------------------------------------------------

The following changes since commit 4c72c53be5e3c8cf319a020ea671ab0fc32ec96f:

  Merge tag 'linux-can-next-for-3.20-20150128' of git://git.kernel.org/pub/scm/linux/kernel/git/mkl/linux-can-next (2015-01-29 14:54:45 -0800)

are available in the git repository at:


  git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf-next.git master

for you to fetch changes up to 4c1017aa80c95a74703139bb95c4ce0d130efe4d:

  netfilter: nft_lookup: add missing attribute validation for NFTA_LOOKUP_SET_ID (2015-01-30 19:08:20 +0100)

----------------------------------------------------------------
Arturo Borrero (1):
      netfilter: nft_compat: add ebtables support

Patrick McHardy (1):
      netfilter: nft_lookup: add missing attribute validation for NFTA_LOOKUP_SET_ID

 net/netfilter/nft_compat.c |   63 +++++++++++++++++++++++++++++++++++++++-----
 net/netfilter/nft_lookup.c |    1 +
 2 files changed, 58 insertions(+), 6 deletions(-)
