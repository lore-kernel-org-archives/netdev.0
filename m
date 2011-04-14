From: Ben Hutchings <ben@decadent.org.uk>
Subject: [PATCH net-next-2.6] rndis_host: Quirky devices are still
 'point-to-point'
Date: Thu, 14 Apr 2011 13:51:01 +0100
Message-ID: <1302785461.5282.686.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8BIT
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:34584 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757992Ab1DNMvH convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 Apr 2011 08:51:07 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

My changes in commit 4d42d417be75d750b82798922b6e775915e11bce were
written some time before the introduction of FLAG_POINTTOPOINT, so
didn't include that flag in the new driver_info.  Change the new
driver_info to be consistent.

Signed-off-by: Ben Hutchings <ben@decadent.org.uk>
---
 drivers/net/usb/rndis_host.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/usb/rndis_host.c b/drivers/net/usb/rndis_host.c
index 6d6c1da..255d6a4 100644
--- a/drivers/net/usb/rndis_host.c
+++ b/drivers/net/usb/rndis_host.c
@@ -592,7 +592,7 @@ static const struct driver_info	rndis_info = {
 
 static const struct driver_info	rndis_poll_status_info = {
 	.description =	"RNDIS device (poll status before control)",
-	.flags =	FLAG_ETHER | FLAG_FRAMING_RN | FLAG_NO_SETINT,
+	.flags =	FLAG_ETHER | FLAG_POINTTOPOINT | FLAG_FRAMING_RN | FLAG_NO_SETINT,
 	.data =		RNDIS_DRIVER_DATA_POLL_STATUS,
 	.bind =		rndis_bind,
 	.unbind =	rndis_unbind,
-- 
1.7.4.1


