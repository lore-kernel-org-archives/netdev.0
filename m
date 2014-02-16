From: Joe Perches <joe@perches.com>
Subject: [PATCH net-next 3/4] bonding: Convert c99 comments
Date: Sat, 15 Feb 2014 16:02:03 -0800
Message-ID: <204a6287bbd9f26437bfe2ff33e00167c143cb77.1392508410.git.joe@perches.com>
References: <cover.1392508410.git.joe@perches.com>
Cc: Jay Vosburgh <fubar@us.ibm.com>,
	Veaceslav Falico <vfalico@redhat.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1392508410.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Neatening only.

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/bonding/bond_3ad.h | 175 ++++++++++++++++++++---------------------
 1 file changed, 87 insertions(+), 88 deletions(-)

diff --git a/drivers/net/bonding/bond_3ad.h b/drivers/net/bonding/bond_3ad.h
index 13dc9d3..3b97fe48 100644
--- a/drivers/net/bonding/bond_3ad.h
+++ b/drivers/net/bonding/bond_3ad.h
@@ -28,7 +28,7 @@
 #include <linux/netdevice.h>
 #include <linux/if_ether.h>
 
-// General definitions
+/* General definitions */
 #define PKT_TYPE_LACPDU         cpu_to_be16(ETH_P_SLOW)
 #define AD_TIMER_INTERVAL       100 /*msec*/
 
@@ -47,54 +47,54 @@ enum {
 	BOND_AD_COUNT = 2,
 };
 
-// rx machine states(43.4.11 in the 802.3ad standard)
+/* rx machine states(43.4.11 in the 802.3ad standard) */
 typedef enum {
 	AD_RX_DUMMY,
-	AD_RX_INITIALIZE,     // rx Machine
-	AD_RX_PORT_DISABLED,  // rx Machine
-	AD_RX_LACP_DISABLED,  // rx Machine
-	AD_RX_EXPIRED,	      // rx Machine
-	AD_RX_DEFAULTED,      // rx Machine
-	AD_RX_CURRENT	      // rx Machine
+	AD_RX_INITIALIZE,	/* rx Machine */
+	AD_RX_PORT_DISABLED,	/* rx Machine */
+	AD_RX_LACP_DISABLED,	/* rx Machine */
+	AD_RX_EXPIRED,		/* rx Machine */
+	AD_RX_DEFAULTED,	/* rx Machine */
+	AD_RX_CURRENT		/* rx Machine */
 } rx_states_t;
 
-// periodic machine states(43.4.12 in the 802.3ad standard)
+/* periodic machine states(43.4.12 in the 802.3ad standard) */
 typedef enum {
 	AD_PERIODIC_DUMMY,
-	AD_NO_PERIODIC,	       // periodic machine
-	AD_FAST_PERIODIC,      // periodic machine
-	AD_SLOW_PERIODIC,      // periodic machine
-	AD_PERIODIC_TX	   // periodic machine
+	AD_NO_PERIODIC,		/* periodic machine */
+	AD_FAST_PERIODIC,	/* periodic machine */
+	AD_SLOW_PERIODIC,	/* periodic machine */
+	AD_PERIODIC_TX		/* periodic machine */
 } periodic_states_t;
 
-// mux machine states(43.4.13 in the 802.3ad standard)
+/* mux machine states(43.4.13 in the 802.3ad standard) */
 typedef enum {
 	AD_MUX_DUMMY,
-	AD_MUX_DETACHED,       // mux machine
-	AD_MUX_WAITING,	       // mux machine
-	AD_MUX_ATTACHED,       // mux machine
-	AD_MUX_COLLECTING_DISTRIBUTING // mux machine
+	AD_MUX_DETACHED,	/* mux machine */
+	AD_MUX_WAITING,		/* mux machine */
+	AD_MUX_ATTACHED,	/* mux machine */
+	AD_MUX_COLLECTING_DISTRIBUTING	/* mux machine */
 } mux_states_t;
 
-// tx machine states(43.4.15 in the 802.3ad standard)
+/* tx machine states(43.4.15 in the 802.3ad standard) */
 typedef enum {
 	AD_TX_DUMMY,
-	AD_TRANSMIT	   // tx Machine
+	AD_TRANSMIT		/* tx Machine */
 } tx_states_t;
 
