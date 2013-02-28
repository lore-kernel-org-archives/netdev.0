From: "Yaniv Rosner" <yanivr@broadcom.com>
Subject: [PATCH ethtool] Restore 20000baseKR2 cap display
Date: Thu, 28 Feb 2013 12:10:06 +0200
Message-ID: <1362046206-6907-1-git-send-email-yanivr@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	"Yaniv Rosner" <yanivr@broadcom.com>
To: "Ben Hutchings" <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:2538 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751192Ab3B1ILU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 Feb 2013 03:11:20 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Restore the 20000baseKR2 which was removed by mistake back in June 2012.

Signed-off-by: Yaniv Rosner <yanivr@broadcom.com>
---
 ethtool.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/ethtool.c b/ethtool.c
index 55bc082..acac32a 100644
--- a/ethtool.c
+++ b/ethtool.c
@@ -513,6 +513,7 @@ dump_link_caps(const char *prefix, const char *an_prefix, u32 mask,
 		{ 0, ADVERTISED_10000baseT_Full,    "10000baseT/Full" },
 		{ 0, ADVERTISED_10000baseKX4_Full,  "10000baseKX4/Full" },
 		{ 0, ADVERTISED_20000baseMLD2_Full, "20000baseMLD2/Full" },
+		{ 0, ADVERTISED_20000baseKR2_Full,  "20000baseKR2/Full" },
 		{ 0, ADVERTISED_40000baseKR4_Full,  "40000baseKR4/Full" },
 		{ 0, ADVERTISED_40000baseCR4_Full,  "40000baseCR4/Full" },
 		{ 0, ADVERTISED_40000baseSR4_Full,  "40000baseSR4/Full" },
-- 
1.7.7.1
