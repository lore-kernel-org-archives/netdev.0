From: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Subject: [PATCH 2/2] net/ipv6/addrconf: fix sysctl table indentation
Date: Mon, 18 Apr 2016 14:41:17 +0300
Message-ID: <146097967761.15409.8428180075560908884.stgit@buzz>
References: <146097967035.15409.8235893232862124602.stgit@buzz>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <146097967035.15409.8235893232862124602.stgit@buzz>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Separated from previous patch for readability.

Signed-off-by: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
---
 net/ipv6/addrconf.c |  616 +++++++++++++++++++++++++--------------------------
 1 file changed, 307 insertions(+), 309 deletions(-)

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 8a724c7136b0..51574ba5d328 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -5618,323 +5618,321 @@ int addrconf_sysctl_ignore_routes_with_linkdown(struct ctl_table *ctl,
 }
 
 static const struct ctl_table addrconf_sysctl[] = {
-		{
-			.procname	= "forwarding",
-			.data		= &ipv6_devconf.forwarding,
-			.maxlen		= sizeof(int),
-			.mode		= 0644,
-			.proc_handler	= addrconf_sysctl_forward,
-		},
-		{
-			.procname	= "hop_limit",
-			.data		= &ipv6_devconf.hop_limit,
-			.maxlen		= sizeof(int),
-			.mode		= 0644,
-			.proc_handler	= addrconf_sysctl_hop_limit,
-		},
-		{
-			.procname	= "mtu",
-			.data		= &ipv6_devconf.mtu6,
-			.maxlen		= sizeof(int),
-			.mode		= 0644,
-			.proc_handler	= addrconf_sysctl_mtu,
-		},
-		{
-			.procname	= "accept_ra",
-			.data		= &ipv6_devconf.accept_ra,
-			.maxlen		= sizeof(int),
-			.mode		= 0644,
-			.proc_handler	= proc_dointvec,
-		},
-		{
-			.procname	= "accept_redirects",
-			.data		= &ipv6_devconf.accept_redirects,
-			.maxlen		= sizeof(int),
-			.mode		= 0644,
-			.proc_handler	= proc_dointvec,
-		},
-		{
-			.procname	= "autoconf",
-			.data		= &ipv6_devconf.autoconf,
-			.maxlen		= sizeof(int),
-			.mode		= 0644,
-			.proc_handler	= proc_dointvec,
-		},
-		{
-			.procname	= "dad_transmits",
-			.data		= &ipv6_devconf.dad_transmits,
-			.maxlen		= sizeof(int),
-			.mode		= 0644,
-			.proc_handler	= proc_dointvec,
-		},
-		{
-			.procname	= "router_solicitations",
-			.data		= &ipv6_devconf.rtr_solicits,
-			.maxlen		= sizeof(int),
-			.mode		= 0644,
-			.proc_handler	= proc_dointvec,
-		},
-		{
-			.procname	= "router_solicitation_interval",
-			.data		= &ipv6_devconf.rtr_solicit_interval,
-			.maxlen		= sizeof(int),
-			.mode		= 0644,
-			.proc_handler	= proc_dointvec_jiffies,
-		},
-		{
-			.procname	= "router_solicitation_delay",
-			.data		= &ipv6_devconf.rtr_solicit_delay,
-			.maxlen		= sizeof(int),
-			.mode		= 0644,
-			.proc_handler	= proc_dointvec_jiffies,
-		},
-		{
-			.procname	= "force_mld_version",
-			.data		= &ipv6_devconf.force_mld_version,
-			.maxlen		= sizeof(int),
-			.mode		= 0644,
-			.proc_handler	= proc_dointvec,
-		},
-		{
-			.procname	= "mldv1_unsolicited_report_interval",
-			.data		=
-				&ipv6_devconf.mldv1_unsolicited_report_interval,
-			.maxlen		= sizeof(int),
-			.mode		= 0644,
-			.proc_handler	= proc_dointvec_ms_jiffies,
-		},
-		{
-			.procname	= "mldv2_unsolicited_report_interval",
-			.data		=
-				&ipv6_devconf.mldv2_unsolicited_report_interval,
-			.maxlen		= sizeof(int),
-			.mode		= 0644,
-			.proc_handler	= proc_dointvec_ms_jiffies,
-		},
-		{
-			.procname	= "use_tempaddr",
-			.data		= &ipv6_devconf.use_tempaddr,
-			.maxlen		= sizeof(int),
-			.mode		= 0644,
-			.proc_handler	= proc_dointvec,
-		},
-		{
-			.procname	= "temp_valid_lft",
-			.data		= &ipv6_devconf.temp_valid_lft,
-			.maxlen		= sizeof(int),
-			.mode		= 0644,
-			.proc_handler	= proc_dointvec,
-		},
-		{
-			.procname	= "temp_prefered_lft",
-			.data		= &ipv6_devconf.temp_prefered_lft,
-			.maxlen		= sizeof(int),
-			.mode		= 0644,
-			.proc_handler	= proc_dointvec,
-		},
-		{
-			.procname	= "regen_max_retry",
-			.data		= &ipv6_devconf.regen_max_retry,
-			.maxlen		= sizeof(int),
-			.mode		= 0644,
-			.proc_handler	= proc_dointvec,
-		},
-		{
-			.procname	= "max_desync_factor",
-			.data		= &ipv6_devconf.max_desync_factor,
-			.maxlen		= sizeof(int),
-			.mode		= 0644,
-			.proc_handler	= proc_dointvec,
-		},
-		{
-			.procname	= "max_addresses",
-			.data		= &ipv6_devconf.max_addresses,
-			.maxlen		= sizeof(int),
-			.mode		= 0644,
-			.proc_handler	= proc_dointvec,
-		},
-		{
-			.procname	= "accept_ra_defrtr",
-			.data		= &ipv6_devconf.accept_ra_defrtr,
-			.maxlen		= sizeof(int),
-			.mode		= 0644,
-			.proc_handler	= proc_dointvec,
-		},
-		{
-			.procname	= "accept_ra_min_hop_limit",
-			.data		= &ipv6_devconf.accept_ra_min_hop_limit,
-			.maxlen		= sizeof(int),
-			.mode		= 0644,
-			.proc_handler	= proc_dointvec,
-		},
-		{
-			.procname	= "accept_ra_pinfo",
-			.data		= &ipv6_devconf.accept_ra_pinfo,
-			.maxlen		= sizeof(int),
-			.mode		= 0644,
-			.proc_handler	= proc_dointvec,
-		},
+	{
+		.procname	= "forwarding",
+		.data		= &ipv6_devconf.forwarding,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= addrconf_sysctl_forward,
+	},
+	{
+		.procname	= "hop_limit",
+		.data		= &ipv6_devconf.hop_limit,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= addrconf_sysctl_hop_limit,
+	},
+	{
+		.procname	= "mtu",
+		.data		= &ipv6_devconf.mtu6,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= addrconf_sysctl_mtu,
+	},
+	{
+		.procname	= "accept_ra",
+		.data		= &ipv6_devconf.accept_ra,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec,
+	},
+	{
+		.procname	= "accept_redirects",
+		.data		= &ipv6_devconf.accept_redirects,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec,
+	},
+	{
+		.procname	= "autoconf",
+		.data		= &ipv6_devconf.autoconf,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec,
+	},
+	{
+		.procname	= "dad_transmits",
+		.data		= &ipv6_devconf.dad_transmits,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec,
+	},
+	{
+		.procname	= "router_solicitations",
+		.data		= &ipv6_devconf.rtr_solicits,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec,
+	},
+	{
+		.procname	= "router_solicitation_interval",
+		.data		= &ipv6_devconf.rtr_solicit_interval,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec_jiffies,
+	},
+	{
+		.procname	= "router_solicitation_delay",
+		.data		= &ipv6_devconf.rtr_solicit_delay,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec_jiffies,
+	},
+	{
+		.procname	= "force_mld_version",
+		.data		= &ipv6_devconf.force_mld_version,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec,
+	},
+	{
+		.procname	= "mldv1_unsolicited_report_interval",
+		.data		=
+			&ipv6_devconf.mldv1_unsolicited_report_interval,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec_ms_jiffies,
+	},
+	{
+		.procname	= "mldv2_unsolicited_report_interval",
+		.data		=
+			&ipv6_devconf.mldv2_unsolicited_report_interval,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec_ms_jiffies,
+	},
+	{
+		.procname	= "use_tempaddr",
+		.data		= &ipv6_devconf.use_tempaddr,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec,
+	},
+	{
+		.procname	= "temp_valid_lft",
+		.data		= &ipv6_devconf.temp_valid_lft,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec,
+	},
+	{
+		.procname	= "temp_prefered_lft",
+		.data		= &ipv6_devconf.temp_prefered_lft,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec,
+	},
+	{
+		.procname	= "regen_max_retry",
+		.data		= &ipv6_devconf.regen_max_retry,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec,
+	},
+	{
+		.procname	= "max_desync_factor",
+		.data		= &ipv6_devconf.max_desync_factor,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec,
+	},
+	{
+		.procname	= "max_addresses",
+		.data		= &ipv6_devconf.max_addresses,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec,
+	},
+	{
+		.procname	= "accept_ra_defrtr",
+		.data		= &ipv6_devconf.accept_ra_defrtr,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec,
+	},
+	{
+		.procname	= "accept_ra_min_hop_limit",
+		.data		= &ipv6_devconf.accept_ra_min_hop_limit,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec,
+	},
+	{
+		.procname	= "accept_ra_pinfo",
+		.data		= &ipv6_devconf.accept_ra_pinfo,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec,
+	},
 #ifdef CONFIG_IPV6_ROUTER_PREF
-		{
-			.procname	= "accept_ra_rtr_pref",
-			.data		= &ipv6_devconf.accept_ra_rtr_pref,
-			.maxlen		= sizeof(int),
-			.mode		= 0644,
-			.proc_handler	= proc_dointvec,
-		},
-		{
-			.procname	= "router_probe_interval",
-			.data		= &ipv6_devconf.rtr_probe_interval,
-			.maxlen		= sizeof(int),
-			.mode		= 0644,
-			.proc_handler	= proc_dointvec_jiffies,
-		},
+	{
+		.procname	= "accept_ra_rtr_pref",
+		.data		= &ipv6_devconf.accept_ra_rtr_pref,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec,
+	},
+	{
+		.procname	= "router_probe_interval",
+		.data		= &ipv6_devconf.rtr_probe_interval,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec_jiffies,
+	},
 #ifdef CONFIG_IPV6_ROUTE_INFO
-		{
-			.procname	= "accept_ra_rt_info_max_plen",
-			.data		= &ipv6_devconf.accept_ra_rt_info_max_plen,
-			.maxlen		= sizeof(int),
-			.mode		= 0644,
-			.proc_handler	= proc_dointvec,
-		},
+	{
+		.procname	= "accept_ra_rt_info_max_plen",
+		.data		= &ipv6_devconf.accept_ra_rt_info_max_plen,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec,
+	},
 #endif
 #endif
-		{
-			.procname	= "proxy_ndp",
-			.data		= &ipv6_devconf.proxy_ndp,
-			.maxlen		= sizeof(int),
-			.mode		= 0644,
-			.proc_handler	= addrconf_sysctl_proxy_ndp,
-		},
-		{
-			.procname	= "accept_source_route",
-			.data		= &ipv6_devconf.accept_source_route,
-			.maxlen		= sizeof(int),
-			.mode		= 0644,
-			.proc_handler	= proc_dointvec,
-		},
+	{
+		.procname	= "proxy_ndp",
+		.data		= &ipv6_devconf.proxy_ndp,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= addrconf_sysctl_proxy_ndp,
+	},
+	{
+		.procname	= "accept_source_route",
+		.data		= &ipv6_devconf.accept_source_route,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec,
+	},
 #ifdef CONFIG_IPV6_OPTIMISTIC_DAD
-		{
-			.procname       = "optimistic_dad",
-			.data           = &ipv6_devconf.optimistic_dad,
-			.maxlen         = sizeof(int),
-			.mode           = 0644,
-			.proc_handler   = proc_dointvec,
-
-		},
-		{
-			.procname       = "use_optimistic",
-			.data           = &ipv6_devconf.use_optimistic,
-			.maxlen         = sizeof(int),
-			.mode           = 0644,
-			.proc_handler   = proc_dointvec,
-
-		},
+	{
+		.procname	= "optimistic_dad",
+		.data		= &ipv6_devconf.optimistic_dad,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler   = proc_dointvec,
+	},
+	{
+		.procname	= "use_optimistic",
+		.data		= &ipv6_devconf.use_optimistic,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec,
+	},
 #endif
 #ifdef CONFIG_IPV6_MROUTE
-		{
-			.procname	= "mc_forwarding",
-			.data		= &ipv6_devconf.mc_forwarding,
-			.maxlen		= sizeof(int),
-			.mode		= 0444,
-			.proc_handler	= proc_dointvec,
-		},
+	{
+		.procname	= "mc_forwarding",
+		.data		= &ipv6_devconf.mc_forwarding,
+		.maxlen		= sizeof(int),
+		.mode		= 0444,
+		.proc_handler	= proc_dointvec,
+	},
 #endif
-		{
-			.procname	= "disable_ipv6",
-			.data		= &ipv6_devconf.disable_ipv6,
-			.maxlen		= sizeof(int),
-			.mode		= 0644,
-			.proc_handler	= addrconf_sysctl_disable,
-		},
-		{
-			.procname	= "accept_dad",
-			.data		= &ipv6_devconf.accept_dad,
-			.maxlen		= sizeof(int),
-			.mode		= 0644,
-			.proc_handler	= proc_dointvec,
-		},
-		{
-			.procname       = "force_tllao",
-			.data           = &ipv6_devconf.force_tllao,
-			.maxlen         = sizeof(int),
-			.mode           = 0644,
-			.proc_handler   = proc_dointvec
-		},
-		{
-			.procname       = "ndisc_notify",
-			.data           = &ipv6_devconf.ndisc_notify,
-			.maxlen         = sizeof(int),
-			.mode           = 0644,
-			.proc_handler   = proc_dointvec
-		},
-		{
-			.procname	= "suppress_frag_ndisc",
-			.data		= &ipv6_devconf.suppress_frag_ndisc,
-			.maxlen		= sizeof(int),
-			.mode		= 0644,
-			.proc_handler	= proc_dointvec
-		},
-		{
-			.procname	= "accept_ra_from_local",
-			.data		= &ipv6_devconf.accept_ra_from_local,
-			.maxlen		= sizeof(int),
-			.mode		= 0644,
-			.proc_handler	= proc_dointvec,
-		},
-		{
-			.procname	= "accept_ra_mtu",
-			.data		= &ipv6_devconf.accept_ra_mtu,
-			.maxlen		= sizeof(int),
-			.mode		= 0644,
-			.proc_handler	= proc_dointvec,
-		},
-		{
-			.procname	= "stable_secret",
-			.data		= &ipv6_devconf.stable_secret,
-			.maxlen		= IPV6_MAX_STRLEN,
-			.mode		= 0600,
-			.proc_handler	= addrconf_sysctl_stable_secret,
-		},
-		{
-			.procname       = "use_oif_addrs_only",
-			.data           = &ipv6_devconf.use_oif_addrs_only,
-			.maxlen         = sizeof(int),
-			.mode           = 0644,
-			.proc_handler   = proc_dointvec,
-		},
-		{
-			.procname	= "ignore_routes_with_linkdown",
-			.data		= &ipv6_devconf.ignore_routes_with_linkdown,
-			.maxlen		= sizeof(int),
-			.mode		= 0644,
-			.proc_handler	= addrconf_sysctl_ignore_routes_with_linkdown,
-		},
-		{
-			.procname	= "drop_unicast_in_l2_multicast",
-			.data		= &ipv6_devconf.drop_unicast_in_l2_multicast,
-			.maxlen		= sizeof(int),
-			.mode		= 0644,
-			.proc_handler	= proc_dointvec,
-		},
-		{
-			.procname	= "drop_unsolicited_na",
-			.data		= &ipv6_devconf.drop_unsolicited_na,
-			.maxlen		= sizeof(int),
-			.mode		= 0644,
-			.proc_handler	= proc_dointvec,
-		},
-		{
-			.procname       = "keep_addr_on_down",
-			.data           = &ipv6_devconf.keep_addr_on_down,
-			.maxlen         = sizeof(int),
-			.mode           = 0644,
-			.proc_handler   = proc_dointvec,
-
-		},
-		{
-			/* sentinel */
-		}
+	{
+		.procname	= "disable_ipv6",
+		.data		= &ipv6_devconf.disable_ipv6,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= addrconf_sysctl_disable,
+	},
+	{
+		.procname	= "accept_dad",
+		.data		= &ipv6_devconf.accept_dad,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec,
+	},
+	{
+		.procname	= "force_tllao",
+		.data		= &ipv6_devconf.force_tllao,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec
+	},
+	{
+		.procname	= "ndisc_notify",
+		.data		= &ipv6_devconf.ndisc_notify,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec
+	},
+	{
+		.procname	= "suppress_frag_ndisc",
+		.data		= &ipv6_devconf.suppress_frag_ndisc,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec
+	},
+	{
+		.procname	= "accept_ra_from_local",
+		.data		= &ipv6_devconf.accept_ra_from_local,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec,
+	},
+	{
+		.procname	= "accept_ra_mtu",
+		.data		= &ipv6_devconf.accept_ra_mtu,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec,
+	},
+	{
+		.procname	= "stable_secret",
+		.data		= &ipv6_devconf.stable_secret,
+		.maxlen		= IPV6_MAX_STRLEN,
+		.mode		= 0600,
+		.proc_handler	= addrconf_sysctl_stable_secret,
+	},
+	{
+		.procname	= "use_oif_addrs_only",
+		.data		= &ipv6_devconf.use_oif_addrs_only,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec,
+	},
+	{
+		.procname	= "ignore_routes_with_linkdown",
+		.data		= &ipv6_devconf.ignore_routes_with_linkdown,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= addrconf_sysctl_ignore_routes_with_linkdown,
+	},
+	{
+		.procname	= "drop_unicast_in_l2_multicast",
+		.data		= &ipv6_devconf.drop_unicast_in_l2_multicast,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec,
+	},
+	{
+		.procname	= "drop_unsolicited_na",
+		.data		= &ipv6_devconf.drop_unsolicited_na,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec,
+	},
+	{
+		.procname	= "keep_addr_on_down",
+		.data		= &ipv6_devconf.keep_addr_on_down,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec,
+
+	},
+	{
+		/* sentinel */
+	}
 };
 
 static int __addrconf_sysctl_register(struct net *net, char *dev_name,
