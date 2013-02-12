From: "Vasundhara, Volam" <Vasundhara.Volam@Emulex.Com>
Subject: [PATCH ethtool] ethtool: Add string to display support for KR PHY
Date: Tue, 12 Feb 2013 09:46:20 +0000
Message-ID: <f30e7788-1920-426f-88c2-afadac2cee75@CMEXHTCAS2.ad.emulex.com>
References: <1360659168-14346-1-git-send-email-vasundhara.volam@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Vasundhara, Volam" <Vasundhara.Volam@Emulex.Com>
To: "bhutchings@solarflare.com" <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge1.ext.emulex.com ([138.239.224.99]:7602 "EHLO
	CMEXEDGE1.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751027Ab3BLJq1 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Feb 2013 04:46:27 -0500
In-Reply-To: <1360659168-14346-1-git-send-email-vasundhara.volam@emulex.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Vasundhara Volam <vasundhara.volam@emulex.com>
---
 ethtool.c |    1 +
 1 file changed, 1 insertion(+)

diff --git a/ethtool.c b/ethtool.c
index 55bc082..205f574 100644
--- a/ethtool.c
+++ b/ethtool.c
@@ -512,6 +512,7 @@ dump_link_caps(const char *prefix, const char *an_prefix, u32 mask,
 		{ 0, ADVERTISED_2500baseX_Full,     "2500baseX/Full" },
 		{ 0, ADVERTISED_10000baseT_Full,    "10000baseT/Full" },
 		{ 0, ADVERTISED_10000baseKX4_Full,  "10000baseKX4/Full" },
+		{ 0, ADVERTISED_10000baseKR_Full,   "10000baseKR/Full" },
 		{ 0, ADVERTISED_20000baseMLD2_Full, "20000baseMLD2/Full" },
 		{ 0, ADVERTISED_40000baseKR4_Full,  "40000baseKR4/Full" },
 		{ 0, ADVERTISED_40000baseCR4_Full,  "40000baseCR4/Full" },
-- 
1.7.10.4
