From: Simon Horman <horms@verge.net.au>
Subject: [GIT PULL nf] IPVS Fixes for v3.19
Date: Fri, 30 Jan 2015 10:22:17 +0900
Message-ID: <1422580938-31520-1-git-send-email-horms@verge.net.au>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org,
	Wensong Zhang <wensong@linux-vs.org>,
	Julian Anastasov <ja@ssi.bg>, Simon Horman <horms@verge.net.au>
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:54907 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752517AbbA3BWY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Jan 2015 20:22:24 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Pablo,

please consider this fix for v3.19.

It resolves a crash in xfrm reported by Florian Wiessner.

I believe this problem manifests since 0a5ebb8000c5 ("ipv4: Pass explicit
daddr arg to ip_send_reply().") which was included in v2.6.39.

Julian reports that the patch has been tested on net tree (Dec 7), 3.14.25,
3.12.33, 3.10.61. 3.4.104 needs a modified fix that resolves rejects. It
applies with little fuzz on 3.2.64. Please let us know if we should post
separate 3.2 and 3.4 patches.


The following changes since commit e8781f70a5b210a1b08cff8ce05895ebcec18d83:

  netfilter: nf_tables: disable preemption when restoring chain counters (2015-01-26 11:50:02 +0100)

are available in the git repository at:

  https://git.kernel.org/pub/scm/linux/kernel/git/horms/ipvs.git tags/ipvs-fixes-for-v3.19

for you to fetch changes up to 579eb62ac35845686a7c4286c0a820b4eb1f96aa:

  ipvs: rerouting to local clients is not needed anymore (2015-01-30 10:05:55 +0900)

----------------------------------------------------------------
Julian Anastasov (1):
      ipvs: rerouting to local clients is not needed anymore

 net/netfilter/ipvs/ip_vs_core.c | 33 ++++++++++++++++++++++-----------
 1 file changed, 22 insertions(+), 11 deletions(-)
