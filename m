From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 0/3 net-next] Minor rhashtable fixes
Date: Fri, 13 Mar 2015 15:45:18 +0100
Message-ID: <cover.1426257747.git.tgraf@suug.ch>
Cc: netdev@vger.kernel.org, herbert@gondor.apana.org.au,
	daniel@iogearbox.net
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:59800 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751601AbbCMOp2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Mar 2015 10:45:28 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thomas Graf (3):
  rhashtable: Avoid calculating hash again to unlock
  rhashtable: Use spin_lock_bh_nested() consistently
  rhashtable: Annotate RCU locking of walkers

 lib/rhashtable.c | 21 +++++++++++----------
 1 file changed, 11 insertions(+), 10 deletions(-)

---
Applies on top of Herbert's fixes:
("[PATCH 0/6] rhashtable: Fixes + cleanups + preparation for multiple rehash")
