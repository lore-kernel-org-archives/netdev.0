From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 01/16] ethtool: Add port type PORT_OTHER
Date: Wed, 29 Apr 2009 19:02:59 +0100
Message-ID: <1241028179.3246.32.camel@achroite>
References: <1241028086.3246.30.camel@achroite>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost02.mail.zen.net.uk ([212.23.3.141]:56393 "EHLO
	smarthost02.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752866AbZD2SDA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Apr 2009 14:03:00 -0400
In-Reply-To: <1241028086.3246.30.camel@achroite>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add a PORT_OTHER to represent all other physical port types.  Current
NICs generally do not allow switching between multiple port types in
software so specific types should not be needed.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 include/linux/ethtool.h |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/include/linux/ethtool.h b/include/linux/ethtool.h
index 131b127..5ccb6bd 100644
--- a/include/linux/ethtool.h
+++ b/include/linux/ethtool.h
@@ -605,6 +605,7 @@ struct ethtool_ops {
 #define PORT_MII		0x02
 #define PORT_FIBRE		0x03
 #define PORT_BNC		0x04
+#define PORT_OTHER		0xff
 
 /* Which transceiver to use. */
 #define XCVR_INTERNAL		0x00

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

