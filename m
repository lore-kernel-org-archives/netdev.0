From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH] ethtool: allow non-admin user to read GRO settings.
Date: Thu, 11 Feb 2010 15:48:29 -0800
Message-ID: <20100211154829.1b1a2039@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:59916 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757340Ab0BKXsk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 11 Feb 2010 18:48:40 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Looks like an oversight in GRO design.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/net/core/ethtool.c	2010-02-11 15:45:32.480296094 -0800
+++ b/net/core/ethtool.c	2010-02-11 15:46:34.669670657 -0800
@@ -927,6 +927,7 @@ int dev_ethtool(struct net *net, struct 
 	case ETHTOOL_GPERMADDR:
 	case ETHTOOL_GUFO:
 	case ETHTOOL_GGSO:
+	case ETHTOOL_GGRO:
 	case ETHTOOL_GFLAGS:
 	case ETHTOOL_GPFLAGS:
 	case ETHTOOL_GRXFH:
