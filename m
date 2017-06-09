From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH net 2/3] bonding: fix 802.3ad support for 14G speed
Date: Thu, 08 Jun 2017 17:05:12 -0700
Message-ID: <1496966712.1929.25.camel@perches.com>
References: <1496913493-23293-1-git-send-email-nicolas.dichtel@6wind.com>
         <1496913493-23293-2-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, j.vosburgh@gmail.com, vfalico@gmail.com,
        andy@greyhouse.net, thibaut.collet@6wind.com,
        linville@tuxdriver.com
To: Nicolas Dichtel <nicolas.dichtel@6wind.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0147.hostedemail.com ([216.40.44.147]:54198 "EHLO
        smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1751392AbdFIAFQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 8 Jun 2017 20:05:16 -0400
In-Reply-To: <1496913493-23293-2-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2017-06-08 at 11:18 +0200, Nicolas Dichtel wrote:
> This patch adds 14 Gbps enum definition, and fixes
> aggregated bandwidth calculation based on above slave links.

Doesn't 14G need to be added to phy.c?
---
diff --git a/drivers/net/phy/phy.c b/drivers/net/phy/phy.c
index a4238cb56731..d1c33a8cbaf5 100644
--- a/drivers/net/phy/phy.c
+++ b/drivers/net/phy/phy.c
@@ -54,6 +54,8 @@ static const char *phy_speed_to_str(int speed)
 		return "5Gbps";
 	case SPEED_10000:
 		return "10Gbps";
+	case SPEED_14000:
+		return "14Gbps";
 	case SPEED_20000:
 		return "20Gbps";
 	case SPEED_25000:
