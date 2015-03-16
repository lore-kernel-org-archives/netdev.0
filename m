From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 0/2 net-next v2] Minor rhashtable fixes
Date: Mon, 16 Mar 2015 10:42:25 +0100
Message-ID: <cover.1426494808.git.tgraf@suug.ch>
Cc: netdev@vger.kernel.org, herbert@gondor.apana.org.au
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:41855 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751221AbbCPJmb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Mar 2015 05:42:31 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thomas Graf (2):
  rhashtable: Avoid calculating hash again to unlock
  rhashtable: Annotate RCU locking of walkers

 lib/rhashtable.c | 13 +++++++------
 1 file changed, 7 insertions(+), 6 deletions(-)

---
v2: Dropped patch 2
