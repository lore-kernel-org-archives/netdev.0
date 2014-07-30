From: Nikolay Aleksandrov <nikolay@redhat.com>
Subject: RE: [PATCH v3] net: kernel-doc compliant documentation for net_device
Date: Wed, 30 Jul 2014 14:57:02 +0200
Message-ID: <53D8EB9E.3090003@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: rdunlap@infradead.org, netdev <netdev@vger.kernel.org>,
	linux-doc@vger.kernel.org, Nikolay Aleksandrov <nikolay@redhat.com>
To: Karoly Kemeny <karoly.kemeny@gmail.com>
Return-path: <linux-doc-owner@vger.kernel.org>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 07/30/2014 01:55 PM, Karoly Kemeny wrote:
<<snip>>
> +/**
> + *	struct net_device - The DEVICE structure.
> + *		Actually, this whole structure is a big mistake.  It mixes I/O
> + *		data with strictly "high-level" data, and it has to know about
> + *		almost every data structure used in the INET module.
> + *
> + *	@name:	This is the first field of the "visible" part of this stru=
cture
> + *		(i.e. as seen by users in the "Space.c" file).  It is the name
> + *	 	of the interface.
> + *
> + *	@name_hlist: 	Device name hash chain, please keep it close to nam=
e[]
> + *	@ifalias:	SNMP alias
> + *	@mem_end:	Shared memory end
> + *	@mem_start:	Shared memory start
> + *	@base_addr:	Device I/O address
> + *	@irq:		Device IRQ number
> + *
> + *	@state:		Generic network queuing layer state, see netdev_state_t
> + *	@dev_list:	The global list of network devices
> + *	@napi_list:	List entry, that is used for polling napi devices
> + *	@unreg_list:	List entry, that is used, when we are unregistering =
the
> + *			device, see the function unregister_netdev
> + *	@close_list:	List entry, that is used, when we are closing the de=
vice
> + *
> + *	@adj_list:	Directly linked devices, like slaves for bonding
> + *	@all_adj_list:	All linked devices, *including* neighbours
> + *	@features:	Currently active device features
> + *	@hw_features:	User-changable features
s/changable/changeable/

> + *
> + *	@wanted_features:	User-requested features
> + *	@vlan_features:		Mask of features inheritable by VLAN devices
> + *
> + *	@hw_enc_features:	Mask of features inherited by enapsulating devi=
ces
s/enapsulating/encapsulating/

> + *				This field indicates what encapsulation
> + *				offloads the hardware is capable of doing,
> + *				and drivers will need to set them appropriately.
> + *
> + *	@mpls_features:	Mask of features intheritable by MPLS
s/intheritable/inheritable/

> + *
> + *	@ifindex:	interface index
> + *	@iflink:	unique device identifier
> + *
> + *	@stats:		Statistics struct, wich was left as a legacy, use
s/wich/which/

> + *			rtnl_link_stats64 instead
> + *
> + *	@rx_dropped:	Dropped packets by core network,
> + *			do not use this in drivers
> + *	@tx_dropped:	Dropped packets by core network,
> + *			do not use this in drivers
> + *
> + *	@carrier_changes:	Stats to monitor carrier on<->off transitions
> + *
> + *	@wireless_handlers:	List of functions to handle Wireless Extensio=
ns,
> + *				instead of ioctl,
> + *				see <net/iw_handler.h> for details.
> + *	@wireless_data:	Instance data managed by the core of wireless ext=
ensions
> + *
> + *	@netdev_ops:	Includes several pointers to callbacks,
> + *			if one wants to override the ndo_*() functions
> + *	@ethtool_ops:	Management operations
> + *	@fwd_ops:	Management operations
> + *	@header_ops:	Includes callbacks for creating,parsing,rebuilding,e=
tc
> + *			of Layer 2 headers.
> + *
> + *	@flags:		Interface flags (a la BSD)
> + *	@priv_flags:	Like 'flags' but invisible to userspace,
> + *			see if.h for the definitions
> + *	@gflags:	Global flags ( kept as legacy )
> + *	@padded:	How much padding added by alloc_netdev()
> + *	@operstate:	RFC2863 operstate
> + *	@link_mode:	Mapping policy to operstate
> + *	@if_port:	Selectable AUI, TP, ...
> + *	@dma:		DMA channel
> + *	@mtu:		Interface MTU value
> + *	@type:		Interface hardware type
> + *	@hard_header_len: Hardware header length
> + *
> + *	@needed_headroom: Extra headroom the hardware may need, but not i=
n all
> + *			  cases can this be guaranteed
> + *	@needed_tailroom: Extra tai=E9room the hardware may need, but not=
 in all
s/tai=E9room/tailroom/

> + *			  cases can this be guaranteed. Some cases also use
> + *			  LL_MAX_HEADER instead to allocate the skb
> + *
> + *	interface address info:
> + *
> + * 	@perm_addr:		Permanent hw address
> + * 	@addr_assign_type:	Hw address assignment type
> + * 	@addr_len:		Hardware address length
> + * 	@neigh_priv_len;	Used in neigh_alloc(),
> + * 				initialized only in atm/clip.c
> + * 	@dev_id:		Used to differentiate devices that share
> + * 				the same link layer address
> + * 	@dev_port:		Used to differentiate devices that share
> + * 				the same function
> + *	@addr_list_lock:	XXX: need comments on this one
> + *	@uc:			unicast mac addresses
> + *	@mc:			multicas mac addresses
s/multicas/multicast/

> + *	@dev_addrs:		list of device hw addresses
> + *	@queues_kset:		Group of all Kobjects in the Tx and RX queues
> + *	@uc_promisc:		Counter, that indicates, that promiscous mode
s/promiscous/promiscuous/

> + *				has been enabled due to the need to listen to
> + *				additional unicast addresses in a device that
> + *				does not implement ndo_set_rx_mode()
> + *	@promiscuity:		Number of times, the NIC is told to work in
> + *				Promiscuous mode, if it becomes 0 the NIC will
> + *				exit from working in Promiscuous mode
> + *	@allmulti:		Counter, enables or disables allmulticast mode
> + *
> + *	@vlan_info:	VLAN info
> + *	@dsa_ptr:	dsa specific data
> + *	@tipc_ptr:	TIPC specific data
> + *	@atalk_ptr:	AppleTalk link
> + *	@ip_ptr:	IPv4 specific data
> + *	@dn_ptr:	DECnet specific data
> + *	@ip6_ptr:	IPv6 specific data
> + *	@ax25_ptr:	AX.25 specific data
> + *	@ieee80211_ptr:	IEEE 802.11 specific data, assign before register=
ing
> + *
> + *	@last_rx:	Time of last Rx
> + *	@dev_addr:	Hw address (before bcast,
> + *			because most packets are unicast)
> + *
> + *	@_rx:			Array of RX queues
> + *	@num_rx_queues:		Number of RX queues
> + *				allocated at register_netdev() time
> + *	@real_num_rx_queues: 	Number of RX queues currently active in dev=
ice
> + *
> + *	@rx_handler:		handler for received packets
> + *	@rx_handler_data: 	XXX: need comments on this one
> + *	@ingress_queue:		XXX: need comments on this one
> + *	@broadcast:		hw bcast address
> + *
> + *	@_tx:			Array of TX queues
> + *	@num_tx_queues:		Number of TX queues allocated at alloc_netdev_mq=
() time
> + *	@real_num_tx_queues: 	Number of TX queues currently active in dev=
ice
> + *	@qdisc:			Root qdisc form userspace point of view
s/form/from/

> + *	@tx_queue_len:		Max frames per queue allowed
> + *	@tx_global_lock: 	XXX: need comments on this one
> + *
> + *	@xps_maps:	XXX: need comments on this one
> + *
> + *	@rx_cpu_rmap:	CPU reverse-mapping for RX completion interrupts,
> + *			indexed by RX queue number. Assigned by driver.
> + *			This must only be set if the ndo_rx_flow_steer
> + *			operation is defined
> + *
> + *	@trans_start:		Time (in jiffies) of last Tx
> + *	@watchdog_timeo:	Represents the timeout that is used by
> + *				the watchdog ( see dev_watchdog() )
> + *	@watchdog_timer:	List of timers
> + *
> + *	@pcpu_refcnt:		Number of references to this device
> + *	@todo_list:		Delayed register/unregister
> + *	@index_hlist:		Device index hash chain
> + *	@link_watch_list:	XXX: need comments on this one
> + *
> + *	@reg_state:		Register/unregister state machine
> + *	@dismantle:		Device is going to be freed
> + *	@rtnl_link_state:	This enum represents the phases of creating
> + *				a new link
> + *
> + *	@destructor:		Called from unregister,
> + *				can be used to call free_netdev
> + *	@npinfo:		XXX: need comments on this one
> + * 	@nd_net:		Network namespace this network device is inside
> + *
> + * 	@ml_priv:	Mid-layer private
> + * 	@lstats:	Loopback statistics
> + * 	@tstats:	Tunnel statistics
> + * 	@dstats:	Dummy statistics
> + * 	@vstats:	Virtual ethernet statistics
> + *
> + *	@garp_port:	GARP
> + *	@mrp_port:	MRP
> + *
> + *	@dev:		Class/net/name entry
> + *	@sysfs_groups:	Space for optional device, statistics and wireless
> + *			sysfs groups
> + *
> + *	@sysfs_rx_queue_group:	Space for optional per-rx queue attributes
> + *	@rtnl_link_ops:	Rtnl_link_ops
> + *
> + *	@gso_max_size:	Maximum size of generic segmentation offload
> + *	@gso_max_segs:	Maximum number of segments that can be passed to t=
he
> + *			NIC for GSO
> + *
> + *	@dcbnl_ops:	Data Center Bridging netlink ops
> + *	@num_tc:	Number of traffic classes in the net device
> + *	@tc_to_txq:	XXX: need comments on this one
> + *	@prio_tc_map	XXX: need comments on this one
> + *
> + *	@fcoe_ddp_xid:	Max exchange id for FCoE LRO by ddp
> + *
> + *	@priomap:	XXX: need comments on this one
> + *	@phydev:	Physical device may attach itself
> + *			for hardware timestamping
> + *
> + *	@qdisc_tx_busylock:	XXX: need comments on this one
> + *
> + *	@group:		The group, that the device belongs to
> + *	@pm_qos_req:	Power Management QoS object
>   *
>   *	FIXME: cleanup struct net_device such that network protocol info
>   *	moves out.
>   */
<<snip>>

Sorry for my previous emails, but something goes wrong each time I try =
to reply
to them so I'm sending this reply as a new/clean one.

Cheers,
 Nik


