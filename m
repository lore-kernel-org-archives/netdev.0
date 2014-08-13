From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 0/4] rhashtable annotation fixes
Date: Wed, 13 Aug 2014 16:38:28 +0200
Message-ID: <cover.1407939963.git.tgraf@suug.ch>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:54738 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751145AbaHMOih (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Aug 2014 10:38:37 -0400
Received: from 77-56-195-25.dclient.hispeed.ch ([77.56.195.25] helo=lsx.localdomain)
	by bombadil.infradead.org with esmtpsa (Exim 4.80.1 #2 (Red Hat Linux))
	id 1XHZhE-00056M-Ap
	for netdev@vger.kernel.org; Wed, 13 Aug 2014 14:38:36 +0000
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thomas Graf (4):
  rhashtable: RCU annotations for next pointers
  rhashtable: unexport and make rht_obj() static
  rhashtable: fix annotations for rht_for_each_entry_rcu()
  netlink: Annotate RCU locking for seq_file walker

 include/linux/rhashtable.h | 17 ++++++-----------
 lib/rhashtable.c           | 10 ++--------
 net/netlink/af_netlink.c   |  2 ++
 3 files changed, 10 insertions(+), 19 deletions(-)

-- 
1.9.3
