From: Daniel Hellstrom <daniel@gaisler.com>
Subject: [PATCH 1/7 v2] GRETH: added raw AMBA vendor/device number to match against.
Date: Fri, 14 Jan 2011 14:02:37 +0100
Message-ID: <1295010163-2585-1-git-send-email-daniel@gaisler.com>
Cc: netdev@vger.kernel.org, kristoffer@gaisler.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail175c2.megamailservers.com ([69.49.111.75]:57034 "EHLO
	mail175c2.megamailservers.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751937Ab1ANNCx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Jan 2011 08:02:53 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Daniel Hellstrom <daniel@gaisler.com>
---
 drivers/net/greth.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/drivers/net/greth.c b/drivers/net/greth.c
index 27d6960..1c2dbdb 100644
--- a/drivers/net/greth.c
+++ b/drivers/net/greth.c
@@ -1600,6 +1600,9 @@ static struct of_device_id greth_of_match[] = {
 	{
 	 .name = "GAISLER_ETHMAC",
 	 },
+	{
+	 .name = "01_01d",
+	 },
 	{},
 };
 
-- 
1.5.4

