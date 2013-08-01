From: Joe Perches <joe@perches.com>
Subject: [PATCH 5/8] ax25.h: Remove extern from function prototypes
Date: Wed, 31 Jul 2013 17:31:36 -0700
Message-ID: <5793f36f9d785ca45ac20663d54bd77c5993203c.1375316912.git.joe@perches.com>
References: <cover.1375316912.git.joe@perches.com>
Cc: Ralf Baechle <ralf@linux-mips.org>,
	"David S. Miller" <davem@davemloft.net>,
	linux-hams@vger.kernel.org, linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1375316912.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

There are a mix of function prototypes with and without extern
in the kernel sources.  Standardize on not using extern for
function prototypes.

Function prototypes don't need to be written with extern.
extern is assumed by the compiler.  Its use is as unnecessary as
using auto to declare automatic/local variables in a block.

Reflow modified prototypes to 80 columns.

Signed-off-by: Joe Perches <joe@perches.com>
---
 include/net/ax25.h | 215 +++++++++++++++++++++++++++--------------------------
 1 file changed, 109 insertions(+), 106 deletions(-)

diff --git a/include/net/ax25.h b/include/net/ax25.h
index 89ed9ac..bf0396e 100644
--- a/include/net/ax25.h
+++ b/include/net/ax25.h
@@ -195,7 +195,7 @@ static inline void ax25_hold_route(ax25_route *ax25_rt)
 	atomic_inc(&ax25_rt->refcount);
 }
 
