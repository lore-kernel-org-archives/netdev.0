From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH] sky2: flow control off
Date: Fri, 2 Feb 2007 15:34:25 -0800
Message-ID: <20070202153425.2d979fd4@freekitty>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Linus Torvalds <torvalds@linux-foundation.org>,
	Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:44595 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1946170AbXBBXha (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 2 Feb 2007 18:37:30 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Turn flow control off for sky2. When flow control is on, the transmitter
may get randomly stuck. Perhaps there is hardware problem, but until
Marvell provides errata information for workaround, it should default to off.

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>
---
 drivers/net/sky2.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/sky2.c b/drivers/net/sky2.c
index 822dd0b..a31dea5 100644
--- a/drivers/net/sky2.c
+++ b/drivers/net/sky2.c
@@ -3263,7 +3263,7 @@ #endif
 
 	/* Auto speed and flow control */
 	sky2->autoneg = AUTONEG_ENABLE;
-	sky2->flow_mode = FC_BOTH;
+	sky2->flow_mode = FC_NONE;
 
 	sky2->duplex = -1;
 	sky2->speed = -1;
-- 
1.4.1

