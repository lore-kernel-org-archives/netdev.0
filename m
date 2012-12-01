From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next 07/13] sfc: Correctly initialise reset_method in
 siena_test_chip()
Date: Sat, 1 Dec 2012 04:42:44 +0000
Message-ID: <1354336964.2640.46.camel@bwh-desktop.uk.solarflarecom.com>
References: <1354336821.2640.39.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:26157 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751928Ab2LAEmr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Nov 2012 23:42:47 -0500
In-Reply-To: <1354336821.2640.39.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/sfc/siena.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/sfc/siena.c b/drivers/net/ethernet/sfc/siena.c
index 3553d77..ba40f67 100644
--- a/drivers/net/ethernet/sfc/siena.c
+++ b/drivers/net/ethernet/sfc/siena.c
@@ -170,7 +170,7 @@ static const struct efx_nic_register_test siena_register_tests[] = {
 
 static int siena_test_chip(struct efx_nic *efx, struct efx_self_tests *tests)
 {
-	enum reset_type reset_method = reset_method;
+	enum reset_type reset_method = RESET_TYPE_ALL;
 	int rc, rc2;
 
 	efx_reset_down(efx, reset_method);
-- 
1.7.7.6



-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