-extern void __ax25_put_route(ax25_route *ax25_rt);
+void __ax25_put_route(ax25_route *ax25_rt);
 
 static inline void ax25_put_route(ax25_route *ax25_rt)
 {
@@ -272,30 +272,31 @@ static inline __be16 ax25_type_trans(struct sk_buff *skb, struct net_device *dev
 /* af_ax25.c */
 extern struct hlist_head ax25_list;
 extern spinlock_t ax25_list_lock;
-extern void ax25_cb_add(ax25_cb *);
+void ax25_cb_add(ax25_cb *);
 struct sock *ax25_find_listener(ax25_address *, int, struct net_device *, int);
 struct sock *ax25_get_socket(ax25_address *, ax25_address *, int);
-extern ax25_cb *ax25_find_cb(ax25_address *, ax25_address *, ax25_digi *, struct net_device *);
-extern void ax25_send_to_raw(ax25_address *, struct sk_buff *, int);
-extern void ax25_destroy_socket(ax25_cb *);
-extern ax25_cb * __must_check ax25_create_cb(void);
-extern void ax25_fillin_cb(ax25_cb *, ax25_dev *);
-extern struct sock *ax25_make_new(struct sock *, struct ax25_dev *);
+ax25_cb *ax25_find_cb(ax25_address *, ax25_address *, ax25_digi *,
+		      struct net_device *);
+void ax25_send_to_raw(ax25_address *, struct sk_buff *, int);
+void ax25_destroy_socket(ax25_cb *);
+ax25_cb * __must_check ax25_create_cb(void);
+void ax25_fillin_cb(ax25_cb *, ax25_dev *);
+struct sock *ax25_make_new(struct sock *, struct ax25_dev *);
 
 /* ax25_addr.c */
 extern const ax25_address ax25_bcast;
 extern const ax25_address ax25_defaddr;
 extern const ax25_address null_ax25_address;
-extern char *ax2asc(char *buf, const ax25_address *);
-extern void asc2ax(ax25_address *addr, const char *callsign);
-extern int ax25cmp(const ax25_address *, const ax25_address *);
-extern int ax25digicmp(const ax25_digi *, const ax25_digi *);
-extern const unsigned char *ax25_addr_parse(const unsigned char *, int,
+char *ax2asc(char *buf, const ax25_address *);
+void asc2ax(ax25_address *addr, const char *callsign);
+int ax25cmp(const ax25_address *, const ax25_address *);
+int ax25digicmp(const ax25_digi *, const ax25_digi *);
+const unsigned char *ax25_addr_parse(const unsigned char *, int,
 	ax25_address *, ax25_address *, ax25_digi *, int *, int *);
-extern int  ax25_addr_build(unsigned char *, const ax25_address *,
-	const ax25_address *, const ax25_digi *, int, int);
-extern int  ax25_addr_size(const ax25_digi *);
-extern void ax25_digi_invert(const ax25_digi *, ax25_digi *);
+int ax25_addr_build(unsigned char *, const ax25_address *,
+		    const ax25_address *, const ax25_digi *, int, int);
+int ax25_addr_size(const ax25_digi *);
+void ax25_digi_invert(const ax25_digi *, ax25_digi *);
 
 /* ax25_dev.c */
 extern ax25_dev *ax25_dev_list;
@@ -306,33 +307,33 @@ static inline ax25_dev *ax25_dev_ax25dev(struct net_device *dev)
 	return dev->ax25_ptr;
 }
 
-extern ax25_dev *ax25_addr_ax25dev(ax25_address *);
-extern void ax25_dev_device_up(struct net_device *);
-extern void ax25_dev_device_down(struct net_device *);
-extern int  ax25_fwd_ioctl(unsigned int, struct ax25_fwd_struct *);
-extern struct net_device *ax25_fwd_dev(struct net_device *);
-extern void ax25_dev_free(void);
+ax25_dev *ax25_addr_ax25dev(ax25_address *);
+void ax25_dev_device_up(struct net_device *);
+void ax25_dev_device_down(struct net_device *);
+int ax25_fwd_ioctl(unsigned int, struct ax25_fwd_struct *);
+struct net_device *ax25_fwd_dev(struct net_device *);
+void ax25_dev_free(void);
 
 /* ax25_ds_in.c */
-extern int  ax25_ds_frame_in(ax25_cb *, struct sk_buff *, int);
+int ax25_ds_frame_in(ax25_cb *, struct sk_buff *, int);
 
 /* ax25_ds_subr.c */
-extern void ax25_ds_nr_error_recovery(ax25_cb *);
-extern void ax25_ds_enquiry_response(ax25_cb *);
-extern void ax25_ds_establish_data_link(ax25_cb *);
-extern void ax25_dev_dama_off(ax25_dev *);
-extern void ax25_dama_on(ax25_cb *);
-extern void ax25_dama_off(ax25_cb *);
+void ax25_ds_nr_error_recovery(ax25_cb *);
+void ax25_ds_enquiry_response(ax25_cb *);
+void ax25_ds_establish_data_link(ax25_cb *);
+void ax25_dev_dama_off(ax25_dev *);
+void ax25_dama_on(ax25_cb *);
+void ax25_dama_off(ax25_cb *);
 
 /* ax25_ds_timer.c */
-extern void ax25_ds_setup_timer(ax25_dev *);
-extern void ax25_ds_set_timer(ax25_dev *);
-extern void ax25_ds_del_timer(ax25_dev *);
-extern void ax25_ds_timer(ax25_cb *);
-extern void ax25_ds_t1_timeout(ax25_cb *);
-extern void ax25_ds_heartbeat_expiry(ax25_cb *);
-extern void ax25_ds_t3timer_expiry(ax25_cb *);
-extern void ax25_ds_idletimer_expiry(ax25_cb *);
+void ax25_ds_setup_timer(ax25_dev *);
+void ax25_ds_set_timer(ax25_dev *);
+void ax25_ds_del_timer(ax25_dev *);
+void ax25_ds_timer(ax25_cb *);
+void ax25_ds_t1_timeout(ax25_cb *);
+void ax25_ds_heartbeat_expiry(ax25_cb *);
+void ax25_ds_t3timer_expiry(ax25_cb *);
+void ax25_ds_idletimer_expiry(ax25_cb *);
 
 /* ax25_iface.c */
 
@@ -342,107 +343,109 @@ struct ax25_protocol {
 	int (*func)(struct sk_buff *, ax25_cb *);
 };
 
-extern void ax25_register_pid(struct ax25_protocol *ap);
-extern void ax25_protocol_release(unsigned int);
+void ax25_register_pid(struct ax25_protocol *ap);
+void ax25_protocol_release(unsigned int);
 
 struct ax25_linkfail {
 	struct hlist_node lf_node;
 	void (*func)(ax25_cb *, int);
 };
 
-extern void ax25_linkfail_register(struct ax25_linkfail *lf);
-extern void ax25_linkfail_release(struct ax25_linkfail *lf);
-extern int __must_check ax25_listen_register(ax25_address *,
-	struct net_device *);
-extern void ax25_listen_release(ax25_address *, struct net_device *);
-extern int  (*ax25_protocol_function(unsigned int))(struct sk_buff *, ax25_cb *);
-extern int  ax25_listen_mine(ax25_address *, struct net_device *);
-extern void ax25_link_failed(ax25_cb *, int);
-extern int  ax25_protocol_is_registered(unsigned int);
+void ax25_linkfail_register(struct ax25_linkfail *lf);
+void ax25_linkfail_release(struct ax25_linkfail *lf);
+int __must_check ax25_listen_register(ax25_address *, struct net_device *);
+void ax25_listen_release(ax25_address *, struct net_device *);
+int(*ax25_protocol_function(unsigned int))(struct sk_buff *, ax25_cb *);
+int ax25_listen_mine(ax25_address *, struct net_device *);
+void ax25_link_failed(ax25_cb *, int);
+int ax25_protocol_is_registered(unsigned int);
 
 /* ax25_in.c */
-extern int  ax25_rx_iframe(ax25_cb *, struct sk_buff *);
-extern int  ax25_kiss_rcv(struct sk_buff *, struct net_device *, struct packet_type *, struct net_device *);
+int ax25_rx_iframe(ax25_cb *, struct sk_buff *);
+int ax25_kiss_rcv(struct sk_buff *, struct net_device *, struct packet_type *,
+		  struct net_device *);
 
 /* ax25_ip.c */
-extern int ax25_hard_header(struct sk_buff *, struct net_device *,
-			    unsigned short, const void *,
-			    const void *, unsigned int);
-extern int  ax25_rebuild_header(struct sk_buff *);
+int ax25_hard_header(struct sk_buff *, struct net_device *, unsigned short,
+		     const void *, const void *, unsigned int);
+int ax25_rebuild_header(struct sk_buff *);
 extern const struct header_ops ax25_header_ops;
 
 /* ax25_out.c */
-extern ax25_cb *ax25_send_frame(struct sk_buff *, int, ax25_address *, ax25_address *, ax25_digi *, struct net_device *);
-extern void ax25_output(ax25_cb *, int, struct sk_buff *);
-extern void ax25_kick(ax25_cb *);
-extern void ax25_transmit_buffer(ax25_cb *, struct sk_buff *, int);
-extern void ax25_queue_xmit(struct sk_buff *skb, struct net_device *dev);
-extern int  ax25_check_iframes_acked(ax25_cb *, unsigned short);
+ax25_cb *ax25_send_frame(struct sk_buff *, int, ax25_address *, ax25_address *,
+			 ax25_digi *, struct net_device *);
+void ax25_output(ax25_cb *, int, struct sk_buff *);
+void ax25_kick(ax25_cb *);
+void ax25_transmit_buffer(ax25_cb *, struct sk_buff *, int);
+void ax25_queue_xmit(struct sk_buff *skb, struct net_device *dev);
+int ax25_check_iframes_acked(ax25_cb *, unsigned short);
 
 /* ax25_route.c */
-extern void ax25_rt_device_down(struct net_device *);
-extern int  ax25_rt_ioctl(unsigned int, void __user *);
+void ax25_rt_device_down(struct net_device *);
+int ax25_rt_ioctl(unsigned int, void __user *);
 extern const struct file_operations ax25_route_fops;
-extern ax25_route *ax25_get_route(ax25_address *addr, struct net_device *dev);
-extern int  ax25_rt_autobind(ax25_cb *, ax25_address *);
-extern struct sk_buff *ax25_rt_build_path(struct sk_buff *, ax25_address *, ax25_address *, ax25_digi *);
-extern void ax25_rt_free(void);
+ax25_route *ax25_get_route(ax25_address *addr, struct net_device *dev);
+int ax25_rt_autobind(ax25_cb *, ax25_address *);
+struct sk_buff *ax25_rt_build_path(struct sk_buff *, ax25_address *,
+				   ax25_address *, ax25_digi *);
+void ax25_rt_free(void);
 
 /* ax25_std_in.c */
-extern int  ax25_std_frame_in(ax25_cb *, struct sk_buff *, int);
+int ax25_std_frame_in(ax25_cb *, struct sk_buff *, int);
 
 /* ax25_std_subr.c */
-extern void ax25_std_nr_error_recovery(ax25_cb *);
-extern void ax25_std_establish_data_link(ax25_cb *);
-extern void ax25_std_transmit_enquiry(ax25_cb *);
-extern void ax25_std_enquiry_response(ax25_cb *);
-extern void ax25_std_timeout_response(ax25_cb *);
+void ax25_std_nr_error_recovery(ax25_cb *);
+void ax25_std_establish_data_link(ax25_cb *);
+void ax25_std_transmit_enquiry(ax25_cb *);
+void ax25_std_enquiry_response(ax25_cb *);
+void ax25_std_timeout_response(ax25_cb *);
 
 /* ax25_std_timer.c */
-extern void ax25_std_heartbeat_expiry(ax25_cb *);
-extern void ax25_std_t1timer_expiry(ax25_cb *);
-extern void ax25_std_t2timer_expiry(ax25_cb *);
-extern void ax25_std_t3timer_expiry(ax25_cb *);
-extern void ax25_std_idletimer_expiry(ax25_cb *);
+void ax25_std_heartbeat_expiry(ax25_cb *);
+void ax25_std_t1timer_expiry(ax25_cb *);
+void ax25_std_t2timer_expiry(ax25_cb *);
+void ax25_std_t3timer_expiry(ax25_cb *);
+void ax25_std_idletimer_expiry(ax25_cb *);
 
 /* ax25_subr.c */
-extern void ax25_clear_queues(ax25_cb *);
-extern void ax25_frames_acked(ax25_cb *, unsigned short);
-extern void ax25_requeue_frames(ax25_cb *);
-extern int  ax25_validate_nr(ax25_cb *, unsigned short);
-extern int  ax25_decode(ax25_cb *, struct sk_buff *, int *, int *, int *);
-extern void ax25_send_control(ax25_cb *, int, int, int);
-extern void ax25_return_dm(struct net_device *, ax25_address *, ax25_address *, ax25_digi *);
-extern void ax25_calculate_t1(ax25_cb *);
-extern void ax25_calculate_rtt(ax25_cb *);
-extern void ax25_disconnect(ax25_cb *, int);
+void ax25_clear_queues(ax25_cb *);
+void ax25_frames_acked(ax25_cb *, unsigned short);
+void ax25_requeue_frames(ax25_cb *);
+int ax25_validate_nr(ax25_cb *, unsigned short);
+int ax25_decode(ax25_cb *, struct sk_buff *, int *, int *, int *);
+void ax25_send_control(ax25_cb *, int, int, int);
+void ax25_return_dm(struct net_device *, ax25_address *, ax25_address *,
+		    ax25_digi *);
+void ax25_calculate_t1(ax25_cb *);
+void ax25_calculate_rtt(ax25_cb *);
+void ax25_disconnect(ax25_cb *, int);
 
 /* ax25_timer.c */
-extern void ax25_setup_timers(ax25_cb *);
-extern void ax25_start_heartbeat(ax25_cb *);
-extern void ax25_start_t1timer(ax25_cb *);
-extern void ax25_start_t2timer(ax25_cb *);
-extern void ax25_start_t3timer(ax25_cb *);
-extern void ax25_start_idletimer(ax25_cb *);
-extern void ax25_stop_heartbeat(ax25_cb *);
-extern void ax25_stop_t1timer(ax25_cb *);
-extern void ax25_stop_t2timer(ax25_cb *);
-extern void ax25_stop_t3timer(ax25_cb *);
-extern void ax25_stop_idletimer(ax25_cb *);
-extern int  ax25_t1timer_running(ax25_cb *);
-extern unsigned long ax25_display_timer(struct timer_list *);
+void ax25_setup_timers(ax25_cb *);
+void ax25_start_heartbeat(ax25_cb *);
+void ax25_start_t1timer(ax25_cb *);
+void ax25_start_t2timer(ax25_cb *);
+void ax25_start_t3timer(ax25_cb *);
+void ax25_start_idletimer(ax25_cb *);
+void ax25_stop_heartbeat(ax25_cb *);
+void ax25_stop_t1timer(ax25_cb *);
+void ax25_stop_t2timer(ax25_cb *);
+void ax25_stop_t3timer(ax25_cb *);
+void ax25_stop_idletimer(ax25_cb *);
+int ax25_t1timer_running(ax25_cb *);
+unsigned long ax25_display_timer(struct timer_list *);
 
 /* ax25_uid.c */
 extern int  ax25_uid_policy;
-extern ax25_uid_assoc *ax25_findbyuid(kuid_t);
-extern int __must_check ax25_uid_ioctl(int, struct sockaddr_ax25 *);
+ax25_uid_assoc *ax25_findbyuid(kuid_t);
+int __must_check ax25_uid_ioctl(int, struct sockaddr_ax25 *);
 extern const struct file_operations ax25_uid_fops;
-extern void ax25_uid_free(void);
+void ax25_uid_free(void);
 
 /* sysctl_net_ax25.c */
 #ifdef CONFIG_SYSCTL
-extern int ax25_register_dev_sysctl(ax25_dev *ax25_dev);
-extern void ax25_unregister_dev_sysctl(ax25_dev *ax25_dev);
+int ax25_register_dev_sysctl(ax25_dev *ax25_dev);
+void ax25_unregister_dev_sysctl(ax25_dev *ax25_dev);
 #else
 static inline int ax25_register_dev_sysctl(ax25_dev *ax25_dev) { return 0; }
 static inline void ax25_unregister_dev_sysctl(ax25_dev *ax25_dev) {}
-- 
1.8.1.2.459.gbcd45b4.dirty
