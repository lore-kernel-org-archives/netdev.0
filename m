From: Simon Horman <horms@verge.net.au>
Subject: [GIT PULL 0/1] IPVS Fixes for v4.12
Date: Mon,  8 May 2017 11:48:42 +0200
Message-ID: <1494236923-8015-1-git-send-email-horms@verge.net.au>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org,
        netfilter-devel@vger.kernel.org,
        Wensong Zhang <wensong@linux-vs.org>,
        Julian Anastasov <ja@ssi.bg>, Simon Horman <horms@verge.net.au>
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:58187 "EHLO
        kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753964AbdEHJsx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 8 May 2017 05:48:53 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Pablo,

please consider this fix to IPVS for v4.12.

* It is a fix from Julian Anastasov to only SNAT SNAT packet replies only for
  NATed connections


My understanding is that this fix is appropriate for 4.9.25, 4.10.13, 4.11
as well as the nf tree. Julian has separately posted backports for other
-stable kernels; please see:

* [PATCH 3.2.88,3.4.113 -stable 1/3] ipvs: SNAT packet replies only for
        NATed connections
* [PATCH 3.10.105,3.12.73,3.16.43,4.1.39 -stable 2/3] ipvs: SNAT packet
        replies only for NATed connections 
* [PATCH 4.4.65 -stable 3/3] ipvs: SNAT packet replies only for NATed
        connections


The following changes since commit f411af6822182f84834c4881b825dd40534e7fe8:

  Merge branch 'ibmvnic-Updated-reset-handler-andcode-fixes' (2017-05-03 11:33:06 -0400)

are available in the git repository at:

  http://git.kernel.org/pub/scm/linux/kernel/git/horms/ipvs.git tags/ipvs-fixes-for-v4.12

for you to fetch changes up to 3c5ab3f395d66a9e4e937fcfdf6ebc63894f028b:

  ipvs: SNAT packet replies only for NATed connections (2017-05-08 11:38:35 +0200)

----------------------------------------------------------------
Julian Anastasov (1):
      ipvs: SNAT packet replies only for NATed connections

 net/netfilter/ipvs/ip_vs_core.c | 19 ++++++++++++++-----
 1 file changed, 14 insertions(+), 5 deletions(-)
