From: Joe Perches <joe@perches.com>
Subject: [PATCH 06/12] x25.h: Remove extern from function prototypes
Date: Mon, 23 Sep 2013 11:33:49 -0700
Message-ID: <b0c1e7b3237e2723d2a2accd6f5aa63d683c1cb5.1379961014.git.joe@perches.com>
References: <445209f8885ccd8234fa787c30d63e63fc7917d7.1379961014.git.joe@perches.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0137.hostedemail.com ([216.40.44.137]:43134 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753698Ab3IWSdx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Sep 2013 14:33:53 -0400
In-Reply-To: <445209f8885ccd8234fa787c30d63e63fc7917d7.1379961014.git.joe@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There are a mix of function prototypes with and without extern
in the kernel sources.  Standardize on not using extern for
function prototypes.

Function prototypes don't need to be written with extern.
extern is assumed by the compiler.  Its use is as unnecessary as
using auto to declare automatic/local variables in a block.

Signed-off-by: Joe Perches <joe@perches.com>
---
 include/net/x25.h | 141 +++++++++++++++++++++++++++---------------------------
 1 file changed, 71 insertions(+), 70 deletions(-)

diff --git a/include/net/x25.h b/include/net/x25.h
index b4a8a89..c383aa4 100644
--- a/include/net/x25.h
+++ b/include/net/x25.h
@@ -187,57 +187,57 @@ extern int  sysctl_x25_clear_request_timeout;
 extern int  sysctl_x25_ack_holdback_timeout;
 extern int  sysctl_x25_forward;
 
-extern int x25_parse_address_block(struct sk_buff *skb,
-		struct x25_address *called_addr,
-		struct x25_address *calling_addr);
-
-extern int  x25_addr_ntoa(unsigned char *, struct x25_address *,
-			  struct x25_address *);
-extern int  x25_addr_aton(unsigned char *, struct x25_address *,
-			  struct x25_address *);
-extern struct sock *x25_find_socket(unsigned int, struct x25_neigh *);
-extern void x25_destroy_socket_from_timer(struct sock *);
-extern int  x25_rx_call_request(struct sk_buff *, struct x25_neigh *, unsigned int);
-extern void x25_kill_by_neigh(struct x25_neigh *);
+int x25_parse_address_block(struct sk_buff *skb,
+			    struct x25_address *called_addr,
+			    struct x25_address *calling_addr);
+
+int x25_addr_ntoa(unsigned char *, struct x25_address *, struct x25_address *);
+int x25_addr_aton(unsigned char *, struct x25_address *, struct x25_address *);
+struct sock *x25_find_socket(unsigned int, struct x25_neigh *);
+void x25_destroy_socket_from_timer(struct sock *);
+int x25_rx_call_request(struct sk_buff *, struct x25_neigh *, unsigned int);
+void x25_kill_by_neigh(struct x25_neigh *);
 
 /* x25_dev.c */
-extern void x25_send_frame(struct sk_buff *, struct x25_neigh *);
-extern int  x25_lapb_receive_frame(struct sk_buff *, struct net_device *, struct packet_type *, struct net_device *);
-extern void x25_establish_link(struct x25_neigh *);
-extern void x25_terminate_link(struct x25_neigh *);
+void x25_send_frame(struct sk_buff *, struct x25_neigh *);
+int x25_lapb_receive_frame(struct sk_buff *, struct net_device *,
+			   struct packet_type *, struct net_device *);
+void x25_establish_link(struct x25_neigh *);
+void x25_terminate_link(struct x25_neigh *);
 
 /* x25_facilities.c */
-extern int x25_parse_facilities(struct sk_buff *, struct x25_facilities *,
-				struct x25_dte_facilities *, unsigned long *);
-extern int x25_create_facilities(unsigned char *, struct x25_facilities *,
-				struct x25_dte_facilities *, unsigned long);
-extern int x25_negotiate_facilities(struct sk_buff *, struct sock *,
-				struct x25_facilities *,
-				struct x25_dte_facilities *);
-extern void x25_limit_facilities(struct x25_facilities *, struct x25_neigh *);
+int x25_parse_facilities(struct sk_buff *, struct x25_facilities *,
+			 struct x25_dte_facilities *, unsigned long *);
+int x25_create_facilities(unsigned char *, struct x25_facilities *,
+			  struct x25_dte_facilities *, unsigned long);
+int x25_negotiate_facilities(struct sk_buff *, struct sock *,
+			     struct x25_facilities *,
+			     struct x25_dte_facilities *);
+void x25_limit_facilities(struct x25_facilities *, struct x25_neigh *);
 
 /* x25_forward.c */
-extern void x25_clear_forward_by_lci(unsigned int lci);
-extern void x25_clear_forward_by_dev(struct net_device *);
-extern int x25_forward_data(int, struct x25_neigh *, struct sk_buff *);
-extern int x25_forward_call(struct x25_address *, struct x25_neigh *,
-				struct sk_buff *, int);
+void x25_clear_forward_by_lci(unsigned int lci);
+void x25_clear_forward_by_dev(struct net_device *);
+int x25_forward_data(int, struct x25_neigh *, struct sk_buff *);
+int x25_forward_call(struct x25_address *, struct x25_neigh *, struct sk_buff *,
+		     int);
 
 /* x25_in.c */
-extern int  x25_process_rx_frame(struct sock *, struct sk_buff *);
-extern int  x25_backlog_rcv(struct sock *, struct sk_buff *);
+int x25_process_rx_frame(struct sock *, struct sk_buff *);
+int x25_backlog_rcv(struct sock *, struct sk_buff *);
 
 /* x25_link.c */
-extern void x25_link_control(struct sk_buff *, struct x25_neigh *, unsigned short);
-extern void x25_link_device_up(struct net_device *);
-extern void x25_link_device_down(struct net_device *);
-extern void x25_link_established(struct x25_neigh *);
-extern void x25_link_terminated(struct x25_neigh *);
-extern void x25_transmit_clear_request(struct x25_neigh *, unsigned int, unsigned char);
-extern void x25_transmit_link(struct sk_buff *, struct x25_neigh *);
-extern int  x25_subscr_ioctl(unsigned int, void __user *);
-extern struct x25_neigh *x25_get_neigh(struct net_device *);
-extern void x25_link_free(void);
+void x25_link_control(struct sk_buff *, struct x25_neigh *, unsigned short);
+void x25_link_device_up(struct net_device *);
+void x25_link_device_down(struct net_device *);
+void x25_link_established(struct x25_neigh *);
+void x25_link_terminated(struct x25_neigh *);
+void x25_transmit_clear_request(struct x25_neigh *, unsigned int,
+				unsigned char);
+void x25_transmit_link(struct sk_buff *, struct x25_neigh *);
+int x25_subscr_ioctl(unsigned int, void __user *);
+struct x25_neigh *x25_get_neigh(struct net_device *);
+void x25_link_free(void);
 
 /* x25_neigh.c */
 static __inline__ void x25_neigh_hold(struct x25_neigh *nb)
@@ -252,16 +252,16 @@ static __inline__ void x25_neigh_put(struct x25_neigh *nb)
 }
 
 /* x25_out.c */
