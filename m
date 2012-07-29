From: Karsten Keil <keil@b1-systems.de>
Subject: [PATCH 0/1] mISDN: Fix regression with AVM Fritz!PCI cards
Date: Sun, 29 Jul 2012 19:15:12 +0200
Message-ID: <1343582113-14752-1-git-send-email-keil@b1-systems.de>
Cc: netdev@vger.kernel.org, tobias.powalowski@googlemail.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.b1-systems.de ([217.11.58.35]:47396 "EHLO mx1.b1-systems.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753318Ab2G2RVq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 29 Jul 2012 13:21:46 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch does fix https://bugzilla.kernel.org/show_bug.cgi?id=45271. The bug was introduced
in 3.5. and so the fix should go into 3.5 stable series and into 3.6.

Best Regards
Karsten

Karsten Keil (1):

  mISDN: Bugfix only few bytes are transfered on a connection

 drivers/isdn/hardware/mISDN/avmfritz.c |    7 ++++---
 1 files changed, 4 insertions(+), 3 deletions(-)

-- 
1.7.7
