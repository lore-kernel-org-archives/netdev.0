From: Kirtika Ruchandani <kirtika.ruchandani@gmail.com>
Subject: [PATCH v2 06/10] nl80211: Various checkpatch.pl spacing fixes
Date: Sun, 29 May 2016 19:53:06 -0700
Message-ID: <80c4512b4c5ca1f26ecda9785a456c4d0cf4f937.1464576022.git.kirtika.ruchandani@gmail.com>
References: <cover.1464576022.git.kirtika.ruchandani@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless@vger.kernel.org, ruchandani.tina@gmail.com,
	netdev@vger.kernel.org, Julian.Calaby@gmail.com
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f67.google.com ([209.85.220.67]:33001 "EHLO
	mail-pa0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753549AbcE3CxN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 May 2016 22:53:13 -0400
Content-Disposition: inline
In-Reply-To: <cover.1464576022.git.kirtika.ruchandani@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch fixes the following spacing issues reported
by checkpatch.pl -
- space preferred around that <operator>
- no space needed after cast.
- Alignment should match open parenthesis
- suspect code indent for conditional statements
- Statements should start on a tabstop

This patch also contains two hunks to fix 'line over 80 characters',
that are spacing related.
All other instances of that warning have been ignored.

Signed-off-by: Kirtika Ruchandani <kirtika.ruchandani@gmail.com>
---
 net/wireless/nl80211.c | 103 ++++++++++++++++++++++++++-----------------------
 1 file changed, 54 insertions(+), 49 deletions(-)

diff --git a/net/wireless/nl80211.c b/net/wireless/nl80211.c
index 11cbf0b..ad7cdce 100644
--- a/net/wireless/nl80211.c
+++ b/net/wireless/nl80211.c
@@ -39,10 +39,10 @@ static void nl80211_post_doit(const struct genl_ops *ops, struct sk_buff *skb,

 /* the netlink family */
 static struct genl_family nl80211_fam = {
-	.id = GENL_ID_GENERATE,		/* don't bother with a hardcoded ID */
-	.name = NL80211_GENL_NAME,	/* have users key off the name instead */
-	.hdrsize = 0,			/* no private header */
-	.version = 1,			/* no particular meaning now */
+	.id = GENL_ID_GENERATE,	    /* don't bother with a hardcoded ID */
+	.name = NL80211_GENL_NAME,  /* have users key off the name instead */
+	.hdrsize = 0,		    /* no private header */
+	.version = 1,		    /* no particular meaning now */
 	.maxattr = NL80211_ATTR_MAX,
 	.netnsok = true,
 	.pre_doit = nl80211_pre_doit,
@@ -213,7 +213,7 @@ cfg80211_get_dev_from_info(struct net *netns, struct genl_info *info)
 static const struct nla_policy nl80211_policy[NUM_NL80211_ATTR] = {
 	[NL80211_ATTR_WIPHY] = { .type = NLA_U32 },
 	[NL80211_ATTR_WIPHY_NAME] = { .type = NLA_NUL_STRING,
-				      .len = 20-1 },
+				      .len = 20 - 1 },
 	[NL80211_ATTR_WIPHY_TXQ_PARAMS] = { .type = NLA_NESTED },

 	[NL80211_ATTR_WIPHY_FREQ] = { .type = NLA_U32 },
@@ -231,7 +231,7 @@ static const struct nla_policy nl80211_policy[NUM_NL80211_ATTR] = {

 	[NL80211_ATTR_IFTYPE] = { .type = NLA_U32 },
 	[NL80211_ATTR_IFINDEX] = { .type = NLA_U32 },
-	[NL80211_ATTR_IFNAME] = { .type = NLA_NUL_STRING, .len = IFNAMSIZ-1 },
+	[NL80211_ATTR_IFNAME] = { .type = NLA_NUL_STRING, .len = IFNAMSIZ - 1 },

 	[NL80211_ATTR_MAC] = { .len = ETH_ALEN },
 	[NL80211_ATTR_PREV_BSSID] = { .len = ETH_ALEN },
@@ -967,7 +967,7 @@ static int nl80211_put_iface_combinations(struct wiphy *wiphy,
 	int i, j;

 	nl_combis = nla_nest_start(msg,
-				NL80211_ATTR_INTERFACE_COMBINATIONS);
+				   NL80211_ATTR_INTERFACE_COMBINATIONS);
 	if (!nl_combis)
 		goto nla_put_failure;

@@ -1012,9 +1012,9 @@ static int nl80211_put_iface_combinations(struct wiphy *wiphy,
 			goto nla_put_failure;
 		if (large &&
 		    (nla_put_u32(msg, NL80211_IFACE_COMB_RADAR_DETECT_WIDTHS,
-				c->radar_detect_widths) ||
+				 c->radar_detect_widths) ||
 		     nla_put_u32(msg, NL80211_IFACE_COMB_RADAR_DETECT_REGIONS,
-				c->radar_detect_regions)))
+				 c->radar_detect_regions)))
 			goto nla_put_failure;

 		nla_nest_end(msg, nl_combi);
@@ -1493,7 +1493,7 @@ static int nl80211_send_wiphy(struct cfg80211_registered_device *rdev,

 		i = 0;
 #define CMD(op, n)							\
-		 do {							\
+		do {							\
 			if (rdev->ops->op) {				\
 				i++;					\
 				if (nla_put_u32(msg, i, NL80211_CMD_ ## n)) \
@@ -1735,8 +1735,9 @@ static int nl80211_send_wiphy(struct cfg80211_registered_device *rdev,
 			       rdev->wiphy.max_num_csa_counters))
 			goto nla_put_failure;

-		if (rdev->wiphy.regulatory_flags & REGULATORY_WIPHY_SELF_MANAGED &&
-		    nla_put_flag(msg, NL80211_ATTR_WIPHY_SELF_MANAGED_REG))
+		if ((rdev->wiphy.regulatory_flags &
+		     REGULATORY_WIPHY_SELF_MANAGED) &&
+		     nla_put_flag(msg, NL80211_ATTR_WIPHY_SELF_MANAGED_REG))
 			goto nla_put_failure;

 		if (nla_put(msg, NL80211_ATTR_EXT_FEATURES,
@@ -2299,7 +2300,7 @@ static int nl80211_set_wiphy(struct sk_buff *skb, struct genl_info *info)
 		if (frag_threshold < 256)
 			return -EINVAL;

-		if (frag_threshold != (u32) -1) {
+		if (frag_threshold != (u32)-1) {
 			/* Fragments (apart from the last one) are required to
 			 * have even length. Make the fragmentation code
 			 * simpler by stripping LSB should someone try to use
@@ -2406,7 +2407,8 @@ static int nl80211_send_chandef(struct sk_buff *msg,
 	return 0;
 }

-static int nl80211_send_iface(struct sk_buff *msg, u32 portid, u32 seq, int flags,
+static int nl80211_send_iface(struct sk_buff *msg,
+			      u32 portid, u32 seq, int flags,
 			      struct cfg80211_registered_device *rdev,
 			      struct wireless_dev *wdev, bool removal)
 {
@@ -2470,7 +2472,8 @@ static int nl80211_send_iface(struct sk_buff *msg, u32 portid, u32 seq, int flag
 	return -EMSGSIZE;
 }

-static int nl80211_dump_interface(struct sk_buff *skb, struct netlink_callback *cb)
+static int nl80211_dump_interface(struct sk_buff *skb,
+				  struct netlink_callback *cb)
 {
 	int wp_idx = 0;
 	int if_idx = 0;
@@ -2557,7 +2560,7 @@ static int parse_monitor_flags(struct nlattr *nla, u32 *mntrflags)

 	for (flag = 1; flag <= NL80211_MNTR_FLAG_MAX; flag++)
 		if (flags[flag])
-			*mntrflags |= (1<<flag);
+			*mntrflags |= (1 << flag);

 	return 0;
 }
@@ -2722,9 +2725,9 @@ static int nl80211_new_interface(struct sk_buff *skb, struct genl_info *info)
 		return -ENOMEM;

 	wdev = rdev_add_virtual_intf(rdev,
-				nla_data(info->attrs[NL80211_ATTR_IFNAME]),
-				NET_NAME_USER, type, err ? NULL : &flags,
-				&params);
+				     nla_data(info->attrs[NL80211_ATTR_IFNAME]),
+				     NET_NAME_USER, type, err ? NULL : &flags,
+				     &params);
 	if (WARN_ON(!wdev)) {
 		nlmsg_free(msg);
 		return -EPROTO;
@@ -3000,7 +3003,7 @@ static int nl80211_set_key(struct sk_buff *skb, struct genl_info *info)
 			goto out;

 		err = rdev_set_default_key(rdev, dev, key.idx,
-						 key.def_uni, key.def_multi);
+					   key.def_uni, key.def_multi);

 		if (err)
 			goto out;
@@ -3621,7 +3624,7 @@ static int parse_station_flags(struct genl_info *info,

 	for (flag = 1; flag <= NL80211_STA_FLAG_MAX; flag++) {
 		if (flags[flag]) {
-			params->sta_flags_set |= (1<<flag);
+			params->sta_flags_set |= (1 << flag);

 			/* no longer support new API additions in old API */
 			if (flag > NL80211_STA_FLAG_MAX_OLD_API)
@@ -3949,10 +3952,10 @@ static int nl80211_dump_station(struct sk_buff *skb,
 			goto out_err;

 		if (nl80211_send_station(skb, NL80211_CMD_NEW_STATION,
-				NETLINK_CB(cb->skb).portid,
-				cb->nlh->nlmsg_seq, NLM_F_MULTI,
-				rdev, wdev->netdev, mac_addr,
-				&sinfo) < 0)
+					 NETLINK_CB(cb->skb).portid,
+					 cb->nlh->nlmsg_seq, NLM_F_MULTI,
+					 rdev, wdev->netdev, mac_addr,
+					 &sinfo) < 0)
 			goto out;

 		sta_idx++;
@@ -4224,7 +4227,7 @@ static int nl80211_parse_sta_wme(struct genl_info *info,
 }

 static int nl80211_parse_sta_channel_info(struct genl_info *info,
-				      struct station_parameters *params)
+					  struct station_parameters *params)
 {
 	if (info->attrs[NL80211_ATTR_STA_SUPPORTED_CHANNELS]) {
 		params->supported_channels =
@@ -4655,9 +4658,9 @@ static int nl80211_del_station(struct sk_buff *skb, struct genl_info *info)
 }

 static int nl80211_send_mpath(struct sk_buff *msg, u32 portid, u32 seq,
-				int flags, struct net_device *dev,
-				u8 *dst, u8 *next_hop,
-				struct mpath_info *pinfo)
+			      int flags, struct net_device *dev,
+			      u8 *dst, u8 *next_hop,
+			      struct mpath_info *pinfo)
 {
 	void *hdr;
 	struct nlattr *pinfoattr;
@@ -4790,7 +4793,7 @@ static int nl80211_get_mpath(struct sk_buff *skb, struct genl_info *info)
 		return -ENOMEM;

 	if (nl80211_send_mpath(msg, info->snd_portid, info->snd_seq, 0,
-				 dev, dst, next_hop, &pinfo) < 0) {
+			       dev, dst, next_hop, &pinfo) < 0) {
 		nlmsg_free(msg);
 		return -ENOBUFS;
 	}
@@ -5185,7 +5188,8 @@ static int nl80211_get_mesh_config(struct sk_buff *skb,
 	return -ENOBUFS;
 }

-static const struct nla_policy nl80211_meshconf_params_policy[NL80211_MESHCONF_ATTR_MAX+1] = {
+static const
+struct nla_policy nl80211_meshconf_params_policy[NL80211_MESHCONF_ATTR_MAX + 1] = {
 	[NL80211_MESHCONF_RETRY_TIMEOUT] = { .type = NLA_U16 },
 	[NL80211_MESHCONF_CONFIRM_TIMEOUT] = { .type = NLA_U16 },
 	[NL80211_MESHCONF_HOLDING_TIMEOUT] = { .type = NLA_U16 },
@@ -5217,7 +5221,7 @@ static const struct nla_policy nl80211_meshconf_params_policy[NL80211_MESHCONF_A
 };

 static const struct nla_policy
-	nl80211_mesh_setup_params_policy[NL80211_MESH_SETUP_ATTR_MAX+1] = {
+	nl80211_mesh_setup_params_policy[NL80211_MESH_SETUP_ATTR_MAX + 1] = {
 	[NL80211_MESH_SETUP_ENABLE_VENDOR_SYNC] = { .type = NLA_U8 },
 	[NL80211_MESH_SETUP_ENABLE_VENDOR_PATH_SEL] = { .type = NLA_U8 },
 	[NL80211_MESH_SETUP_ENABLE_VENDOR_METRIC] = { .type = NLA_U8 },
@@ -5363,7 +5367,7 @@ do {									    \
 }

 static int nl80211_parse_mesh_setup(struct genl_info *info,
-				     struct mesh_setup *setup)
+				    struct mesh_setup *setup)
 {
 	struct cfg80211_registered_device *rdev = info->user_ptr[0];
 	struct nlattr *tb[NL80211_MESH_SETUP_ATTR_MAX + 1];
@@ -5672,7 +5676,7 @@ static const struct nla_policy reg_rule_policy[NL80211_REG_RULE_ATTR_MAX + 1] =
 };

 static int parse_reg_rule(struct nlattr *tb[],
-	struct ieee80211_reg_rule *reg_rule)
+			  struct ieee80211_reg_rule *reg_rule)
 {
 	struct ieee80211_freq_range *freq_range = &reg_rule->freq_range;
 	struct ieee80211_power_rule *power_rule = &reg_rule->power_rule;
@@ -6686,7 +6690,7 @@ static int nl80211_channel_switch(struct sk_buff *skb, struct genl_info *info)
 	/* csa_attrs is defined static to avoid waste of stack size - this
 	 * function is called under RTNL lock, so this should not be a problem.
 	 */
-	static struct nlattr *csa_attrs[NL80211_ATTR_MAX+1];
+	static struct nlattr *csa_attrs[NL80211_ATTR_MAX + 1];
 	int err;
 	bool need_new_beacon = false;
 	int len, i;
@@ -6982,8 +6986,8 @@ static int nl80211_dump_scan(struct sk_buff *skb, struct netlink_callback *cb)
 		if (++idx <= start)
 			continue;
 		if (nl80211_send_bss(skb, cb,
-				cb->nlh->nlmsg_seq, NLM_F_MULTI,
-				rdev, wdev, scan) < 0) {
+				     cb->nlh->nlmsg_seq, NLM_F_MULTI,
+				     rdev, wdev, scan) < 0) {
 			idx--;
 			break;
 		}
@@ -7035,7 +7039,7 @@ static int nl80211_send_survey(struct sk_buff *msg, u32 portid, u32 seq,
 		goto nla_put_failure;
 	if ((survey->filled & SURVEY_INFO_TIME) &&
 	    nla_put_u64_64bit(msg, NL80211_SURVEY_INFO_TIME,
-			survey->time, NL80211_SURVEY_INFO_PAD))
+			      survey->time, NL80211_SURVEY_INFO_PAD))
 		goto nla_put_failure;
 	if ((survey->filled & SURVEY_INFO_TIME_BUSY) &&
 	    nla_put_u64_64bit(msg, NL80211_SURVEY_INFO_TIME_BUSY,
@@ -7109,9 +7113,9 @@ static int nl80211_dump_survey(struct sk_buff *skb, struct netlink_callback *cb)
 		}

 		if (nl80211_send_survey(skb,
-				NETLINK_CB(cb->skb).portid,
-				cb->nlh->nlmsg_seq, NLM_F_MULTI,
-				wdev->netdev, radio_stats, &survey) < 0)
+					NETLINK_CB(cb->skb).portid,
+					cb->nlh->nlmsg_seq, NLM_F_MULTI,
+					wdev->netdev, radio_stats, &survey) < 0)
 			goto out;
 		survey_idx++;
 	}
@@ -7674,8 +7678,8 @@ static int nl80211_join_ibss(struct sk_buff *skb, struct genl_info *info)
 		bool no_ht = false;

 		connkeys = nl80211_parse_connkeys(rdev,
-					  info->attrs[NL80211_ATTR_KEYS],
-					  &no_ht);
+						  info->attrs[NL80211_ATTR_KEYS],
+						  &no_ht);
 		if (IS_ERR(connkeys))
 			return PTR_ERR(connkeys);

@@ -8022,7 +8026,7 @@ static int nl80211_connect(struct sk_buff *skb, struct genl_info *info)

 	connect.bg_scan_period = -1;
 	if (info->attrs[NL80211_ATTR_BG_SCAN_PERIOD] &&
-		(wiphy->flags & WIPHY_FLAG_SUPPORTS_FW_ROAM)) {
+	    (wiphy->flags & WIPHY_FLAG_SUPPORTS_FW_ROAM)) {
 		connect.bg_scan_period =
 			nla_get_u16(info->attrs[NL80211_ATTR_BG_SCAN_PERIOD]);
 	}
@@ -8067,7 +8071,8 @@ static int nl80211_connect(struct sk_buff *skb, struct genl_info *info)

 	if (connect.privacy && info->attrs[NL80211_ATTR_KEYS]) {
 		connkeys = nl80211_parse_connkeys(rdev,
-					  info->attrs[NL80211_ATTR_KEYS], NULL);
+						  info->attrs[NL80211_ATTR_KEYS],
+						  NULL);
 		if (IS_ERR(connkeys))
 			return PTR_ERR(connkeys);
 	}
@@ -9046,7 +9051,7 @@ static int nl80211_join_mesh(struct sk_buff *skb, struct genl_info *info)
 	if (info->attrs[NL80211_ATTR_MCAST_RATE] &&
 	    !nl80211_parse_mcast_rate(rdev, setup.mcast_rate,
 			    nla_get_u32(info->attrs[NL80211_ATTR_MCAST_RATE])))
-			return -EINVAL;
+		return -EINVAL;

 	if (info->attrs[NL80211_ATTR_BEACON_INTERVAL]) {
 		setup.beacon_interval =
@@ -12234,7 +12239,7 @@ void cfg80211_notify_new_peer_candidate(struct net_device *dev, const u8 *addr,
 	    nla_put_u32(msg, NL80211_ATTR_IFINDEX, dev->ifindex) ||
 	    nla_put(msg, NL80211_ATTR_MAC, ETH_ALEN, addr) ||
 	    (ie_len && ie &&
-	     nla_put(msg, NL80211_ATTR_IE, ie_len , ie)))
+	     nla_put(msg, NL80211_ATTR_IE, ie_len, ie)))
 		goto nla_put_failure;

 	genlmsg_end(msg, hdr);
@@ -12958,7 +12963,7 @@ static void nl80211_ch_switch_notify(struct cfg80211_registered_device *rdev,

 	if ((notif == NL80211_CMD_CH_SWITCH_STARTED_NOTIFY) &&
 	    (nla_put_u32(msg, NL80211_ATTR_CH_SWITCH_COUNT, count)))
-			goto nla_put_failure;
+		goto nla_put_failure;

 	genlmsg_end(msg, hdr);

@@ -13297,7 +13302,7 @@ void cfg80211_report_wowlan_wakeup(struct wireless_dev *wdev,

 		if (wakeup->net_detect &&
 		    cfg80211_net_detect_results(msg, wakeup))
-				goto free_msg;
+			goto free_msg;

 		nla_nest_end(msg, reasons);
 	}
