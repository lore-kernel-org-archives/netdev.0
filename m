From: Simon Horman <horms@verge.net.au>
Subject: [GIT PULL net] IPVS
Date: Fri, 27 Apr 2012 09:53:54 +0900
Message-ID: <1335488039-13471-1-git-send-email-horms@verge.net.au>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org,
	Wensong Zhang <wensong@linux-vs.org>,
	Julian Anastasov <ja@ssi.bg>,
	Hans Schillstrom <hans.schillstrom@ericsson.com>,
	Jesper Dangaard Brouer <brouer@redhat.com>
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:58350 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753429Ab2D0AyY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Apr 2012 20:54:24 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Pablo,

please consider the following 5 changes for 3.4, they are all bug fixes.
I would also like these changes considered for stable.

The following changes since commit 8f9b9a2fad47af27e14b037395e03cd8278d96d7:

  ipvs: fix crash in ip_vs_control_net_cleanup on unload (2012-04-25 11:16:30 +0200)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/horms/ipvs.git master

for you to fetch changes up to 1c3dc0f92d127d3fdefa84c7ef629b070bf8d32c:

  ipvs: kernel oops - do_ip_vs_get_ctl (2012-04-26 18:04:31 +0900)

----------------------------------------------------------------
Hans Schillstrom (3):
      ipvs: null check of net->ipvs in lblc(r) shedulers
      ipvs: take care of return value from protocol init_netns
      ipvs: kernel oops - do_ip_vs_get_ctl

Julian Anastasov (2):
      ipvs: add check in ftp for initialized core
      ipvs: reset ipvs pointer in netns

 include/net/ip_vs.h                   |    4 ++-
 net/netfilter/ipvs/ip_vs_core.c       |   11 +++++++
 net/netfilter/ipvs/ip_vs_ctl.c        |   52 +++++++++++++++++++--------------
 net/netfilter/ipvs/ip_vs_ftp.c        |    2 ++
 net/netfilter/ipvs/ip_vs_lblc.c       |    3 ++
 net/netfilter/ipvs/ip_vs_lblcr.c      |    3 ++
 net/netfilter/ipvs/ip_vs_proto.c      |   11 +++++--
 net/netfilter/ipvs/ip_vs_proto_sctp.c |    5 +++-
 net/netfilter/ipvs/ip_vs_proto_tcp.c  |    5 +++-
 net/netfilter/ipvs/ip_vs_proto_udp.c  |    5 +++-
 10 files changed, 73 insertions(+), 28 deletions(-)
