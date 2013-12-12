From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next 09/16] sfc: Add new sensor names
Date: Thu, 12 Dec 2013 23:01:45 +0000
Message-ID: <1386889305.1516.346.camel@bwh-desktop.uk.level5networks.com>
References: <1386888977.1516.337.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:43776 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751825Ab3LLXBs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Dec 2013 18:01:48 -0500
In-Reply-To: <1386888977.1516.337.camel@bwh-desktop.uk.level5networks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/sfc/mcdi_mon.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/drivers/net/ethernet/sfc/mcdi_mon.c b/drivers/net/ethernet/sfc/mcdi_mon.c
index 2891b409d263..bc27d5b580f5 100644
--- a/drivers/net/ethernet/sfc/mcdi_mon.c
+++ b/drivers/net/ethernet/sfc/mcdi_mon.c
@@ -89,6 +89,9 @@ static const struct {
 				 "Controller die temp. (ext. ADC)", TEMP,  -1),
 	SENSOR(AMBIENT_TEMP,		"Ambient temp.",	    TEMP,  -1),
 	SENSOR(AIRFLOW,			"Air flow raw",		    IN,    -1),
+	SENSOR(VDD08D_VSS08D_CSR,	"0.9V die (int. ADC)",	    IN,    -1),
+	SENSOR(VDD08D_VSS08D_CSR_EXTADC, "0.9V die (ext. ADC)",	    IN,    -1),
+	SENSOR(HOTPOINT_TEMP,  "Controller board temp. (hotpoint)", TEMP,  -1),
 #undef SENSOR
 };
 


-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
