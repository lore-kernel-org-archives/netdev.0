From: Simon Horman <horms@verge.net.au>
Subject: [GIT PULL nf 0/3] IPVS Fixes for v4.5
Date: Thu, 18 Feb 2016 09:40:58 +0900
Message-ID: <1455756061-21834-1-git-send-email-horms@verge.net.au>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org,
	Wensong Zhang <wensong@linux-vs.org>,
	Julian Anastasov <ja@ssi.bg>, Simon Horman <horms@verge.net.au>
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:40591 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965363AbcBRAlS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Feb 2016 19:41:18 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Pablo,

please consider these IPVS fixes for v4.5.

* Arnd Bergman has corrected an error whereby the SIP persistence engine
  may incorrectly access protocol fields
* Julian Anastasov has corrected a problem reported by Jiri Bohac with the
  connection rescheduling mechanism added in 3.10 when new SYNs in
  connection to dead real server can be redirected to another real server.

The following changes since commit 5cc6ce9ff27565949a1001a2889a8dd9fd09e772:

  netfilter: nft_counter: fix erroneous return values (2016-02-08 13:05:02 +0100)

are available in the git repository at:

  https://git.kernel.org/pub/scm/linux/kernel/git/horms/ipvs.git tags/ipvs-fixes-for-v4.5

for you to fetch changes up to 5acaf89f88b97849d550d6fbb10362e3d84b5082:

  netfilter: ipvs: handle ip_vs_fill_iph_skb_off failure (2016-02-18 09:31:48 +0900)

----------------------------------------------------------------
Arnd Bergmann (1):
      netfilter: ipvs: handle ip_vs_fill_iph_skb_off failure

Julian Anastasov (2):
      netfilter: ipvs: drop first packet to redirect conntrack
      netfilter: ipvs: allow rescheduling after RST

 include/net/ip_vs.h               | 17 +++++++++++++++++
 net/netfilter/ipvs/ip_vs_core.c   | 38 +++++++++++++++++++++++++++++---------
 net/netfilter/ipvs/ip_vs_pe_sip.c |  4 ++--
 3 files changed, 48 insertions(+), 11 deletions(-)