-extern  int x25_output(struct sock *, struct sk_buff *);
-extern void x25_kick(struct sock *);
-extern void x25_enquiry_response(struct sock *);
+int x25_output(struct sock *, struct sk_buff *);
+void x25_kick(struct sock *);
+void x25_enquiry_response(struct sock *);
 
 /* x25_route.c */
-extern struct x25_route *x25_get_route(struct x25_address *addr);
-extern struct net_device *x25_dev_get(char *);
-extern void x25_route_device_down(struct net_device *dev);
-extern int  x25_route_ioctl(unsigned int, void __user *);
-extern void x25_route_free(void);
+struct x25_route *x25_get_route(struct x25_address *addr);
+struct net_device *x25_dev_get(char *);
+void x25_route_device_down(struct net_device *dev);
+int x25_route_ioctl(unsigned int, void __user *);
+void x25_route_free(void);
 
 static __inline__ void x25_route_hold(struct x25_route *rt)
 {
@@ -275,30 +275,31 @@ static __inline__ void x25_route_put(struct x25_route *rt)
 }
 
 /* x25_subr.c */
-extern void x25_clear_queues(struct sock *);
-extern void x25_frames_acked(struct sock *, unsigned short);
-extern void x25_requeue_frames(struct sock *);
-extern int  x25_validate_nr(struct sock *, unsigned short);
-extern void x25_write_internal(struct sock *, int);
-extern int  x25_decode(struct sock *, struct sk_buff *, int *, int *, int *, int *, int *);
-extern void x25_disconnect(struct sock *, int, unsigned char, unsigned char);
+void x25_clear_queues(struct sock *);
+void x25_frames_acked(struct sock *, unsigned short);
+void x25_requeue_frames(struct sock *);
+int x25_validate_nr(struct sock *, unsigned short);
+void x25_write_internal(struct sock *, int);
+int x25_decode(struct sock *, struct sk_buff *, int *, int *, int *, int *,
+	       int *);
+void x25_disconnect(struct sock *, int, unsigned char, unsigned char);
 
 /* x25_timer.c */
-extern void x25_init_timers(struct sock *sk);
-extern void x25_start_heartbeat(struct sock *);
-extern void x25_start_t2timer(struct sock *);
-extern void x25_start_t21timer(struct sock *);
-extern void x25_start_t22timer(struct sock *);
-extern void x25_start_t23timer(struct sock *);
-extern void x25_stop_heartbeat(struct sock *);
-extern void x25_stop_timer(struct sock *);
-extern unsigned long x25_display_timer(struct sock *);
-extern void x25_check_rbuf(struct sock *);
+void x25_init_timers(struct sock *sk);
+void x25_start_heartbeat(struct sock *);
+void x25_start_t2timer(struct sock *);
+void x25_start_t21timer(struct sock *);
+void x25_start_t22timer(struct sock *);
+void x25_start_t23timer(struct sock *);
+void x25_stop_heartbeat(struct sock *);
+void x25_stop_timer(struct sock *);
+unsigned long x25_display_timer(struct sock *);
+void x25_check_rbuf(struct sock *);
 
 /* sysctl_net_x25.c */
 #ifdef CONFIG_SYSCTL
-extern void x25_register_sysctl(void);
-extern void x25_unregister_sysctl(void);
+void x25_register_sysctl(void);
+void x25_unregister_sysctl(void);
 #else
 static inline void x25_register_sysctl(void) {};
 static inline void x25_unregister_sysctl(void) {};
@@ -318,6 +319,6 @@ extern rwlock_t x25_forward_list_lock;
 extern struct list_head x25_neigh_list;
 extern rwlock_t x25_neigh_list_lock;
 
-extern int x25_proc_init(void);
-extern void x25_proc_exit(void);
+int x25_proc_init(void);
+void x25_proc_exit(void);
 #endif
-- 
1.8.1.2.459.gbcd45b4.dirty
