From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCH net-next 1/3] ethtool: rename reserved1 memeber in ethtool_drvinfo for expansion ROM version
Date: Wed,  4 Feb 2015 18:19:34 +0530
Message-ID: <1423054176-26420-2-git-send-email-hariprasad@chelsio.com>
References: <1423054176-26420-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, ben@decadent.org.uk, leedom@chelsio.com,
	anish@chelsio.com, nirranjan@chelsio.com, kumaras@chelsio.com,
	Hariprasad Shenai <hariprasad@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:30038 "EHLO
	stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S933819AbbBDMoL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Feb 2015 07:44:11 -0500
In-Reply-To: <1423054176-26420-1-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Renamed the reserved1 member of struct ethtool_drvinfo to erom_version to get
expansion/option ROM version of the adapter if present.

Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>
---
 include/uapi/linux/ethtool.h |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/include/uapi/linux/ethtool.h b/include/uapi/linux/ethtool.h
index 5f66d9c..bd80f0f 100644
--- a/include/uapi/linux/ethtool.h
+++ b/include/uapi/linux/ethtool.h
@@ -148,6 +148,7 @@ static inline __u32 ethtool_cmd_speed(const struct ethtool_cmd *ep)
  *	not be an empty string.
  * @version: Driver version string; may be an empty string
  * @fw_version: Firmware version string; may be an empty string
+ * @erom_version: Expansion ROM version string; may be an empty string
  * @bus_info: Device bus address.  This should match the dev_name()
  *	string for the underlying bus device, if there is one.  May be
  *	an empty string.
@@ -176,7 +177,7 @@ struct ethtool_drvinfo {
 	char	version[32];
 	char	fw_version[ETHTOOL_FWVERS_LEN];
 	char	bus_info[ETHTOOL_BUSINFO_LEN];
-	char	reserved1[32];
+	char	erom_version[32];
 	char	reserved2[12];
 	__u32	n_priv_flags;
 	__u32	n_stats;
-- 
1.7.1