-// rx indication types
+/* rx indication types */
 typedef enum {
-	AD_TYPE_LACPDU = 1,    // type lacpdu
-	AD_TYPE_MARKER	   // type marker
+	AD_TYPE_LACPDU = 1,	/* type lacpdu */
+	AD_TYPE_MARKER		/* type marker */
 } pdu_type_t;
 
-// rx marker indication types
+/* rx marker indication types */
 typedef enum {
-	AD_MARKER_INFORMATION_SUBTYPE = 1, // marker imformation subtype
-	AD_MARKER_RESPONSE_SUBTYPE     // marker response subtype
+	AD_MARKER_INFORMATION_SUBTYPE = 1,	/* marker imformation subtype */
+	AD_MARKER_RESPONSE_SUBTYPE		/* marker response subtype */
 } bond_marker_subtype_t;
 
-// timers types(43.4.9 in the 802.3ad standard)
+/* timers types(43.4.9 in the 802.3ad standard) */
 typedef enum {
 	AD_CURRENT_WHILE_TIMER,
 	AD_ACTOR_CHURN_TIMER,
@@ -105,35 +105,35 @@ typedef enum {
 
 #pragma pack(1)
 
-// Link Aggregation Control Protocol(LACP) data unit structure(43.4.2.2 in the 802.3ad standard)
+/* Link Aggregation Control Protocol(LACP) data unit structure(43.4.2.2 in the 802.3ad standard) */
 typedef struct lacpdu {
-	u8 subtype;		     // = LACP(= 0x01)
+	u8 subtype;		/* = LACP(= 0x01) */
 	u8 version_number;
-	u8 tlv_type_actor_info;	      // = actor information(type/length/value)
-	u8 actor_information_length; // = 20
+	u8 tlv_type_actor_info;	/* = actor information(type/length/value) */
+	u8 actor_information_length;	/* = 20 */
 	__be16 actor_system_priority;
 	struct mac_addr actor_system;
 	__be16 actor_key;
 	__be16 actor_port_priority;
 	__be16 actor_port;
 	u8 actor_state;
-	u8 reserved_3_1[3];	     // = 0
-	u8 tlv_type_partner_info;     // = partner information
-	u8 partner_information_length;	 // = 20
+	u8 reserved_3_1[3];		/* = 0 */
+	u8 tlv_type_partner_info;	/* = partner information */
+	u8 partner_information_length;	/* = 20 */
 	__be16 partner_system_priority;
 	struct mac_addr partner_system;
 	__be16 partner_key;
 	__be16 partner_port_priority;
 	__be16 partner_port;
 	u8 partner_state;
-	u8 reserved_3_2[3];	     // = 0
-	u8 tlv_type_collector_info;	  // = collector information
-	u8 collector_information_length; // = 16
+	u8 reserved_3_2[3];		/* = 0 */
+	u8 tlv_type_collector_info;	/* = collector information */
+	u8 collector_information_length;/* = 16 */
 	__be16 collector_max_delay;
 	u8 reserved_12[12];
-	u8 tlv_type_terminator;	     // = terminator
-	u8 terminator_length;	     // = 0
-	u8 reserved_50[50];	     // = 0
+	u8 tlv_type_terminator;		/* = terminator */
+	u8 terminator_length;		/* = 0 */
+	u8 reserved_50[50];		/* = 0 */
 } __packed lacpdu_t;
 
 typedef struct lacpdu_header {
@@ -141,20 +141,20 @@ typedef struct lacpdu_header {
 	struct lacpdu lacpdu;
 } __packed lacpdu_header_t;
 
-// Marker Protocol Data Unit(PDU) structure(43.5.3.2 in the 802.3ad standard)
+/* Marker Protocol Data Unit(PDU) structure(43.5.3.2 in the 802.3ad standard) */
 typedef struct bond_marker {
-	u8 subtype;		 //  = 0x02  (marker PDU)
-	u8 version_number;	 //  = 0x01
-	u8 tlv_type;		 //  = 0x01  (marker information)
-	//  = 0x02  (marker response information)
-	u8 marker_length;	 //  = 0x16
-	u16 requester_port;	 //   The number assigned to the port by the requester
-	struct mac_addr requester_system;      //   The requester's system id
-	u32 requester_transaction_id;	//   The transaction id allocated by the requester,
-	u16 pad;		 //  = 0
-	u8 tlv_type_terminator;	     //  = 0x00
-	u8 terminator_length;	     //  = 0x00
-	u8 reserved_90[90];	     //  = 0
+	u8 subtype;		/* = 0x02  (marker PDU) */
+	u8 version_number;	/* = 0x01 */
+	u8 tlv_type;		/* = 0x01  (marker information) */
+	/* = 0x02  (marker response information) */
+	u8 marker_length;	/* = 0x16 */
+	u16 requester_port;	/* The number assigned to the port by the requester */
+	struct mac_addr requester_system;	/* The requester's system id */
+	u32 requester_transaction_id;		/* The transaction id allocated by the requester, */
+	u16 pad;		/* = 0 */
+	u8 tlv_type_terminator;	/* = 0x00 */
+	u8 terminator_length;	/* = 0x00 */
+	u8 reserved_90[90];	/* = 0 */
 } __packed bond_marker_t;
 
 typedef struct bond_marker_header {
@@ -173,7 +173,7 @@ struct port;
 #pragma pack(8)
 #endif
 
-// aggregator structure(43.4.5 in the 802.3ad standard)
+/* aggregator structure(43.4.5 in the 802.3ad standard) */
 typedef struct aggregator {
 	struct mac_addr aggregator_mac_address;
 	u16 aggregator_identifier;
@@ -183,12 +183,12 @@ typedef struct aggregator {
 	struct mac_addr partner_system;
 	u16 partner_system_priority;
 	u16 partner_oper_aggregator_key;
-	u16 receive_state;		// BOOLEAN
-	u16 transmit_state;		// BOOLEAN
+	u16 receive_state;	/* BOOLEAN */
+	u16 transmit_state;	/* BOOLEAN */
 	struct port *lag_ports;
-	// ****** PRIVATE PARAMETERS ******
-	struct slave *slave;	    // pointer to the bond slave that this aggregator belongs to
-	u16 is_active;	    // BOOLEAN. Indicates if this aggregator is active
+	/* ****** PRIVATE PARAMETERS ****** */
+	struct slave *slave;	/* pointer to the bond slave that this aggregator belongs to */
+	u16 is_active;		/* BOOLEAN. Indicates if this aggregator is active */
 	u16 num_of_ports;
 } aggregator_t;
 
@@ -201,12 +201,12 @@ struct port_params {
 	u16 port_state;
 };
 
-// port structure(43.4.6 in the 802.3ad standard)
+/* port structure(43.4.6 in the 802.3ad standard) */
 typedef struct port {
 	u16 actor_port_number;
 	u16 actor_port_priority;
-	struct mac_addr actor_system;	       // This parameter is added here although it is not specified in the standard, just for simplification
-	u16 actor_system_priority;	 // This parameter is added here although it is not specified in the standard, just for simplification
+	struct mac_addr actor_system;	/* This parameter is added here although it is not specified in the standard, just for simplification */
+	u16 actor_system_priority;	/* This parameter is added here although it is not specified in the standard, just for simplification */
 	u16 actor_port_aggregator_identifier;
 	bool ntt;
 	u16 actor_admin_port_key;
@@ -219,24 +219,24 @@ typedef struct port {
 
 	bool is_enabled;
 
-	// ****** PRIVATE PARAMETERS ******
-	u16 sm_vars;	      // all state machines variables for this port
-	rx_states_t sm_rx_state;	// state machine rx state
-	u16 sm_rx_timer_counter;    // state machine rx timer counter
-	periodic_states_t sm_periodic_state;// state machine periodic state
-	u16 sm_periodic_timer_counter;	// state machine periodic timer counter
-	mux_states_t sm_mux_state;	// state machine mux state
-	u16 sm_mux_timer_counter;   // state machine mux timer counter
-	tx_states_t sm_tx_state;	// state machine tx state
-	u16 sm_tx_timer_counter;    // state machine tx timer counter(allways on - enter to transmit state 3 time per second)
-	struct slave *slave;	    // pointer to the bond slave that this port belongs to
-	struct aggregator *aggregator;	   // pointer to an aggregator that this port related to
-	struct port *next_port_in_aggregator; // Next port on the linked list of the parent aggregator
-	u32 transaction_id;	    // continuous number for identification of Marker PDU's;
-	struct lacpdu lacpdu;	       // the lacpdu that will be sent for this port
+	/* ****** PRIVATE PARAMETERS ****** */
+	u16 sm_vars;		/* all state machines variables for this port */
+	rx_states_t sm_rx_state;	/* state machine rx state */
+	u16 sm_rx_timer_counter;	/* state machine rx timer counter */
+	periodic_states_t sm_periodic_state;	/* state machine periodic state */
+	u16 sm_periodic_timer_counter;	/* state machine periodic timer counter */
+	mux_states_t sm_mux_state;	/* state machine mux state */
+	u16 sm_mux_timer_counter;	/* state machine mux timer counter */
+	tx_states_t sm_tx_state;	/* state machine tx state */
+	u16 sm_tx_timer_counter;	/* state machine tx timer counter(allways on - enter to transmit state 3 time per second) */
+	struct slave *slave;		/* pointer to the bond slave that this port belongs to */
+	struct aggregator *aggregator;	/* pointer to an aggregator that this port related to */
+	struct port *next_port_in_aggregator;	/* Next port on the linked list of the parent aggregator */
+	u32 transaction_id;		/* continuous number for identification of Marker PDU's; */
+	struct lacpdu lacpdu;		/* the lacpdu that will be sent for this port */
 } port_t;
 
-// system structure
+/* system structure */
 struct ad_system {
 	u16 sys_priority;
 	struct mac_addr sys_mac_addr;
@@ -246,26 +246,25 @@ struct ad_system {
 #pragma pack()
 #endif
 
-// ================= AD Exported structures to the main bonding code ==================
+/* ========== AD Exported structures to the main bonding code ========== */
 #define BOND_AD_INFO(bond)   ((bond)->ad_info)
 #define SLAVE_AD_INFO(slave) ((slave)->ad_info)
 
 struct ad_bond_info {
-	struct ad_system system;	    /* 802.3ad system structure */
-	u32 agg_select_timer;	    // Timer to select aggregator after all adapter's hand shakes
+	struct ad_system system;	/* 802.3ad system structure */
+	u32 agg_select_timer;		/* Timer to select aggregator after all adapter's hand shakes */
 };
 
 struct ad_slave_info {
-	struct aggregator aggregator;	    // 802.3ad aggregator structure
-	struct port port;		    // 802.3ad port structure
-	spinlock_t state_machine_lock; /* mutex state machines vs.
-					  incoming LACPDU */
+	struct aggregator aggregator;	/* 802.3ad aggregator structure */
+	struct port port;		/* 802.3ad port structure */
+	spinlock_t state_machine_lock;	/* mutex state machines vs. incoming LACPDU */
 	u16 id;
 };
 
-// ================= AD Exported functions to the main bonding code ==================
+/* ========== AD Exported functions to the main bonding code ========== */
 void bond_3ad_initialize(struct bonding *bond, u16 tick_resolution);
-void  bond_3ad_bind_slave(struct slave *slave);
+void bond_3ad_bind_slave(struct slave *slave);
 void bond_3ad_unbind_slave(struct slave *slave);
 void bond_3ad_state_machine_handler(struct work_struct *);
 void bond_3ad_initiate_agg_selection(struct bonding *bond, int timeout);
@@ -280,5 +279,5 @@ int bond_3ad_lacpdu_recv(const struct sk_buff *skb, struct bonding *bond,
 			 struct slave *slave);
 int bond_3ad_set_carrier(struct bonding *bond);
 void bond_3ad_update_lacp_rate(struct bonding *bond);
-#endif //__BOND_3AD_H__
+#endif /* __BOND_3AD_H__ */
 
-- 
1.8.1.2.459.gbcd45b4.dirty
