From: Patrick McHardy <kaber@trash.net>
Subject: netfilter 00/02: Netfilter fixes
Date: Thu, 19 Nov 2009 15:59:02 +0100 (MET)
Message-ID: <20091119145902.18633.28666.sendpatchset@x2.localnet>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:44352 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751910AbZKSO65 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Nov 2009 09:58:57 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

following are two patches for netfilter, fixing

- a positive errno return value in the osf match

- a sleeping function called under RCU lock in the nf_log seq_show function

Please apply or pull from:

git://git.kernel.org/pub/scm/linux/kernel/git/kaber/nf-2.6.git master

Thanks!


 net/netfilter/nf_log.c |   18 +++++-------------
 net/netfilter/xt_osf.c |    2 +-
 2 files changed, 6 insertions(+), 14 deletions(-)

Roel Kluin (1):
      netfilter: xt_osf: fix xt_osf_remove_callback() return value

Wu Fengguang (1):
      netfilter: nf_log: fix sleeping function called from invalid context in seq_show()
