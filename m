From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 45/52] sfc: Don't use EFX_OWORD_FIELD on an event (64-bit, quad-word)
Date: Mon, 1 Sep 2008 12:49:29 +0100
Message-ID: <20080901114928.GL7908@solarflare.com>
References: <20080901111621.GT7908@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost03.mail.zen.net.uk ([212.23.3.142]:37177 "EHLO
	smarthost03.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1759283AbYIALtb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Sep 2008 07:49:31 -0400
Content-Disposition: inline
In-Reply-To: <20080901111621.GT7908@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


From: Steve Hodgson <shodgson@solarflare.com>
Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/falcon.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/sfc/falcon.c b/drivers/net/sfc/falcon.c
index 636fe82..ad192f8 100644
--- a/drivers/net/sfc/falcon.c
+++ b/drivers/net/sfc/falcon.c
@@ -1007,7 +1007,7 @@ static void falcon_handle_global_event(struct efx_channel *channel,
 		is_phy_event = true;
 
 	if ((falcon_rev(efx) >= FALCON_REV_B0) &&
-	    EFX_OWORD_FIELD(*event, XG_MNT_INTR_B0))
+	    EFX_QWORD_FIELD(*event, XG_MNT_INTR_B0))
 		is_phy_event = true;
 
 	if (is_phy_event) {
-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

