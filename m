From: Shradha Shah <sshah@solarflare.com>
Subject: [PATCH net-next v3 02/15] sfc: Add paranthesis correctly on all branches
 of the if statement
Date: Tue, 2 Jun 2015 11:37:41 +0100
Message-ID: <556D8775.5050102@solarflare.com>
References: <556D8710.6060706@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo02.seg.att.com ([209.65.160.78]:46588 "EHLO
	nbfkord-smmo02.seg.att.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752923AbbFBKhr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Jun 2015 06:37:47 -0400
In-Reply-To: <556D8710.6060706@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This change is a stylistic change and does not affect
functionality.

Signed-off-by: Shradha Shah <sshah@solarflare.com>
---
 drivers/net/ethernet/sfc/ef10.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/sfc/ef10.c b/drivers/net/ethernet/sfc/ef10.c
index 06605ab..14c5205 100644
--- a/drivers/net/ethernet/sfc/ef10.c
+++ b/drivers/net/ethernet/sfc/ef10.c
@@ -346,9 +346,9 @@ static int efx_ef10_probe(struct efx_nic *efx)
 	 * ask if it's already enabled
 	 */
 	rc = efx_mcdi_set_workaround(efx, MC_CMD_WORKAROUND_BUG35388, true);
-	if (rc == 0)
+	if (rc == 0) {
 		nic_data->workaround_35388 = true;
-	else if (rc == -EPERM) {
+	} else if (rc == -EPERM) {
 		unsigned int enabled;
 
 		rc = efx_mcdi_get_workarounds(efx, NULL, &enabled);
@@ -356,9 +356,9 @@ static int efx_ef10_probe(struct efx_nic *efx)
 			goto fail3;
 		nic_data->workaround_35388 = enabled &
 			MC_CMD_GET_WORKAROUNDS_OUT_BUG35388;
-	}
-	else if (rc != -ENOSYS && rc != -ENOENT)
+	} else if (rc != -ENOSYS && rc != -ENOENT) {
 		goto fail3;
+	}
 	netif_dbg(efx, probe, efx->net_dev,
 		  "workaround for bug 35388 is %sabled\n",
 		  nic_data->workaround_35388 ? "en" : "dis");
