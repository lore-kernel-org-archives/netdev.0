From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH] ip_common.h header cleanup
Date: Fri,  6 Nov 2015 18:54:08 +0100
Message-ID: <1446832448-26793-1-git-send-email-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemming@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbit.nwl.cc ([176.31.251.142]:35964 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932977AbbKFRyK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 Nov 2015 12:54:10 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

- Drop 'extern' keyword from all function prototypes.
- Make line breaking of print_* functions consistent.
- Make print_ntable() and ipntable_reset_filter() static and remove
  their declaration.
- Drop declaration of non-existent ipaddr_list() and iproute_monitor().

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 ip/ip_common.h | 116 +++++++++++++++++++++++++++------------------------------
 ip/ipntable.c  |   4 +-
 2 files changed, 56 insertions(+), 64 deletions(-)

diff --git a/ip/ip_common.h b/ip/ip_common.h
index f74face..9a846df 100644
--- a/ip/ip_common.h
+++ b/ip/ip_common.h
@@ -1,68 +1,60 @@
-extern int get_operstate(const char *name);
-extern int print_linkinfo(const struct sockaddr_nl *who,
-			  struct nlmsghdr *n,
-			  void *arg);
-extern int print_linkinfo_brief(const struct sockaddr_nl *who,
-				struct nlmsghdr *n,
-				void *arg);
-extern int print_addrinfo(const struct sockaddr_nl *who,
-			  struct nlmsghdr *n,
-			  void *arg);
-extern int print_addrlabel(const struct sockaddr_nl *who,
-			   struct nlmsghdr *n, void *arg);
-extern int print_neigh(const struct sockaddr_nl *who,
-		       struct nlmsghdr *n, void *arg);
-extern int print_ntable(const struct sockaddr_nl *who,
-			struct nlmsghdr *n, void *arg);
-extern int ipaddr_list(int argc, char **argv);
-extern int ipaddr_list_link(int argc, char **argv);
+int get_operstate(const char *name);
+int print_linkinfo(const struct sockaddr_nl *who,
+		   struct nlmsghdr *n, void *arg);
+int print_linkinfo_brief(const struct sockaddr_nl *who,
+			 struct nlmsghdr *n, void *arg);
+int print_addrinfo(const struct sockaddr_nl *who,
+		   struct nlmsghdr *n, void *arg);
+int print_addrlabel(const struct sockaddr_nl *who,
+		    struct nlmsghdr *n, void *arg);
+int print_neigh(const struct sockaddr_nl *who,
+	        struct nlmsghdr *n, void *arg);
+int ipaddr_list_link(int argc, char **argv);
 void ipaddr_get_vf_rate(int, int *, int *, int);
-extern int iproute_monitor(int argc, char **argv);
-extern void iplink_usage(void) __attribute__((noreturn));
+void iplink_usage(void) __attribute__((noreturn));
 
-extern void iproute_reset_filter(int ifindex);
-extern void ipmroute_reset_filter(int ifindex);
-extern void ipaddr_reset_filter(int oneline, int ifindex);
-extern void ipneigh_reset_filter(int ifindex);
-extern void ipntable_reset_filter(void);
-extern void ipnetconf_reset_filter(int ifindex);
+void iproute_reset_filter(int ifindex);
+void ipmroute_reset_filter(int ifindex);
+void ipaddr_reset_filter(int oneline, int ifindex);
+void ipneigh_reset_filter(int ifindex);
+void ipnetconf_reset_filter(int ifindex);
 
-extern int print_route(const struct sockaddr_nl *who,
-		       struct nlmsghdr *n, void *arg);
-extern int print_mroute(const struct sockaddr_nl *who,
-			struct nlmsghdr *n, void *arg);
-extern int print_prefix(const struct sockaddr_nl *who,
-			struct nlmsghdr *n, void *arg);
-extern int print_rule(const struct sockaddr_nl *who,
-		      struct nlmsghdr *n, void *arg);
-extern int print_netconf(const struct sockaddr_nl *who,
-			 struct rtnl_ctrl_data *ctrl,
-			 struct nlmsghdr *n, void *arg);
-extern void netns_map_init(void);
-extern int print_nsid(const struct sockaddr_nl *who,
-		      struct nlmsghdr *n, void *arg);
-extern int do_ipaddr(int argc, char **argv);
-extern int do_ipaddrlabel(int argc, char **argv);
-extern int do_iproute(int argc, char **argv);
-extern int do_iprule(int argc, char **argv);
-extern int do_ipneigh(int argc, char **argv);
-extern int do_ipntable(int argc, char **argv);
-extern int do_iptunnel(int argc, char **argv);
-extern int do_ip6tunnel(int argc, char **argv);
-extern int do_iptuntap(int argc, char **argv);
-extern int do_iplink(int argc, char **argv);
-extern int do_ipmonitor(int argc, char **argv);
-extern int do_multiaddr(int argc, char **argv);
-extern int do_multiroute(int argc, char **argv);
-extern int do_multirule(int argc, char **argv);
-extern int do_netns(int argc, char **argv);
-extern int do_xfrm(int argc, char **argv);
-extern int do_ipl2tp(int argc, char **argv);
-extern int do_ipfou(int argc, char **argv);
-extern int do_tcp_metrics(int argc, char **argv);
-extern int do_ipnetconf(int argc, char **argv);
-extern int do_iptoken(int argc, char **argv);
-extern int iplink_get(unsigned int flags, char *name, __u32 filt_mask);
+int print_route(const struct sockaddr_nl *who,
+		struct nlmsghdr *n, void *arg);
+int print_mroute(const struct sockaddr_nl *who,
+		 struct nlmsghdr *n, void *arg);
+int print_prefix(const struct sockaddr_nl *who,
+		 struct nlmsghdr *n, void *arg);
+int print_rule(const struct sockaddr_nl *who,
+	       struct nlmsghdr *n, void *arg);
+int print_netconf(const struct sockaddr_nl *who,
+		  struct rtnl_ctrl_data *ctrl,
+		  struct nlmsghdr *n, void *arg);
+void netns_map_init(void);
+int print_nsid(const struct sockaddr_nl *who,
+	       struct nlmsghdr *n, void *arg);
+int do_ipaddr(int argc, char **argv);
+int do_ipaddrlabel(int argc, char **argv);
+int do_iproute(int argc, char **argv);
+int do_iprule(int argc, char **argv);
+int do_ipneigh(int argc, char **argv);
+int do_ipntable(int argc, char **argv);
+int do_iptunnel(int argc, char **argv);
+int do_ip6tunnel(int argc, char **argv);
+int do_iptuntap(int argc, char **argv);
+int do_iplink(int argc, char **argv);
+int do_ipmonitor(int argc, char **argv);
+int do_multiaddr(int argc, char **argv);
+int do_multiroute(int argc, char **argv);
+int do_multirule(int argc, char **argv);
+int do_netns(int argc, char **argv);
+int do_xfrm(int argc, char **argv);
+int do_ipl2tp(int argc, char **argv);
+int do_ipfou(int argc, char **argv);
+int do_tcp_metrics(int argc, char **argv);
+int do_ipnetconf(int argc, char **argv);
+int do_iptoken(int argc, char **argv);
+int iplink_get(unsigned int flags, char *name, __u32 filt_mask);
 
 static inline int rtm_get_table(struct rtmsg *r, struct rtattr **tb)
 {
diff --git a/ip/ipntable.c b/ip/ipntable.c
index 5e84b95..6eb84e7 100644
--- a/ip/ipntable.c
+++ b/ip/ipntable.c
@@ -349,7 +349,7 @@ static const char *ntable_strtime_delta(__u32 msec)
 	return str;
 }
 
-int print_ntable(const struct sockaddr_nl *who, struct nlmsghdr *n, void *arg)
+static int print_ntable(const struct sockaddr_nl *who, struct nlmsghdr *n, void *arg)
 {
 	FILE *fp = (FILE*)arg;
 	struct ndtmsg *ndtm = NLMSG_DATA(n);
@@ -601,7 +601,7 @@ int print_ntable(const struct sockaddr_nl *who, struct nlmsghdr *n, void *arg)
 	return 0;
 }
 
-void ipntable_reset_filter(void)
+static void ipntable_reset_filter(void)
 {
 	memset(&filter, 0, sizeof(filter));
 }
-- 
2.1.2
