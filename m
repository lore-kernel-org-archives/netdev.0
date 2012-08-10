From: Simon Horman <horms@verge.net.au>
Subject: [GIT PULL nf-next] IPVS
Date: Fri, 10 Aug 2012 10:41:29 +0900
Message-ID: <1344562895-22790-1-git-send-email-horms@verge.net.au>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org,
	Wensong Zhang <wensong@linux-vs.org>,
	Julian Anastasov <ja@ssi.bg>,
	Hans Schillstrom <hans.schillstrom@ericsson.com>,
	Jesper Dangaard Brouer <brouer@redhat.com>
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:38912 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759179Ab2HJBll (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Aug 2012 21:41:41 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Pablo,

please consider the following enhancements to IPVS for inclusion in 3.7.

----------------------------------------------------------------
The following changes since commit 173f8654746c138a08f51a8a0db7747763a896a2:

  Merge tag 'ext4_for_linus' of git://git.kernel.org/pub/scm/linux/kernel/git/tytso/ext4 (2012-07-27 20:52:25 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/horms/ipvs-next.git master

for you to fetch changes up to 3654e61137db891f5312e6dd813b961484b5fdf3:

  ipvs: add pmtu_disc option to disable IP DF for TUN packets (2012-08-10 10:35:07 +0900)

----------------------------------------------------------------
Claudiu Ghioc (1):
      ipvs: fixed sparse warning

Julian Anastasov (4):
      ipvs: ip_vs_ftp depends on nf_conntrack_ftp helper
      ipvs: generalize app registration in netns
      ipvs: implement passive PMTUD for IPIP packets
      ipvs: add pmtu_disc option to disable IP DF for TUN packets

 include/net/ip_vs.h             | 16 ++++++--
 net/netfilter/ipvs/Kconfig      |  3 +-
 net/netfilter/ipvs/ip_vs_app.c  | 58 ++++++++++++++++++++--------
 net/netfilter/ipvs/ip_vs_core.c | 76 +++++++++++++++++++++++++++++++++++--
 net/netfilter/ipvs/ip_vs_ctl.c  | 16 ++++++--
 net/netfilter/ipvs/ip_vs_ftp.c  | 21 +++--------
 net/netfilter/ipvs/ip_vs_xmit.c | 83 ++++++++++++++++++++++++++++-------------
 7 files changed, 204 insertions(+), 69 deletions(-)
