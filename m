From: "John W. Linville" <linville@redhat.com>
Subject: kernel-2.6.14-1.1637_FC4.netdev.2 now available
Date: Wed, 16 Nov 2005 09:33:56 -0500
Message-ID: <20051116143356.GF8356@redhat.com>
References: <20051114205110.GK25755@redhat.com>
Reply-To: Development discussions related to Fedora Core <fedora-devel-list@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <fedora-devel-list-bounces@redhat.com>
To: fedora-list@redhat.com, fedora-devel-list@redhat.com,
	netdev@vger.kernel.org
Content-Disposition: inline
In-Reply-To: <20051114205110.GK25755@redhat.com>
List-Unsubscribe: <https://www.redhat.com/mailman/listinfo/fedora-devel-list>,
	<mailto:fedora-devel-list-request@redhat.com?subject=unsubscribe>
List-Archive: <https://www.redhat.com/archives/fedora-devel-list>
List-Post: <mailto:fedora-devel-list@redhat.com>
List-Help: <mailto:fedora-devel-list-request@redhat.com?subject=help>
List-Subscribe: <https://www.redhat.com/mailman/listinfo/fedora-devel-list>,
	<mailto:fedora-devel-list-request@redhat.com?subject=subscribe>
Sender: fedora-devel-list-bounces@redhat.com
Errors-To: fedora-devel-list-bounces@redhat.com
List-Id: netdev.vger.kernel.org

The second FC4 fedora-netdev kernel is now available.  If you are
already a fedora-netdev user, a simple 'yum update' should retrieve
the new kernels for you.

I now have a fedora-netdev-release package available.  This simplifies
the process of configuring yum for the fedora-netdev repository.
The FC4 fedora-netdev-release package is available here:

	http://people.redhat.com/linville/kernels/fedora-netdev/4/fedora-netdev-release-4-0.noarch.rpm

Download and install that, then you will be able to use yum to get
the FC4 fedora-netdev kernels.

Thanks, and good luck! :-)

John

P.S.  What is fedora-netdev?

The purpose of this repository is two-fold: 1) to make bleeding-edge
linux kernel networking developments available to Fedora users who
need or want access to them; and, 2) to open-up the Fedora user
base as a better testing resource for the kernel netdev community.
I hope this will prove to be a win-win situation for both camps.

If you are a Fedora user with an interest or need for the latest
developments in Linux kernel networking, then _please_ try the
kernels from this repository.  Your testing and feedback is greatly
appreciated, desperately requested, and graciously accepted.
Thanks in advance!

P.P.S.  What netdev patches are in it?

