From: kbuild test robot <lkp@intel.com>
Subject: Re: [RFC v3 net-next 04/10] qed: Add slowpath L2 support
Date: Wed, 30 Sep 2015 21:59:28 +0800
Message-ID: <201509302101.J2pnChYQ%fengguang.wu@intel.com>
References: <1443618217-18069-5-git-send-email-Yuval.Mintz@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kbuild-all@01.org, netdev@vger.kernel.org, Ariel.Elior@qlogic.com,
	Yuval.Mintz@qlogic.com, Manish Chopra <Manish.Chopra@qlogic.com>
To: Yuval Mintz <Yuval.Mintz@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:37241 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752660AbbI3OAT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 Sep 2015 10:00:19 -0400
Content-Disposition: inline
In-Reply-To: <1443618217-18069-5-git-send-email-Yuval.Mintz@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Manish,

[auto build test results on v4.3-rc3 -- if it's inappropriate base, please ignore]

reproduce:
  # apt-get install sparse
  make ARCH=x86_64 allmodconfig
  make C=1 CF=-D__CHECK_ENDIAN__


sparse warnings: (new ones prefixed by >>)

>> drivers/net/ethernet/qlogic/qed/qed_l2.c:226:9: sparse: invalid assignment: &=
   drivers/net/ethernet/qlogic/qed/qed_l2.c:226:9:    left side has type restricted __le16
   drivers/net/ethernet/qlogic/qed/qed_l2.c:226:9:    right side has type int
   drivers/net/ethernet/qlogic/qed/qed_l2.c:226:9: sparse: invalid assignment: |=
   drivers/net/ethernet/qlogic/qed/qed_l2.c:226:9:    left side has type restricted __le16
   drivers/net/ethernet/qlogic/qed/qed_l2.c:226:9:    right side has type unsigned long long
   drivers/net/ethernet/qlogic/qed/qed_l2.c:229:9: sparse: invalid assignment: &=
   drivers/net/ethernet/qlogic/qed/qed_l2.c:229:9:    left side has type restricted __le16
   drivers/net/ethernet/qlogic/qed/qed_l2.c:229:9:    right side has type int
   drivers/net/ethernet/qlogic/qed/qed_l2.c:229:9: sparse: invalid assignment: |=
   drivers/net/ethernet/qlogic/qed/qed_l2.c:229:9:    left side has type restricted __le16
   drivers/net/ethernet/qlogic/qed/qed_l2.c:229:9:    right side has type unsigned long long
   drivers/net/ethernet/qlogic/qed/qed_l2.c:232:9: sparse: invalid assignment: &=
   drivers/net/ethernet/qlogic/qed/qed_l2.c:232:9:    left side has type restricted __le16
   drivers/net/ethernet/qlogic/qed/qed_l2.c:232:9:    right side has type int
   drivers/net/ethernet/qlogic/qed/qed_l2.c:232:9: sparse: invalid assignment: |=
   drivers/net/ethernet/qlogic/qed/qed_l2.c:232:9:    left side has type restricted __le16
   drivers/net/ethernet/qlogic/qed/qed_l2.c:232:9:    right side has type unsigned long long
   drivers/net/ethernet/qlogic/qed/qed_l2.c:235:9: sparse: invalid assignment: &=
   drivers/net/ethernet/qlogic/qed/qed_l2.c:235:9:    left side has type restricted __le16
   drivers/net/ethernet/qlogic/qed/qed_l2.c:235:9:    right side has type int
   drivers/net/ethernet/qlogic/qed/qed_l2.c:235:9: sparse: invalid assignment: |=
   drivers/net/ethernet/qlogic/qed/qed_l2.c:235:9:    left side has type restricted __le16
   drivers/net/ethernet/qlogic/qed/qed_l2.c:235:9:    right side has type unsigned long long
   drivers/net/ethernet/qlogic/qed/qed_l2.c:238:9: sparse: invalid assignment: &=
   drivers/net/ethernet/qlogic/qed/qed_l2.c:238:9:    left side has type restricted __le16
   drivers/net/ethernet/qlogic/qed/qed_l2.c:238:9:    right side has type int
   drivers/net/ethernet/qlogic/qed/qed_l2.c:238:9: sparse: invalid assignment: |=
   drivers/net/ethernet/qlogic/qed/qed_l2.c:238:9:    left side has type restricted __le16
   drivers/net/ethernet/qlogic/qed/qed_l2.c:238:9:    right side has type unsigned long long
   drivers/net/ethernet/qlogic/qed/qed_l2.c:241:9: sparse: invalid assignment: &=
   drivers/net/ethernet/qlogic/qed/qed_l2.c:241:9:    left side has type restricted __le16
   drivers/net/ethernet/qlogic/qed/qed_l2.c:241:9:    right side has type int
   drivers/net/ethernet/qlogic/qed/qed_l2.c:241:9: sparse: invalid assignment: |=
   drivers/net/ethernet/qlogic/qed/qed_l2.c:241:9:    left side has type restricted __le16
   drivers/net/ethernet/qlogic/qed/qed_l2.c:241:9:    right side has type unsigned long long
>> drivers/net/ethernet/qlogic/qed/qed_l2.c:247:17: sparse: cast from restricted __le16
   drivers/net/ethernet/qlogic/qed/qed_l2.c:296:17: sparse: invalid assignment: &=
   drivers/net/ethernet/qlogic/qed/qed_l2.c:296:17:    left side has type restricted __le16
   drivers/net/ethernet/qlogic/qed/qed_l2.c:296:17:    right side has type int
   drivers/net/ethernet/qlogic/qed/qed_l2.c:296:17: sparse: invalid assignment: |=
   drivers/net/ethernet/qlogic/qed/qed_l2.c:296:17:    left side has type restricted __le16
   drivers/net/ethernet/qlogic/qed/qed_l2.c:296:17:    right side has type unsigned long long
   drivers/net/ethernet/qlogic/qed/qed_l2.c:300:17: sparse: invalid assignment: &=
   drivers/net/ethernet/qlogic/qed/qed_l2.c:300:17:    left side has type restricted __le16
   drivers/net/ethernet/qlogic/qed/qed_l2.c:300:17:    right side has type int
   drivers/net/ethernet/qlogic/qed/qed_l2.c:300:17: sparse: invalid assignment: |=
   drivers/net/ethernet/qlogic/qed/qed_l2.c:300:17:    left side has type restricted __le16
   drivers/net/ethernet/qlogic/qed/qed_l2.c:300:17:    right side has type unsigned long long
   drivers/net/ethernet/qlogic/qed/qed_l2.c:303:17: sparse: invalid assignment: &=
   drivers/net/ethernet/qlogic/qed/qed_l2.c:303:17:    left side has type restricted __le16
   drivers/net/ethernet/qlogic/qed/qed_l2.c:303:17:    right side has type int
   drivers/net/ethernet/qlogic/qed/qed_l2.c:303:17: sparse: invalid assignment: |=
   drivers/net/ethernet/qlogic/qed/qed_l2.c:303:17:    left side has type restricted __le16
   drivers/net/ethernet/qlogic/qed/qed_l2.c:303:17:    right side has type unsigned long long
   drivers/net/ethernet/qlogic/qed/qed_l2.c:307:17: sparse: invalid assignment: &=
   drivers/net/ethernet/qlogic/qed/qed_l2.c:307:17:    left side has type restricted __le16
   drivers/net/ethernet/qlogic/qed/qed_l2.c:307:17:    right side has type int
   drivers/net/ethernet/qlogic/qed/qed_l2.c:307:17: sparse: invalid assignment: |=
   drivers/net/ethernet/qlogic/qed/qed_l2.c:307:17:    left side has type restricted __le16
   drivers/net/ethernet/qlogic/qed/qed_l2.c:307:17:    right side has type unsigned long long
   drivers/net/ethernet/qlogic/qed/qed_l2.c:311:17: sparse: invalid assignment: &=
   drivers/net/ethernet/qlogic/qed/qed_l2.c:311:17:    left side has type restricted __le16
   drivers/net/ethernet/qlogic/qed/qed_l2.c:311:17:    right side has type int
   drivers/net/ethernet/qlogic/qed/qed_l2.c:311:17: sparse: invalid assignment: |=
   drivers/net/ethernet/qlogic/qed/qed_l2.c:311:17:    left side has type restricted __le16
   drivers/net/ethernet/qlogic/qed/qed_l2.c:311:17:    right side has type unsigned long long
   drivers/net/ethernet/qlogic/qed/qed_l2.c:324:17: sparse: invalid assignment: &=
   drivers/net/ethernet/qlogic/qed/qed_l2.c:324:17:    left side has type restricted __le16
   drivers/net/ethernet/qlogic/qed/qed_l2.c:324:17:    right side has type int
   drivers/net/ethernet/qlogic/qed/qed_l2.c:324:17: sparse: invalid assignment: |=
   drivers/net/ethernet/qlogic/qed/qed_l2.c:324:17:    left side has type restricted __le16
   drivers/net/ethernet/qlogic/qed/qed_l2.c:324:17:    right side has type unsigned long long
   drivers/net/ethernet/qlogic/qed/qed_l2.c:327:17: sparse: invalid assignment: &=
   drivers/net/ethernet/qlogic/qed/qed_l2.c:327:17:    left side has type restricted __le16
   drivers/net/ethernet/qlogic/qed/qed_l2.c:327:17:    right side has type int
   drivers/net/ethernet/qlogic/qed/qed_l2.c:327:17: sparse: invalid assignment: |=
   drivers/net/ethernet/qlogic/qed/qed_l2.c:327:17:    left side has type restricted __le16
   drivers/net/ethernet/qlogic/qed/qed_l2.c:327:17:    right side has type unsigned long long
   drivers/net/ethernet/qlogic/qed/qed_l2.c:331:17: sparse: invalid assignment: &=
   drivers/net/ethernet/qlogic/qed/qed_l2.c:331:17:    left side has type restricted __le16
   drivers/net/ethernet/qlogic/qed/qed_l2.c:331:17:    right side has type int
   drivers/net/ethernet/qlogic/qed/qed_l2.c:331:17: sparse: invalid assignment: |=
   drivers/net/ethernet/qlogic/qed/qed_l2.c:331:17:    left side has type restricted __le16
   drivers/net/ethernet/qlogic/qed/qed_l2.c:331:17:    right side has type unsigned long long
   drivers/net/ethernet/qlogic/qed/qed_l2.c:334:17: sparse: invalid assignment: &=
   drivers/net/ethernet/qlogic/qed/qed_l2.c:334:17:    left side has type restricted __le16
   drivers/net/ethernet/qlogic/qed/qed_l2.c:334:17:    right side has type int
   drivers/net/ethernet/qlogic/qed/qed_l2.c:334:17: sparse: invalid assignment: |=
   drivers/net/ethernet/qlogic/qed/qed_l2.c:334:17:    left side has type restricted __le16
   drivers/net/ethernet/qlogic/qed/qed_l2.c:334:17:    right side has type unsigned long long
   drivers/net/ethernet/qlogic/qed/qed_l2.c:338:17: sparse: invalid assignment: &=
   drivers/net/ethernet/qlogic/qed/qed_l2.c:338:17:    left side has type restricted __le16
   drivers/net/ethernet/qlogic/qed/qed_l2.c:338:17:    right side has type int
   drivers/net/ethernet/qlogic/qed/qed_l2.c:338:17: sparse: invalid assignment: |=
   drivers/net/ethernet/qlogic/qed/qed_l2.c:338:17:    left side has type restricted __le16
   drivers/net/ethernet/qlogic/qed/qed_l2.c:338:17:    right side has type unsigned long long

vim +226 drivers/net/ethernet/qlogic/qed/qed_l2.c

   220	
   221		p_ramrod->rss_config.rss_mode = p_rss_params->rss_enable ?
   222			ETH_VPORT_RSS_MODE_REGULAR : ETH_VPORT_RSS_MODE_DISABLED;
   223	
   224		p_ramrod->rss_config.capabilities = 0;
   225	
 > 226		SET_FIELD(p_ramrod->rss_config.capabilities,
   227			  ETH_VPORT_RSS_CONFIG_IPV4_CAPABILITY,
   228			  !!(p_rss_params->rss_caps & QED_RSS_IPV4));
   229		SET_FIELD(p_ramrod->rss_config.capabilities,
   230			  ETH_VPORT_RSS_CONFIG_IPV6_CAPABILITY,
   231			  !!(p_rss_params->rss_caps & QED_RSS_IPV6));
   232		SET_FIELD(p_ramrod->rss_config.capabilities,
   233			  ETH_VPORT_RSS_CONFIG_IPV4_TCP_CAPABILITY,
   234			  !!(p_rss_params->rss_caps & QED_RSS_IPV4_TCP));
   235		SET_FIELD(p_ramrod->rss_config.capabilities,
   236			  ETH_VPORT_RSS_CONFIG_IPV6_TCP_CAPABILITY,
   237			  !!(p_rss_params->rss_caps & QED_RSS_IPV6_TCP));
 > 238		SET_FIELD(p_ramrod->rss_config.capabilities,
   239			  ETH_VPORT_RSS_CONFIG_IPV4_UDP_CAPABILITY,
   240			  !!(p_rss_params->rss_caps & QED_RSS_IPV4_UDP));
   241		SET_FIELD(p_ramrod->rss_config.capabilities,
   242			  ETH_VPORT_RSS_CONFIG_IPV6_UDP_CAPABILITY,
   243			  !!(p_rss_params->rss_caps & QED_RSS_IPV6_UDP));
   244		p_ramrod->rss_config.tbl_size =
   245			p_rss_params->rss_table_size_log;
   246		p_ramrod->rss_config.capabilities =
 > 247			cpu_to_le16(p_ramrod->rss_config.capabilities);
   248	
   249		DP_VERBOSE(
   250			p_hwfn,

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation
