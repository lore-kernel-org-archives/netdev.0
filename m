From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next 1/4] ethtool: Make struct ethtool_rxnfc kernel-doc
 more self-consistent
Date: Wed, 07 Sep 2011 00:48:20 +0100
Message-ID: <1315352900.12033.0.camel@bwh-desktop>
References: <1315352693.2788.20.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Sebastian Poehn <sebastian.poehn@belden.com>,
	Santwona Behera <santwona.behera@sun.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:45505 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755299Ab1IFXsY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Sep 2011 19:48:24 -0400
In-Reply-To: <1315352693.2788.20.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Refer consistently to 'classification rules' or just 'rules' rather
than 'filter specifications' or 'filter rules'.

Refer consistently to rule 'locations' and not 'indices'.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 include/linux/ethtool.h |   23 +++++++++++------------
 1 files changed, 11 insertions(+), 12 deletions(-)

diff --git a/include/linux/ethtool.h b/include/linux/ethtool.h
index 3829712..dffab51 100644
--- a/include/linux/ethtool.h
+++ b/include/linux/ethtool.h
@@ -446,7 +446,7 @@ struct ethtool_flow_ext {
 };
 
 /**
- * struct ethtool_rx_flow_spec - specification for RX flow filter
+ * struct ethtool_rx_flow_spec - classification rule for RX flows
  * @flow_type: Type of match to perform, e.g. %TCP_V4_FLOW
  * @h_u: Flow fields to match (dependent on @flow_type)
  * @h_ext: Additional fields to match
@@ -456,7 +456,7 @@ struct ethtool_flow_ext {
  *	includes the %FLOW_EXT flag.
  * @ring_cookie: RX ring/queue index to deliver to, or %RX_CLS_FLOW_DISC
  *	if packets should be discarded
- * @location: Index of filter in hardware table
+ * @location: Location of rule in the table
  */
 struct ethtool_rx_flow_spec {
 	__u32		flow_type;
@@ -475,9 +475,9 @@ struct ethtool_rx_flow_spec {
  *	%ETHTOOL_GRXCLSRLALL, %ETHTOOL_SRXCLSRLDEL or %ETHTOOL_SRXCLSRLINS
  * @flow_type: Type of flow to be affected, e.g. %TCP_V4_FLOW
  * @data: Command-dependent value
- * @fs: Flow filter specification
+ * @fs: Flow classification rule
  * @rule_cnt: Number of rules to be affected
- * @rule_locs: Array of valid rule indices
+ * @rule_locs: Array of valid rule locations
  *
  * For %ETHTOOL_GRXFH and %ETHTOOL_SRXFH, @data is a bitmask indicating
  * the fields included in the flow hash, e.g. %RXH_IP_SRC.  The following
@@ -489,20 +489,19 @@ struct ethtool_rx_flow_spec {
  * For %ETHTOOL_GRXCLSRLCNT, @rule_cnt is set to the number of defined
  * rules on return.
  *
- * For %ETHTOOL_GRXCLSRULE, @fs.@location specifies the index of an
- * existing filter rule on entry and @fs contains the rule on return.
+ * For %ETHTOOL_GRXCLSRULE, @fs.@location specifies the location of an
+ * existing rule on entry and @fs contains the rule on return.
  *
  * For %ETHTOOL_GRXCLSRLALL, @rule_cnt specifies the array size of the
  * user buffer for @rule_locs on entry.  On return, @data is the size
- * of the filter table and @rule_locs contains the indices of the
+ * of the rule table and @rule_locs contains the locations of the
  * defined rules.
  *
- * For %ETHTOOL_SRXCLSRLINS, @fs specifies the filter rule to add or
- * update.  @fs.@location specifies the index to use and must not be
- * ignored.
+ * For %ETHTOOL_SRXCLSRLINS, @fs specifies the rule to add or update.
+ * @fs.@location specifies the location to use and must not be ignored.
  *
- * For %ETHTOOL_SRXCLSRLDEL, @fs.@location specifies the index of an
- * existing filter rule on entry.
+ * For %ETHTOOL_SRXCLSRLDEL, @fs.@location specifies the location of an
+ * existing rule on entry.
  *
  * Implementation of indexed classification rules generally requires a
  * TCAM.
-- 
1.7.4.4



-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
