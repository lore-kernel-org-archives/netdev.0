From: Simon Horman <horms@verge.net.au>
Subject: [GIT PULL nf-2.6] IPVS
Date: Mon,  2 May 2011 21:47:25 +0900
Message-ID: <1304340447-21857-1-git-send-email-horms@verge.net.au>
Cc: Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>,
	Patrick McHardy <kaber@trash.net>,
	Hans Schillstrom <hans@schillstrom.com>,
	Hans Schillstrom <hans.schillstrom@ericsson.com>,
	"Eric W. Biederman" <ebiederm@xmission.com>
To: lvs-devel@vger.kernel.org, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org, netfilter@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:55143 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756223Ab1EBMrq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 May 2011 08:47:46 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Hi Patrick,

please consider pulling
git://git.kernel.org/pub/scm/linux/kernel/git/horms/ipvs-2.6.git master
to get the following fix from Hans. They resolve some problems related
to his netns for IPVS work which was incorporated into 2.6.39-rc1.

The pull request is based on nf-2.6/master.

There are other less-pressing changes from Hans which
I plan to get you to pull into nf-next-2.6 once these
changes make it there (presumably via net-2.6 and then net-next-2.6).

Hans Schillstrom (2):
      IPVS: Change of socket usage to enable name space exit.
      IPVS: labels at pos 0

 net/netfilter/ipvs/ip_vs_core.c |   12 ++++----
 net/netfilter/ipvs/ip_vs_ctl.c  |    8 +++---
 net/netfilter/ipvs/ip_vs_sync.c |   58 +++++++++++++++++++++++++--------------
 3 files changed, 47 insertions(+), 31 deletions(-)

