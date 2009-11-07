From: Ben Hutchings <ben@decadent.org.uk>
Subject: [PATCH 44/75] tms380tr: declare MODULE_FIRMWARE
Date: Sat, 07 Nov 2009 21:55:20 +0000
Message-ID: <1257630920.15927.446.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8BIT
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:53575 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753510AbZKGVzS convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 7 Nov 2009 16:55:18 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ben Hutchings <ben@decadent.org.uk>
---
 drivers/net/tokenring/tms380tr.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/drivers/net/tokenring/tms380tr.c b/drivers/net/tokenring/tms380tr.c
index a7b6888..fa15214 100644
--- a/drivers/net/tokenring/tms380tr.c
+++ b/drivers/net/tokenring/tms380tr.c
@@ -1364,6 +1364,8 @@ static int tms380tr_reset_adapter(struct net_device *dev)
 	return (-1);
 }
 
+MODULE_FIRMWARE("tms380tr.bin");
+
 /*
  * Starts bring up diagnostics of token ring adapter and evaluates
  * diagnostic results.
-- 
1.6.5.2



