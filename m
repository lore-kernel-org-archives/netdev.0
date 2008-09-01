From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 03/52] sfc: Remove unused field efx_channel::reset_work
Date: Mon, 1 Sep 2008 12:44:48 +0100
Message-ID: <20080901114447.GW7908@solarflare.com>
References: <20080901111621.GT7908@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost02.mail.zen.net.uk ([212.23.3.141]:58918 "EHLO
	smarthost02.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757266AbYIALou (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Sep 2008 07:44:50 -0400
Content-Disposition: inline
In-Reply-To: <20080901111621.GT7908@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


From: Steve Hodgson <shodgson@solarflare.com>
Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/net_driver.h |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/drivers/net/sfc/net_driver.h b/drivers/net/sfc/net_driver.h
index ab318f7..628f25e 100644
--- a/drivers/net/sfc/net_driver.h
+++ b/drivers/net/sfc/net_driver.h
@@ -366,7 +366,6 @@ struct efx_channel {
 	unsigned int irq_moderation;
 	struct net_device *napi_dev;
 	struct napi_struct napi_str;
-	struct work_struct reset_work;
 	int work_pending;
 	struct efx_special_buffer eventq;
 	unsigned int eventq_read_ptr;
-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

