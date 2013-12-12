From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next 11/16] sfc: Map MCDI error MC_CMD_ERR_ENOTSUP to
 Linux EOPNOTSUPP
Date: Thu, 12 Dec 2013 23:02:17 +0000
Message-ID: <1386889337.1516.348.camel@bwh-desktop.uk.level5networks.com>
References: <1386888977.1516.337.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:43813 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751579Ab3LLXCU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Dec 2013 18:02:20 -0500
In-Reply-To: <1386888977.1516.337.camel@bwh-desktop.uk.level5networks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/sfc/mcdi.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/ethernet/sfc/mcdi.c b/drivers/net/ethernet/sfc/mcdi.c
index aee67be3d8c5..d317dfdee845 100644
--- a/drivers/net/ethernet/sfc/mcdi.c
+++ b/drivers/net/ethernet/sfc/mcdi.c
@@ -192,6 +192,8 @@ static int efx_mcdi_errno(unsigned int mcdi_err)
 	TRANSLATE_ERROR(EALREADY);
 	TRANSLATE_ERROR(ENOSPC);
 #undef TRANSLATE_ERROR
+	case MC_CMD_ERR_ENOTSUP:
+		return -EOPNOTSUPP;
 	case MC_CMD_ERR_ALLOC_FAIL:
 		return -ENOBUFS;
 	case MC_CMD_ERR_MAC_EXIST:


-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
