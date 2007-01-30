From: Neil Horman <nhorman@tuxdriver.com>
Subject: [PATCH] IPv6: Fix up some CONFIG typos
Date: Tue, 30 Jan 2007 11:04:11 -0500
Message-ID: <20070130160411.GA4026@hmsreliant.homelinux.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, nhorman@tuxdriver.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([70.61.120.52]:2643 "EHLO ra.tuxdriver.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965372AbXA3QEr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 30 Jan 2007 11:04:47 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hey-
	Noticed some typos in some configurable options while going through the
IPv6 code.  Patch attached to clean them up.

Thanks & Regards
Neil 


Signed-off-by: Neil Horman <nhorman@tuxdriver.com>


 addrconf.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)


diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 171e5b5..7b6cfa9 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -3387,7 +3387,7 @@ static void inline ipv6_store_devconf(struct ipv6_devconf *cnf,
 #ifdef CONFIG_IPV6_ROUTER_PREF
 	array[DEVCONF_ACCEPT_RA_RTR_PREF] = cnf->accept_ra_rtr_pref;
 	array[DEVCONF_RTR_PROBE_INTERVAL] = cnf->rtr_probe_interval;
-#ifdef CONFIV_IPV6_ROUTE_INFO
+#ifdef CONFIG_IPV6_ROUTE_INFO
 	array[DEVCONF_ACCEPT_RA_RT_INFO_MAX_PLEN] = cnf->accept_ra_rt_info_max_plen;
 #endif
 #endif
@@ -3892,7 +3892,7 @@ static struct addrconf_sysctl_table
 			.proc_handler	=	&proc_dointvec_jiffies,
 			.strategy	=	&sysctl_jiffies,
 		},
-#ifdef CONFIV_IPV6_ROUTE_INFO
+#ifdef CONFIG_IPV6_ROUTE_INFO
 		{
 			.ctl_name	=	NET_IPV6_ACCEPT_RA_RT_INFO_MAX_PLEN,
 			.procname	=	"accept_ra_rt_info_max_plen",
