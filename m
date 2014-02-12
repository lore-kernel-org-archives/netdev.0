From: Shradha Shah <sshah@solarflare.com>
Subject: [PATCH net-next 12/13] sfc: Fail self-test with -EBUSY, not -EIO,
 if the device is busy
Date: Wed, 12 Feb 2014 19:00:28 +0000
Message-ID: <52FBC4CC.5030206@solarflare.com>
References: <52FBC3C2.7030103@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:50988 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752706AbaBLTAb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Feb 2014 14:00:31 -0500
In-Reply-To: <52FBC3C2.7030103@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
Signed-off-by: Shradha Shah <sshah@solarflare.com>
---
 drivers/net/ethernet/sfc/ethtool.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/sfc/ethtool.c b/drivers/net/ethernet/sfc/ethtool.c
index 3444dd6..7d5cb86 100644
--- a/drivers/net/ethernet/sfc/ethtool.c
+++ b/drivers/net/ethernet/sfc/ethtool.c
@@ -461,7 +461,7 @@ static void efx_ethtool_self_test(struct net_device *net_dev,
 		goto fail;
 
 	if (efx->state != STATE_READY) {
-		rc = -EIO;
+		rc = -EBUSY;
 		goto out;
 	}
 