- sky2: new experimental Marvell Yukon2 driver
- 8139cp: support ETHTOOL_GPERMADDR
- 8139too: support ETHTOOL_GPERMADDR
- b44: support ETHTOOL_GPERMADDR
- e1000: support ETHTOOL_GPERMADDR
- e100: support ETHTOOL_GPERMADDR
- forcedeth: support ETHTOOL_GPERMADDR
- ixgb: support ETHTOOL_GPERMADDR
- ne2k-pci: support ETHTOOL_GPERMADDR
- pcnet32: support ETHTOOL_GPERMADDR
- r8169: support ETHTOOL_GPERMADDR
- skge: support ETHTOOL_GPERMADDR
- sundance: support ETHTOOL_GPERMADDR
- via-rhine: support ETHTOOL_GPERMADDR
- drivers/net: fix-up schedule_timeout() usage
- Replace drivers/net/wan custom ctype macros with standard ones
- drivers/net/wan/: possible cleanups
- lne390 bogus casts
- C99 initializers in ray_cs.c
- mii: Add test for GigE support
- Add rapidio net driver
- pcnet32: set_ringparam implementation
- pcnet32: set min ring size to 4
- sky2: driver update.
- orinoco: Remove conditionals that are useless in the kernel drivers.
- orinoco: Don't include <net/ieee80211.h> twice.
- orinoco: Update PCMCIA ID's.
- Fixed some endian issues with 802.11 header usage in ieee80211_rx.c
- ieee80211 quality scaling algorithm extension handler
- ieee80211 Added wireless spy support
- Changed 802.11 headers to use ieee80211_info_element[0]
- ieee80211 Removed ieee80211_info_element_hdr
- ieee80211 Cleanup memcpy parameters.
- ieee80211 Switched to sscanf in store_debug_level
- ieee80211 Fixed type-o of abg_ture -> abg_true
- Updated ipw2200 to compile with ieee80211 abg_ture to abg_true change
- sky2: fix FIFO DMA alignment problems
- sky2: allow ethtool debug access to all of PCI space
- sky2: version 0.5
- ieee80211: Updated ipw2100 to be compatible with ieee80211_hdr changes
- ieee80211: Updated ipw2100 to be compatible with ieee80211's hard_start_xmit change
- ieee80211: Updated ipw2200 to be compatible with ieee80211_hdr changes
- ieee80211: Updated ipw2200 to be compatible with ieee80211's hard_start_xmit change.
- ieee80211: Updated atmel to be compatible with ieee80211_hdr changes
- ieee80211: Fixed a kernel oops on module unload
- ieee80211: Hardware crypto and fragmentation offload support
- ieee80211: Fix time calculation, switching to use jiffies_to_msecs
- ieee80211: Fix kernel Oops when module unload
- ieee80211: Allow drivers to fix an issue when using wpa_supplicant with WEP
- ieee82011: Added WE-18 support to default wireless extension handler
- ieee80211: Renamed ieee80211_hdr to ieee80211_hdr_3addr
- ieee80211: adds support for the creation of RTS packets
- ieee82011: Added ieee80211_tx_frame to convert generic 802.11 data frames, and callbacks
- ieee80211: Fix TKIP, repeated fragmentation problem, and payload_size reporting
- ieee80211: Return NETDEV_TX_BUSY when QoS buffer full
- ieee80211: Add QoS (WME) support to the ieee80211 subsystem
- ieee80211: Added ieee80211_geo to provide helper functions
- ieee80211: Added ieee80211_radiotap.h
- ieee80211: Additional fixes for endian-aware types
- ieee80211: "extern inline" to "static inline"
- ieee80211: Type-o, capbility definition for QoS, and ERP parsing
- ieee80211: Mixed PTK/GTK CCMP/TKIP support
- ieee80211: Keep auth mode unchanged after iwconfig key off/on cycle
- ieee80211: Updated copyright dates
- ieee80211: Updated hostap to be compatible with ieee80211_hdr changes
- ieee80211: Updated hostap to be compatible with extra_prefix_len changes
- ieee82011: Remove WIRELESS_EXT ifdefs
- forcedeth: add hardware tx checksumming
- ieee80211: Added subsystem version string and reporting via MODULE_VERSION
- ieee80211: Added handle_deauth() callback, enhanced tkip/ccmp support of varying hw/sw offload
- ieee80211: added IE comments, reason_code to reason, removed info_element from ieee80211_disassoc
- ieee80211: in-tree driver updates to sync with latest ieee80211 series
- ieee80211: update orinoco, wl3501 drivers for latest struct naming
- orinoco: Remove inneeded system includes.
- orinoco: Make nortel_pci_hw_init() static.
- orinoco: Fix memory leak and unneeded unlock in orinoco_join_ap()
- orinoco: orinoco_send_wevents() could return without unlocking.
- orinoco: Remove unneeded forward declarations.
- orinoco: Annotate endianess of variables and structure members.
- orinoco: Read only needed data in __orinoco_ev_txexc().
- orinoco: Bump version to 0.15rc3.
- RPC: Report connection errors properly when mounting with "soft"
- RPC: proper soft timeout behavior for rpcbind
- NFS: use a constant value for TCP retransmit timeouts
- RPC: portmapper doesn't need a reserved port
- RPC: extract socket logic common to both client and server
- RPC: introduce client-side transport switch
- RPC: transport switch function naming
- RPC: Reduce stack utilization in xs_sendpages
- RPC: Rename sock_lock
- RPC: Rename xprt_lock
- RPC: rename the sockstate field
- RPC: Eliminate socket.h includes in RPC client
- RPC: Add helper for waking tasks pending on a transport
- RPC: client-side transport switch cleanup
- RPC: separate TCP and UDP write space callbacks
- RPC: separate TCP and UDP transport connection logic
- RPC: separate TCP and UDP socket write paths
- RPC: skip over transport-specific heads automatically
- RPC: get rid of xprt->stream
- RPC: add API to set transport-specific timeouts
- RPC: expose API for serializing access to RPC transports
- RPC: expose API for serializing access to RPC transports
- RPC: separate xprt_timer implementations
- RPC: add generic interface for adjusting the congestion window
- RPC: add a release_rqst callout to the RPC transport switch
- RPC: remove xprt->nocong
- RPC: clean up after nocong was removed
- RPC: allow RPC client's port range to be adjustable
- RPC: make sure to get the same local port number when reconnecting
- RPC: parametrize various transport connect timeouts
- RPC: rationalize set_buffer_size
- RPC,NFS: new rpc_pipefs patch
- Revert "[PATCH] RPC,NFS: new rpc_pipefs patch"
- SUNRPC: fix bug in patch "portmapper doesn't need a reserved port"
- [netdrvr gianfar] use new phy layer
- [netdrvr] delete CONFIG_PHYCONTROL
- hostap: Fix pci_driver name for hostap_plx and hostap_pci
- hostap: Add support for WE-19
- hostap: Use GFP_ATOMIC to get rid of weird might_sleep issue
- hostap: Remove iwe_stream_add_event kludge
- Remove WIRELESS_EXT ifdefs from several wireless drivers.
- [wireless airo] remove needed dma_addr_t obfuscation
- sky2: changing mtu doesn't have to reset link
- sky2: cleanup interrupt processing
- sky2: add hardware VLAN acceleration support
- sky2: explicit set power state
- sky2: version 0.6
- sky2: nway reset (BONUS FEATURE)
- This patch fixes a typo in ieee80211.h: ieee82011_deauth -> ieee80211_deauth
- This will move the ieee80211_is_ofdm_rate function to the ieee80211.h
- Currently the info_element is parsed by 2 seperate functions, this
- When an assoc_resp is received the network structure is not completely
- Lindent and trailing whitespace script executed ieee80211 subsystem
- hostap: Remove hw specific dev_open/close handlers
- hostap: Fix hostap_pci build with PRISM2_IO_DEBUG
- hostap: Do not free local->hw_priv before unregistering netdev
- hostap: Unregister netdevs before freeing local data
- S2io: MSI/MSI-X support (runtime configurable)
- e1000: Support for 82571 and 82572 controllers
- e1000: multi-queue defines/modification to data structures
- e1000: implementation of the multi-queue feature
- e1000: Enable custom configuration bits for 82571/2 controllers
- e1000: Fixes for packet split related issues
- e1000: Added msleep_interruptible delay
- e1000: Flush shadow RAM
- e1000: fix warnings
- AX.25: Delete debug printk from mkiss driver
- AX.25: Convert mkiss.c to DEFINE_RWLOCK
- airo: fix resume
- s2io: change strncpy length arg to use size of target
- [netdrvr s2io] Add a MODULE_VERSION entry
- bonding: replicate IGMP traffic in activebackup mode
- sky2: add permanent address support.
- [wireless ipw2200] remove redundant return statement
- S2io: Offline diagnostics fixes
- rcu in bpqether driver.
- SMACK support for mkiss
- Initialize the .owner field the tty_ldisc structure.
- SUNRPC: Retry rpcbind requests if the server's portmapper isn't up
- RPC: allow call_encode() to delay transmission of an RPC call.
- ieee80211: division by zero fix
- sb1250-mac: Check the actual setting for reporting hw checksumming.
- sb1250-mac: Ensure 16-byte alignment of the descriptor ring.
- au1000_eth: Misc Au1000 net driver fixes.
- de2104x: Resurrect Cobalt support for 2.6.
- sgiseeq: Fix resource handling.
- sgiseeq: Configure PIO and DMA timing requests.
- declance: Convert to irqreturn_t.
- declance: Fix mapping of device.
- declance: Deal with the bloody KSEG vs CKSEG horror...
- declance: Use physical addresses at the interface level.
- ne: Support for RBHMA4500 eval board.
- mipsnet: Virtual ethernet driver for MIPSsim.
- e1000_intr build fix
- s2io build fix
- via-rhine: change mdelay to msleep and remove from ISR path
- epic100: fix counting of work_done in epic_poll
- bonding: cleanup comment for mode 1 IGMP xmit hack
- b44: alternate allocation option for DMA descriptors
- orinoco: remove redundance skb length check before padding
- sundance: remove if (1) { ... } block in sundance_probe1
- sundance: expand reset mask
- e1000 build fix
- RPC: stops the release_pipe() funtion from being called twice
- SUNRPC: Add support for privacy to generic gss-api code.
- SUNRPC: Provide a callback to allow free pages allocated during xdr encoding
- SUNRPC: Retry wrap in case of memory allocation failure.
- RPCSEC_GSS: cleanup au_rslack calculation
- RPCSEC_GSS: client-side privacy support
- RPCSEC_GSS: Simplify rpcsec_gss crypto code
- RPCSEC_GSS: krb5 pre-privacy cleanup
- RPCSEC_GSS: Add support for privacy to krb5 rpcsec_gss mechanism.
- RPCSEC_GSS remove all qop parameters
- RPCSEC_GSS: krb5 cleanup
- Fixed problem with not being able to decrypt/encrypt broadcast packets.
- sb1250-mac: Get rid of all the funny SBMAC_WRITECSR and SBMAC_READCSR macros.
- sb1250-mac: Whitespace cleanup.
- sundance: include MII address 0 in PHY probe
- e1000: Driver version, white space, comments, device id & other
- Fixed oops if an uninitialized key is used for encryption.
- sb1250-mac: PHY probing fixes.
- ieee80211 subsystem:
- Update version ieee80211 stamp to 1.1.6
- [PARISC] Change the driver names so /sys/bus/parisc/drivers/ looks better
- [PARISC] Convert parisc_device to use struct resource for hpa
- [PARISC] Add NETPOLL support to lasi_82596
- [DECNET]: Remove some redundant ifdeffed code
- [NET]: Wider use of for_each_*cpu()
- [PKTGEN]: Sleeping function called under lock
- [PKTGEN]: Use kzalloc
- [PKTGEN]: Spelling and white space
- [PKTGEN]: proc interface revision
- [NETFILTER] ip_conntrack: Make "hashsize" conntrack parameter writable
- [IPV4]: Kill redundant rcu_dereference on fa_info
- [IPSEC]: Kill obsolete get_mss function
- [NETLINK]: Remove dead code in af_netlink.c
- [IPV4]: Remove dead code from ip_output.c
- [SK_BUFF] kernel-doc: fix skbuff warnings
- [AX.25]: Use constant instead of magic number
- [IPV4]: Fix setting broadcast for SIOCSIFNETMASK
- [netdrvr forcedeth] scatter gather and segmentation offload support
- ieee80211 build fix
- Revert "RPC: stops the release_pipe() funtion from being called twice"
- RPC: Ensure that nobody can queue up new upcalls after rpc_close_pipes()
- gfp_t: net/*
- gfp_t: drivers/net
- [ARM] 2919/1: CS8900A ethernet driver modifications for the Comdial MP1000
- [ARM] 2897/2: PXA2xx IRDA support
- sky2: remove unused definitions
- sky2: use kzalloc
- sky2: spelling fixes
- sky2: fix NAPI and receive handling
- sky2: version 0.7
- DRIVER MODEL: Get rid of the obsolete tri-level suspend/resume callbacks
- [Bluetooth] Make more functions static
- [Bluetooth] Update security filter for Extended Inquiry Response
- [IPv4/IPv6]: UFO Scatter-gather approach
- [MCAST] IPv6: Fix algorithm to compute Querier's Query Interval
- tg3: add 5714/5715 support
- tg3: fix ASF heartbeat
- tg3: update version and minor fixes
- ibmveth fix bonding
- ibmveth fix buffer pool management
- ibmveth fix buffer replenishing
- ibmveth lockless TX
- ibmveth fix failed addbuf
- pcnet_cs: fix mii init code for older DL10019 based cards
- s2io: kconfig help fix
- b44 reports wrong advertised flags
- sis190.c: fix multicast MAC filter
- smc91x: shut down power after probing
- starfire: free_irq() on error path of netdev_open()
- [netdrvr b44] include linux/dma-mapping.h to eliminate warning
- sundance: fix DFE-580TX Tx Underrun
- New PowerPC 4xx on-chip ethernet controller driver
- sis900: come alive after temporary memory shortage
- Add Wake on LAN support to sis900 (2)
- drivers/net: Remove pointless checks for NULL prior to calling kfree()
- [netdrvr] ne2k-pci based card does not support bus-mastering.
- ipw2200: Missing kmalloc check
- [SCTP] Rename SCTP specific control message flags.
- [SCTP] Fix SCTP_SETADAPTION sockopt to use the correct structure.
- [SCTP] Allow SCTP_MAXSEG to revert to default frag point with a '0' value.
- [SCTP] Do not allow unprivileged programs initiating new associations on
- e1000: remove warning about e1000_suspend
- eepro.c: module_param_array cleanup
- b44: fix suspend/resume
- e1000: use vmalloc_node()
- revert "orinoco: Information leakage due to incorrect padding"
- Better fixup for the orinoco driver
- e1000: Fixes e1000_suspend warning when CONFIG_PM is not enabled
- [ETH]: ether address compare
- Add modalias for pmac network drivers
- mv643xx_eth_showsram: Added information message when using the SRAM
- [IPV4]: Fix issue reported by Coverity in ipv4/fib_frontend.c
- s2io iomem annotations
- bluetooth hidp is broken on s390
- drivers/net/tg3: Use the DMA_{32,64}BIT_MASK constants
- prism54: Free skb after disabling interrupts
- [DRIVER MODEL] Add missing platform_device.h header.
- PPC 44x EMAC driver: add 440SPe support
- PPC 44x EMAC driver: add 440GR support
- PPC 4xx EMAC driver: fix VSC8201 PHY initialization
- fec_8xx: Remove dependency on NETTA & NETPHONE
- fec_8xx: Add support for Intel PHY LX971
- vmalloc_node
- [ARM] 3066/1: Fix PXA irda driver suspend/resume functions
- m32r: SMC91x driver update
- smsc-ircc2: PM cleanup - do not close device when suspending
- remove some more check_region stuff
- Typo fix: dot after newline in printk strings
- sparse cleanups: NULL pointers, C99 struct init.
- [netdrvr 8139too] replace hand-crafted kernel thread with workqueue
- [BRIDGE]: Use ether_compare
- [NETFILTER]: Add "revision" support to arp_tables and ip6_tables
- [ROSE]: rose_heartbeat_expiry() locking fix
- [IPV6]: Fix behavior of ip6_route_input() for link local address
- [DCCP]: Simplify skb_set_owner_w semantics
- [DCCP]: Set socket owner iff packet is not data
- [MCAST] IPv6: Check packet size when process Multicast
- ibmveth fix panic in initial replenish cycle
- [MCAST]: ip[6]_mc_add_src should be called when number of sources is zero
- [IPV6]: inet6_ifinfo_notify should use RTM_DELLINK in addrconf_ifdown
- [PKT_SCHED]: Rework QoS and/or fair queueing configuration
- ARM: Reverted 2919/1: CS8900A ethernet driver modifications for the Comdial MP1000
- SUNRPC: allow sunrpc.o to link when CONFIG_SYSCTL is disabled
- NFS,SUNRPC,NLM: fix unused variable warnings when CONFIG_SYSCTL is disabled
- [NETFILTER] PPTP helper: Fix compilation of conntrack helper without NAT
- [NETFILTER] PPTP helper: Fix endianness bug in GRE key / CallID NAT
- [NETFILTER] NAT: Fix module refcount dropping too far
- [netdrvr 8139too] use cancel_rearming_delayed_work() to cancel thread
- [netdrvr 8139too] use rtnl_shlock_nowait() rather than rtnl_lock_interruptible()
- [NETFILTER]: Fix double free after netlink_unicast() in ctnetlink
- [NETFILTER] nfnetlink: Use kzalloc
- [NETFILTER]: CONNMARK target needs ip_conntrack
- [NETFILTER] nf_queue: Fix Ooops when no queue handler registered
- [NETEM]: use PSCHED_LESS
- drivers/net/wireless/airo.c unsigned comparason
- S2io: Multi buffer mode support
- pcnet32: show name of failing device
- pcnet32: AT2700/2701 and Bugzilla 2699 & 4551
- pcnet32: Prevent hang with 79c976
- phy address mask support for generic phy layer
- [PKT_SCHED]: Generic RED layer
- [NET]: Introduce INET_ECN_set_ce() function
- [PKT_SCHED]: RED: Use new generic red interface
- [PKT_SCHED]: RED: Use generic queue management interface
- [PKT_SCHED]: RED: Dont start idle periods while already idling
- [PKT_SCHED]: RED: Cleanup and remove unnecessary code
- [PKT_SCHED]: GRED: Cleanup equalize flag and add new WRED mode detection
- [PKT_SCHED]: GRED: Transform grio to GRED_RIO_MODE
- [PKT_SCHED]: GRED: Cleanup dumping
- [PKT_SCHED]: GRED: Dump table definition
- [PKT_SCHED]: GRED: Use a central table definition change procedure
- [PKT_SCHED]: GRED: Report out-of-bound DPs as illegal
- [PKT_SCHED]: GRED: Use central VQ change procedure
- [PKT_SCHED]: GRED: Use new generic red interface
- [PKT_SCHED]: GRED: Do not reset statistics in gred_reset/gred_change
- [PKT_SCHED]: GRED: Report congestion related drops as NET_XMIT_CN
- [PKT_SCHED]: GRED: Use generic queue management interface
- [PKT_SCHED]: GRED: Introduce tc_index_to_dp()
- [PKT_SCHED]: GRED: Improve error handling and messages
- [PKT_SCHED]: GRED: Remove initd flag
- [PKT_SCHED]: GRED: Dont abuse default VQ for equalizing
- [PKT_SCHED]: GRED: Remove auto-creation of default VQ
- [PKT_SCHED]: GRED: Cleanup and remove unnecessary code
- [PKT_SCHED]: GRED: Fix restart of idle period in WRED mode upon dequeue and drop
- [PKT_SCHED]: GRED: Support ECN marking
- [PKT_SCHED]: (G)RED: Introduce hard dropping
- [DRIVER MODEL] Improved dynamically allocated platform_device interface
- [DRIVER MODEL] Fix depca
- [DRIVER MODEL] Fix jazzsonic
- [DRIVER MODEL] Fix macsonic
- [NETEM]: Support time based reordering
- [NETEM]: Add version string
- [NET]: Fix race condition in sk_stream_wait_connect
- [TCP/DCCP]: Randomize port selection
- drivers/net/ixgb/: make some code static
- drivers/net/e1000/: possible cleanups
- drivers/net/hamradio/dmascc.c: remove dmascc_setup()
- prism54: Remove redundant assignment
- bnx2: add 5708 support
- bnx2: update firmware for 5708
- bnx2: update nvram code for 5708
- bnx2: update firmware handshake for 5708
- bnx2: refine bnx2_poll
- bnx2: update version and minor fixes
- Remove linux/version.h include from drivers/net/phy/* and net/ieee80211/*.
- [netdrvr] fac_8xx build fix
- [netdrvr s2io] warning fixes
- b44: b44_start_xmit returns with a lock held when it fails allocating
- b44: miscellaneous cleanup
- b44: expose counters through ethtool
- b44: s/spin_lock_irqsave/spin_lock/ in b44_interrupt
- b44: late request_irq in b44_open
- 3c59x: convert to use of pci_iomap API
- 3c59x: cleanup of mdio_read routines to use MII_* macros
- 3c59x: avoid blindly reading link status twice
- 3c59x: bounds checking for hw_checksums
- 3c59x: cleanup init of module parameter arrays
- 3c59x: fix some grammar in module parameter descriptions
- 3c59x: support ETHTOOL_GPERMADDR
- 3c59x: correct rx_dropped counting
- 3c59x: enable use of memory-mapped PCI I/O
- 3c59x: don't enable scatter/gather w/o checksum support
- knfsd: make sure svc_process call the correct pg_authenticate for multi-service port
- kernel-doc: fix warnings in vmalloc.c
- m68knommu: FEC ethernet header support for the ColdFire 5208
- m68knommu: FEC ethernet support for the ColdFire 5208
- scripts/Lindent on ieee80211 subsystem.
- Fix problem with WEP unicast key > index 0
- Update version ieee80211 stamp to 1.1.7
- Ran scripts/Lindent on drivers/net/wireless/ipw2{1,2}00.{c,h}
- IPW_DEBUG has already included DRV_NAME, remove double prefix print.
- Catch ipw2200 up to equivelancy with v1.0.1
- Catch ipw2200 up to equivelancy with v1.0.2
- Catch ipw2200 up to equivelancy with v1.0.3
- Catch ipw2200 up to equivelancy with v1.0.4
- Catch ipw2100 up to equivelancy with v1.1.1
- Fixed WEP on ipw2100 (priv->sec was being used instead of
- [Bug 339] Fix ipw2100 iwconfig set/get txpower.
- Move code from ipw2100_wpa_enable to IPW2100_PARAM_DROP_UNENCRYPTED to
- Catch ipw2200 up to equivelancy with v1.0.5
- Fix hardware encryption (both WEP and AES) doesn't work with fragmentation.
- Fix is_duplicate_packet() bug for fragmentation number setting.
- [bug 667] Fix the notorious "No space for Tx" bug.
- [Bug 637] Set tx power for A band.
- Changed default # of missed beacons to miss before disassociation to 24
- Updated to support ieee80211 callback to is_queue_full for 802.11e
- Fixed some compiler issues if CONFIG_IPW2200_QOS is enabled.
- Added more useful geography encoding so people's experience with
- Workaround kernel BUG_ON panic caused by unexpected duplicate packets.
- Disable host fragmentation in open mode since IPW2200/2915 hardware
- [Bug 792] Fix WPA-PSK AES both for -Dipw and -Dwext.
- Fixes the ad-hoc network WEP key list issue.
- [Bug 701] Fix a misuse of ieee->mode with ieee->iw_mode.
- Fix ipw_wx_get_txpow shows wrong disabled value.
- Fix firmware error when setting tx_power.
- Modified ipw_config and STATUS_INIT setting to correct race condition
- Switched firmware error dumping so that it will capture a log available
- Changed all of the ipw_send_cmd() calls to return any ipw_send_cmd error
- Added cmdlog in non-debug systems.
- Migrated some of the channel verification code back into the driver to
- Updated ipw2200 to use the new ieee80211 callbacks
- Added wait_state wakeup on scan completion.
- [Bug 455] Fix frequent channel change generates firmware fatal error.
- [Bug 760] Fix setting WEP key in monitor mode causes IV lost.
- Don't set hardware WEP if we are actually using TKIP/AES.
- Make all the places the firmware fails to load showerrors (in decimal,
- Adds radiotap support to ipw2200 in monitor mode..
- Fixed is_network_packet() to include checking for broadcast packets.
- Mixed PTK/GTK CCMP/TKIP support.
- Card with WEP enabled and using shared-key auth will have firmware
- Fixed problem with get_cmd_string not existing if CONFIG_IPW_DEBUG disabled.
- Removed PF_SYNCTHREAD legacy.
- Fixes problem with WEP not working (association succeeds, but no Tx/Rx)
- [Fix bug# 771] Too many (8) bytes recieved when using AES/hwcrypto
- Fixes WEP firmware error condition.
- Updated driver version stamps for ipw2100 (1.1.3) and ipw2200 (1.0.7)
- Pulled out a stray KERNEL_VERSION check around the suspend handler.
- Fix 'Driver using old /proc/net/wireless support, please fix driver !' message.
- Removed legacy WIRELESS_EXT checks from ipw2200.c
- Fixes missed beacon logic in relation to on-network AP roaming.
- Removed warning about TKIP not being configured if countermeasures are
- Added channel support for ipw2200 cards identified as 'ZZR'
- Fixed problem with not being able to send broadcast packets.
- Fixed parameter reordering in firmware log routine.
- Updated firmware version stamp to 2.4 from 2.3 so it will use the latest firmware.
- Update version ipw2200 stamp to 1.0.8
- fix NET_RADIO=n, IEEE80211=y compile
- bonding: fix feature consolidation
- kill include/linux/eeprom.h
- drivers/net/s2io.c: make functions static
- prism54 : Unused variable / extraneous udelay
- prism54 : Transmit stats updated in wrong place
- Fix sparse warning in e100 driver.
- atmel: memset correct range
- [IPV6]: Put addr_diff() into common header for future use.
- [IPV6]: Make ipv6_addr_type() more generic so that we can use it for source address selection.
- [IPV6]: RFC3484 compliant source address selection
- [PKT_SCHED]: Correctly handle empty ematch trees
- [NET]: sk_add_backlog convert from macro to inline
- [PPP]: handle misaligned accesses
- [PPP]: add PPP MPPE encryption module
- [IRDA] donauboe: locking fix
- [NET]: kfree cleanup
- [IPV4]: Fix ip_queue_xmit identity increment for TSO packets
- [Bluetooth]: Add endian annotations to the core
- [Bluetooth]: Remove the usage of /proc completely
- [SERIAL] IOC3: Update 8250 driver bits
- skge: clear PCI PHY COMA mode on boot
- skge: use kzalloc
- skge: add mii ioctl support
- skge: goto low power mode on shutdown
- skge: use prefetch on receive
- skge: spelling fixes
- skge: increase version number
- [wireless ipw2100] kill unused-var warnings for debug-disabled code
- ieee80211: cleanup crypto list handling, other minor cleanups.
- b44: replace B44_FLAG_INIT_COMPLETE with netif_running()
- b44: race on device closing
- b44: increase version number
- dgrs: fix warnings when CONFIG_ISA and CONFIG_PCI are not enabled
- IOC: And don't mark the things as broken Cowboy.
- add a vfs_permission helper
- sanitize lookup_hash prototype
- [NETFILTER]: packet counter of conntrack is 32bits
- [NETFILTER]: refcount leak of proto when ctnetlink dumping tuple
- [NETFILTER] nfnetlink: nfattr_parse() can never fail, make it void
- [NETFILTER] ctnetlink: check if protoinfo is present
- [NETFILTER] ctnetlink: add marking support from userspace
- [NETFILTER] ctnetlink: add module alias to fix autoloading
- [NETFILTER] ctnetlink: kill unused includes
- [NETFILTER] ctnetlink: get_conntrack can use GFP_KERNEL
- [NETFILTER] PPTP helper: fix PNS-PAC expectation call id
- [NETFILTER] nfnetlink: only load subsystems if CAP_NET_ADMIN is set
- [NETFILTER]: stop tracking ICMP error at early point
- [NETFILTER] ctnetlink: return -EINVAL if size is wrong
- [NETFILTER] ctnetlink: propagate error instaed of returning -EPERM
- [NETFILTER] ctnetlink: Add support to identify expectations by ID's
- [NETFILTER] ctnetlink: Fix oops when no ICMP ID info in message
- [NETFILTER] ctnetlink: ICMP_ID is u_int16_t not u_int8_t.
- [IPV6]: Fix fallout from CONFIG_IPV6_PRIVACY
- [IPV6]: ip6ip6_lock is not unlocked in error path.
- [NETFILTER]: Add nf_conntrack subsystem.
- [NETLINK]: Type-safe netlink messages/attributes interface
- [NETLINK]: Make netlink_callback->done() optional
- [NETLINK]: Generic netlink receive queue processor
- [XFRM]: Use generic netlink receive queue processor
- [RTNETLINK]: Use generic netlink receive queue processor
- [NETLINK]: Generic netlink family
- SUNRPC: don't reencode when looping in call transmit.
- [netdrvr 8139too] fast poll for thread, if an unlikely race occurs
- [BNX2]: output driver name as prefix in error message
- [BNX2]: check return of dev_alloc_skb in bnx2_test_loopback
- [BNX2]: simplify parameter checks in bnx2_{get,set}_eeprom
- [NET]: Detect hardware rx checksum faults correctly
- [TCP]: fix congestion window update when using TSO deferal
- [TCP]: simplify microsecond rtt sampling
- [TCP]: add tcp_slow_start helper
- [TCP]: Appropriate Byte Count support
- [TCP]: receive buffer growth limiting with mixed MTU
- [TCP]: spelling fixes
- [TCP]: speed up SACK processing
- disable DEBUG in ibmveth
- sky2 needs dma_mapping.h
- gianfar mii needs to zero out the mii_bus structure
- [netdrvr forcedeth] remove superfluous rx engine stop/start
- [netdrvr forcedeth] support for irq mitigation
- [netdrvr forcedeth] phy address scan range
- SAA9730: Whitespace cleanup.
- SAA9730: Driver overhaul
- smc91x: DB1200 support.
- gt96100eth.c: Don't concatenate __FUNCTION__ with strings.
- TCP: fix vegas build
- [DECNET]: fix SIGPIPE
- [IPV6]: Fix inet6_init missing unregister.
- [SCTP]: Fix potential NULL pointer dereference in sctp_v4_get_saddr
- [SCTP]: Remove timeouts[] array from sctp_endpoint.
- [SCTP]: Fix ia64 NaT consumption fault with sctp_sideffect commands.
- [SCTP]: Include ulpevents in socket receive buffer accounting.
-- 
John W. Linville
linville@redhat.com

-- 
fedora-devel-list mailing list
fedora-devel-list@redhat.com
https://www.redhat.com/mailman/listinfo/fedora-devel-list
