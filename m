From: Daniel Hellstrom <daniel@gaisler.com>
Subject: [PATCH 01/10] GRETH: added raw AMBA vendor/device number to match against.
Date: Thu, 13 Jan 2011 09:25:26 +0100
Message-ID: <1294907135-24884-1-git-send-email-daniel@gaisler.com>
Cc: netdev@vger.kernel.org, kristoffer@gaisler.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail201c2.megamailservers.com ([69.49.111.102]:39241 "EHLO
	mail201c2.megamailservers.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753307Ab1AMJAD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Jan 2011 04:00:03 -0500
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

