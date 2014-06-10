From: Milos Vyletel <milos.vyletel@gmail.com>
Subject: [patch net-next 2/5] ipv6: rename DEVCONF* to IPV6_DEVCONF* to align with ipv4
Date: Tue, 10 Jun 2014 12:19:10 -0400
Message-ID: <1402417153-2551-3-git-send-email-milos.vyletel@gmail.com>
References: <1402417153-2551-1-git-send-email-milos.vyletel@gmail.com>
Cc: Milos Vyletel <milos.vyletel@gmail.com>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	linux-kernel@vger.kernel.org (open list)
To: davem@davemloft.net, amwang@redhat.com, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1402417153-2551-1-git-send-email-milos.vyletel@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use IPV6_DEVCONF* name similar to the IPV4_DEVCONF* used in ipv4.
Another step in aligning code.

Signed-off-by: Milos Vyletel <milos.vyletel@gmail.com>
---
 include/uapi/linux/ipv6.h | 68 +++++++++++++++++++++----------------------
 net/ipv6/addrconf.c       | 74 +++++++++++++++++++++++------------------------
 2 files changed, 71 insertions(+), 71 deletions(-)

diff --git a/include/uapi/linux/ipv6.h b/include/uapi/linux/ipv6.h
index 593b0e3..715559a 100644
--- a/include/uapi/linux/ipv6.h
+++ b/include/uapi/linux/ipv6.h
@@ -130,40 +130,40 @@ struct ipv6hdr {
 
 /* index values for the variables in ipv6_devconf */
 enum {
-	DEVCONF_FORWARDING = 0,
-	DEVCONF_HOPLIMIT,
-	DEVCONF_MTU6,
-	DEVCONF_ACCEPT_RA,
-	DEVCONF_ACCEPT_REDIRECTS,
-	DEVCONF_AUTOCONF,
-	DEVCONF_DAD_TRANSMITS,
-	DEVCONF_RTR_SOLICITS,
-	DEVCONF_RTR_SOLICIT_INTERVAL,
-	DEVCONF_RTR_SOLICIT_DELAY,
-	DEVCONF_USE_TEMPADDR,
-	DEVCONF_TEMP_VALID_LFT,
-	DEVCONF_TEMP_PREFERED_LFT,
-	DEVCONF_REGEN_MAX_RETRY,
-	DEVCONF_MAX_DESYNC_FACTOR,
-	DEVCONF_MAX_ADDRESSES,
-	DEVCONF_FORCE_MLD_VERSION,
-	DEVCONF_ACCEPT_RA_DEFRTR,
-	DEVCONF_ACCEPT_RA_PINFO,
-	DEVCONF_ACCEPT_RA_RTR_PREF,
-	DEVCONF_RTR_PROBE_INTERVAL,
-	DEVCONF_ACCEPT_RA_RT_INFO_MAX_PLEN,
-	DEVCONF_PROXY_NDP,
-	DEVCONF_OPTIMISTIC_DAD,
-	DEVCONF_ACCEPT_SOURCE_ROUTE,
-	DEVCONF_MC_FORWARDING,
-	DEVCONF_DISABLE_IPV6,
-	DEVCONF_ACCEPT_DAD,
-	DEVCONF_FORCE_TLLAO,
-	DEVCONF_NDISC_NOTIFY,
-	DEVCONF_MLDV1_UNSOLICITED_REPORT_INTERVAL,
-	DEVCONF_MLDV2_UNSOLICITED_REPORT_INTERVAL,
-	DEVCONF_SUPPRESS_FRAG_NDISC,
-	DEVCONF_MAX
+	IPV6_DEVCONF_FORWARDING = 0,
+	IPV6_DEVCONF_HOPLIMIT,
+	IPV6_DEVCONF_MTU6,
+	IPV6_DEVCONF_ACCEPT_RA,
+	IPV6_DEVCONF_ACCEPT_REDIRECTS,
+	IPV6_DEVCONF_AUTOCONF,
+	IPV6_DEVCONF_DAD_TRANSMITS,
+	IPV6_DEVCONF_RTR_SOLICITS,
+	IPV6_DEVCONF_RTR_SOLICIT_INTERVAL,
+	IPV6_DEVCONF_RTR_SOLICIT_DELAY,
+	IPV6_DEVCONF_USE_TEMPADDR,
+	IPV6_DEVCONF_TEMP_VALID_LFT,
+	IPV6_DEVCONF_TEMP_PREFERED_LFT,
+	IPV6_DEVCONF_REGEN_MAX_RETRY,
+	IPV6_DEVCONF_MAX_DESYNC_FACTOR,
+	IPV6_DEVCONF_MAX_ADDRESSES,
+	IPV6_DEVCONF_FORCE_MLD_VERSION,
+	IPV6_DEVCONF_ACCEPT_RA_DEFRTR,
+	IPV6_DEVCONF_ACCEPT_RA_PINFO,
+	IPV6_DEVCONF_ACCEPT_RA_RTR_PREF,
+	IPV6_DEVCONF_RTR_PROBE_INTERVAL,
+	IPV6_DEVCONF_ACCEPT_RA_RT_INFO_MAX_PLEN,
+	IPV6_DEVCONF_PROXY_NDP,
+	IPV6_DEVCONF_OPTIMISTIC_DAD,
+	IPV6_DEVCONF_ACCEPT_SOURCE_ROUTE,
+	IPV6_DEVCONF_MC_FORWARDING,
+	IPV6_DEVCONF_DISABLE_IPV6,
+	IPV6_DEVCONF_ACCEPT_DAD,
+	IPV6_DEVCONF_FORCE_TLLAO,
+	IPV6_DEVCONF_NDISC_NOTIFY,
+	IPV6_DEVCONF_MLDV1_UNSOLICITED_REPORT_INTERVAL,
+	IPV6_DEVCONF_MLDV2_UNSOLICITED_REPORT_INTERVAL,
+	IPV6_DEVCONF_SUPPRESS_FRAG_NDISC,
+	IPV6_DEVCONF_MAX
 };
 
 
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index dbacca4..24fbb38 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -4272,62 +4272,62 @@ errout:
 static inline void ipv6_store_devconf(struct ipv6_devconf *cnf,
 				__s32 *array, int bytes)
 {
-	BUG_ON(bytes < (DEVCONF_MAX * 4));
+	BUG_ON(bytes < (IPV6_DEVCONF_MAX * 4));
 
 	memset(array, 0, bytes);
-	array[DEVCONF_FORWARDING] = cnf->forwarding;
-	array[DEVCONF_HOPLIMIT] = cnf->hop_limit;
-	array[DEVCONF_MTU6] = cnf->mtu6;
-	array[DEVCONF_ACCEPT_RA] = cnf->accept_ra;
-	array[DEVCONF_ACCEPT_REDIRECTS] = cnf->accept_redirects;
-	array[DEVCONF_AUTOCONF] = cnf->autoconf;
-	array[DEVCONF_DAD_TRANSMITS] = cnf->dad_transmits;
-	array[DEVCONF_RTR_SOLICITS] = cnf->rtr_solicits;
-	array[DEVCONF_RTR_SOLICIT_INTERVAL] =
+	array[IPV6_DEVCONF_FORWARDING] = cnf->forwarding;
+	array[IPV6_DEVCONF_HOPLIMIT] = cnf->hop_limit;
+	array[IPV6_DEVCONF_MTU6] = cnf->mtu6;
+	array[IPV6_DEVCONF_ACCEPT_RA] = cnf->accept_ra;
+	array[IPV6_DEVCONF_ACCEPT_REDIRECTS] = cnf->accept_redirects;
+	array[IPV6_DEVCONF_AUTOCONF] = cnf->autoconf;
+	array[IPV6_DEVCONF_DAD_TRANSMITS] = cnf->dad_transmits;
+	array[IPV6_DEVCONF_RTR_SOLICITS] = cnf->rtr_solicits;
+	array[IPV6_DEVCONF_RTR_SOLICIT_INTERVAL] =
 		jiffies_to_msecs(cnf->rtr_solicit_interval);
-	array[DEVCONF_RTR_SOLICIT_DELAY] =
+	array[IPV6_DEVCONF_RTR_SOLICIT_DELAY] =
 		jiffies_to_msecs(cnf->rtr_solicit_delay);
-	array[DEVCONF_FORCE_MLD_VERSION] = cnf->force_mld_version;
-	array[DEVCONF_MLDV1_UNSOLICITED_REPORT_INTERVAL] =
+	array[IPV6_DEVCONF_FORCE_MLD_VERSION] = cnf->force_mld_version;
+	array[IPV6_DEVCONF_MLDV1_UNSOLICITED_REPORT_INTERVAL] =
 		jiffies_to_msecs(cnf->mldv1_unsolicited_report_interval);
-	array[DEVCONF_MLDV2_UNSOLICITED_REPORT_INTERVAL] =
+	array[IPV6_DEVCONF_MLDV2_UNSOLICITED_REPORT_INTERVAL] =
 		jiffies_to_msecs(cnf->mldv2_unsolicited_report_interval);
-	array[DEVCONF_USE_TEMPADDR] = cnf->use_tempaddr;
-	array[DEVCONF_TEMP_VALID_LFT] = cnf->temp_valid_lft;
-	array[DEVCONF_TEMP_PREFERED_LFT] = cnf->temp_prefered_lft;
-	array[DEVCONF_REGEN_MAX_RETRY] = cnf->regen_max_retry;
-	array[DEVCONF_MAX_DESYNC_FACTOR] = cnf->max_desync_factor;
-	array[DEVCONF_MAX_ADDRESSES] = cnf->max_addresses;
-	array[DEVCONF_ACCEPT_RA_DEFRTR] = cnf->accept_ra_defrtr;
-	array[DEVCONF_ACCEPT_RA_PINFO] = cnf->accept_ra_pinfo;
+	array[IPV6_DEVCONF_USE_TEMPADDR] = cnf->use_tempaddr;
+	array[IPV6_DEVCONF_TEMP_VALID_LFT] = cnf->temp_valid_lft;
+	array[IPV6_DEVCONF_TEMP_PREFERED_LFT] = cnf->temp_prefered_lft;
+	array[IPV6_DEVCONF_REGEN_MAX_RETRY] = cnf->regen_max_retry;
+	array[IPV6_DEVCONF_MAX_DESYNC_FACTOR] = cnf->max_desync_factor;
+	array[IPV6_DEVCONF_MAX_ADDRESSES] = cnf->max_addresses;
+	array[IPV6_DEVCONF_ACCEPT_RA_DEFRTR] = cnf->accept_ra_defrtr;
+	array[IPV6_DEVCONF_ACCEPT_RA_PINFO] = cnf->accept_ra_pinfo;
 #ifdef CONFIG_IPV6_ROUTER_PREF
-	array[DEVCONF_ACCEPT_RA_RTR_PREF] = cnf->accept_ra_rtr_pref;
-	array[DEVCONF_RTR_PROBE_INTERVAL] =
+	array[IPV6_DEVCONF_ACCEPT_RA_RTR_PREF] = cnf->accept_ra_rtr_pref;
+	array[IPV6_DEVCONF_RTR_PROBE_INTERVAL] =
 		jiffies_to_msecs(cnf->rtr_probe_interval);
 #ifdef CONFIG_IPV6_ROUTE_INFO
-	array[DEVCONF_ACCEPT_RA_RT_INFO_MAX_PLEN] = cnf->accept_ra_rt_info_max_plen;
+	array[IPV6_DEVCONF_ACCEPT_RA_RT_INFO_MAX_PLEN] = cnf->accept_ra_rt_info_max_plen;
 #endif
 #endif
-	array[DEVCONF_PROXY_NDP] = cnf->proxy_ndp;
-	array[DEVCONF_ACCEPT_SOURCE_ROUTE] = cnf->accept_source_route;
+	array[IPV6_DEVCONF_PROXY_NDP] = cnf->proxy_ndp;
+	array[IPV6_DEVCONF_ACCEPT_SOURCE_ROUTE] = cnf->accept_source_route;
 #ifdef CONFIG_IPV6_OPTIMISTIC_DAD
-	array[DEVCONF_OPTIMISTIC_DAD] = cnf->optimistic_dad;
+	array[IPV6_DEVCONF_OPTIMISTIC_DAD] = cnf->optimistic_dad;
 #endif
 #ifdef CONFIG_IPV6_MROUTE
-	array[DEVCONF_MC_FORWARDING] = cnf->mc_forwarding;
+	array[IPV6_DEVCONF_MC_FORWARDING] = cnf->mc_forwarding;
 #endif
-	array[DEVCONF_DISABLE_IPV6] = cnf->disable_ipv6;
-	array[DEVCONF_ACCEPT_DAD] = cnf->accept_dad;
-	array[DEVCONF_FORCE_TLLAO] = cnf->force_tllao;
-	array[DEVCONF_NDISC_NOTIFY] = cnf->ndisc_notify;
-	array[DEVCONF_SUPPRESS_FRAG_NDISC] = cnf->suppress_frag_ndisc;
+	array[IPV6_DEVCONF_DISABLE_IPV6] = cnf->disable_ipv6;
+	array[IPV6_DEVCONF_ACCEPT_DAD] = cnf->accept_dad;
+	array[IPV6_DEVCONF_FORCE_TLLAO] = cnf->force_tllao;
+	array[IPV6_DEVCONF_NDISC_NOTIFY] = cnf->ndisc_notify;
+	array[IPV6_DEVCONF_SUPPRESS_FRAG_NDISC] = cnf->suppress_frag_ndisc;
 }
 
 static inline size_t inet6_ifla6_size(void)
 {
 	return nla_total_size(4) /* IFLA_INET6_FLAGS */
 	     + nla_total_size(sizeof(struct ifla_cacheinfo))
-	     + nla_total_size(DEVCONF_MAX * 4) /* IFLA_INET6_CONF */
+	     + nla_total_size(IPV6_DEVCONF_MAX * 4) /* IFLA_INET6_CONF */
 	     + nla_total_size(IPSTATS_MIB_MAX * 8) /* IFLA_INET6_STATS */
 	     + nla_total_size(ICMP6_MIB_MAX * 8) /* IFLA_INET6_ICMP6STATS */
 	     + nla_total_size(sizeof(struct in6_addr)); /* IFLA_INET6_TOKEN */
@@ -4400,7 +4400,7 @@ static int inet6_fill_ifla6_attrs(struct sk_buff *skb, struct inet6_dev *idev)
 	ci.retrans_time = jiffies_to_msecs(NEIGH_VAR(idev->nd_parms, RETRANS_TIME));
 	if (nla_put(skb, IFLA_INET6_CACHEINFO, sizeof(ci), &ci))
 		goto nla_put_failure;
-	nla = nla_reserve(skb, IFLA_INET6_CONF, DEVCONF_MAX * sizeof(s32));
+	nla = nla_reserve(skb, IFLA_INET6_CONF, IPV6_DEVCONF_MAX * sizeof(s32));
 	if (nla == NULL)
 		goto nla_put_failure;
 	ipv6_store_devconf(&idev->cnf, nla_data(nla), nla_len(nla));
@@ -4942,7 +4942,7 @@ int addrconf_sysctl_proxy_ndp(struct ctl_table *ctl, int write,
 static struct addrconf_sysctl_table
 {
 	struct ctl_table_header *sysctl_header;
-	struct ctl_table addrconf_vars[DEVCONF_MAX+1];
+	struct ctl_table addrconf_vars[IPV6_DEVCONF_MAX+1];
 } addrconf_sysctl __read_mostly = {
 	.sysctl_header = NULL,
 	.addrconf_vars = {
-- 
1.9.0
