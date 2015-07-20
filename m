From: Xiong Zhou <jencce.kernel@gmail.com>
Subject: Re: [GIT] Networking
Date: Mon, 20 Jul 2015 18:11:02 +0800
Message-ID: <CADJHv_vZZE-nrA2KO2-yB3QCYBDO=SinYjPSKtFjQ_W=JjXVfg@mail.gmail.com>
References: <20150624.063911.1220157256743743341.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	akpm@linux-foundation.org, netdev@vger.kernel.org,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: David Miller <davem@davemloft.net>, linux-wireless@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f65.google.com ([209.85.215.65]:32885 "EHLO
	mail-la0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752272AbbGTKLG convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Jul 2015 06:11:06 -0400
In-Reply-To: <20150624.063911.1220157256743743341.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi

On Wed, Jun 24, 2015 at 9:39 PM, David Miller <davem@davemloft.net> wro=
te:
>
> 1) Add TX fast path in mac80211, from Johannes Berg.
>
> 2) Add TSO/GRO support to ibmveth, from Thomas Falcon
>
> 3) Move away from cached routes in ipv6, just like ipv4, from Martin
>    KaFai Lau.
>
> 4) Lots of new rhashtable tests, from Thomas Graf.
>
> 5) Run ingress qdisc lockless, from Alexei Starovoitov.
>
> 6) Allow servers to fetch TCP packet headers for SYN packets
>    of new connections, for fingerprinting.  From Eric Dumazet.
>
> 7) Add mode parameter to pktgen, for testing receive.  From Alexei
>    Starovoitov.
>
> 8) Cache access optimizations via simplifications of build_skb(), fro=
m
>    Alexander Duyck.
>
> 9) Move page frag allocator under mm/, also from Alexander.
>
> 10) Add xmit_more support to hv_netvsc, from KY Srinivasan.
>
> 11) Add a counter guard in case we try to perform endless reclassify
>     loops in the packet scheduler.
>
> 12) Extern flow dissector to be programmable and use it in new "Flowe=
r"
>     classifier.  From Jiri Pirko.
>
> 13) AF_PACKET fanout rollover fixes, performance improvements, and ne=
w
>     statistics.  From Willem de Bruijn.
>
> 14) Add netdev driver for GENEVE tunnels, from John W. Linville.
>
> 15) Add ingress netfilter hooks and filtering, from Pablo Neira Ayuso=
=2E
>
> 16) Fix handling of epoll edge triggers in TCP, from Eric Dumazet.
>
> 17) Add an ECN retry fallback for the initial TCP handshake, from Dan=
iel
>     Borkmann.
>
> 18) Add tail call support to BPF, from Alexei Starovoitov.
>
> 19) Add several pktgen helper scripts, from Jesper Dangaard Brouer.
>
> 20) Add zerocopy support to AF_UNIX, from Hannes Frederic Sowa.
>
> 21) Favor even port numbers for allocation to connect() requests, and
>     odd port numbers for bind(0), in an effort to help avoid
>     ip_local_port_range exhaustion.  From Eric Dumazet.
>
> 22) Add Cavium ThunderX driver, from Sunil Goutham.
>
> 23) Allow bpf programs to access skb_iif and dev->ifindex SKB metadat=
a, from
>     Alexei Starovoitov.
>
> 24) Add support for T6 chips in cxgb4vf driver, from Hariprasad Shena=
i.
>
> 25) Double TCP Small Queues default to 256K to accomodate situations
>     like the XEN driver and wireless aggregation.  From Wei Liu.
>
> 26) Add more entropy inputs to flow dissector, from Tom Herbert.
>
> 27) Add CDG congestion control algorithm to TCP, from Kenneth Klette
>     Jonassen.
>
> 28) Convert ipset over to RCU locking, from Jozsef Kadlecsik.
>
> 29) Track and act upon link status of ipv4 route nexthops, from Andy
>     Gospodarek.
>
> Please pull, thanks a lot.
>
> The following changes since commit c8d17b451aa18b07b60e771addf17a5fdd=
4138c7:
>
>   Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net (2015=
-06-12 20:54:16 -1000)
>
> are available in the git repository at:
>
>
>   git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-next.git ma=
ster
>
> for you to fetch changes up to 1ea2d020ba477cb7011a7174e8501a9e04a325=
d4:
>
>   bridge: vlan: flush the dynamically learned entries on port vlan de=
lete (2015-06-24 05:40:55 -0700)
>
> ----------------------------------------------------------------
> Achiad Shochat (8):
>       net/mlx5_core: Add transport domain alloc/dealloc support
>       net/mlx5e: Add transport domain to the ethernet TIRs/TISs
>       net/mlx5e: Remove re-assignment of wq type in mlx5e_enable_rq()
>       net/mlx5e: Avoid redundant dev_kfree_skb() upon NOP completion
>       net/mlx5e: Avoid TX CQE generation if more xmit packets expecte=
d
>       net/mlx5e: Remove extra spaces
>       net/mlx5e: Remove mlx5e_cq.sqrq back-pointer
>       net/mlx5e: Pop cq outside mlx5e_get_cqe
>
> Aleksei Volkov (1):
>       Bluetooth: btusb: Correct typo in Roper Class 1 Bluetooth Dongl=
e
>
> Aleksey Makarov (9):
>       net: thunderx: fix constants
>       net: thunderx: introduce a function for mailbox access
>       net: thunderx: rework mac address handling
>       net: thunderx: delete unused variables
>       net: thunderx: add static
>       net: thunderx: fix nicvf_set_rxfh()
>       net: thunderx: remove unneeded type conversions
>       net: thunderx: check if memory allocation was successful
>       net: thunderx: use GFP_KERNEL in thread context
>
> Alexander Aring (62):
>       nl802154: cleanup invalid argument handling
>       ieee802154: move validation check out of softmac
>       ieee802154: change transmit power to s32
>       ieee802154: change transmit power to mbm
>       ieee802154: change cca ed level to mbm
>       ieee802154: introduce wpan_phy_supported
>       ieee802154: add several phy supported handling
>       mac802154: check for really changes
>       mac802154: remove check if operation is supported
>       cfg802154: introduce wpan phy flags
>       ieee802154: add iftypes capability
>       at86rf230: set cca_modes supported flags
>       at86rf230: rework tx power support
>       at86rf230: rework tx cca energy detection level
>       at86rf230: add cca ed level reset value
>       at86rf230: add reset states of tx power level
>       nl802154: add support for dump phy capabilities
>       at86rf230: fix callback for aret handling
>       mac802154: tx: allow xmit complete from hard irq
>       ieee802154: add support for atusb transceiver
>       fakelb: creating two virtual phys per default
>       fakelb: use list_for_each_entry_safe
>       fakelb: rename fakelb_dev_priv to fakelb_phy
>       fakelb: don't deliver when one phy
>       fakelb: declare rwlock static
>       fakelb: declare fakelb list static
>       fakelb: move lock out of iteration
>       fakelb: introduce fakelb ifup phys list
>       fakelb: use own channel and page attributes
>       fakelb: add virtual phy reset defaults
>       fakelb: remove fakelb_hw_deliver
>       fakelb: add support for async xmit handling
>       fakelb: cleanup code
>       at86rf230: add missing cca ed level values
>       mac802154: fix hold rtnl while ioctl
>       mac802154: remove pib lock
>       mac802154: use atomic ops for sequence incrementation
>       mac802154: remove mib lock
>       nl802154: fix cca mode wpan phy flag
>       nl802154: add support for cca ed level info
>       nl802154: add support to set cca ed level
>       atusb: add support for at86rf230
>       ieee802154: 6lowpan: set ackreq when needed
>       mac802154: remove unneeded vif struct
>       mac802154: cleanup address filtering flags
>       mac802154: remove aack hw flag
>       mac802154: cleanup ieee802154 hardware flags
>       mac802154: remove unused hw_filt attribute
>       mac802154: rearrange attribute in ieee802154_hw
>       mac802154: add missing structure comments
>       mac802154: change pan_coord type to bool
>       mac802154: fix flags BIT definitions order
>       mac802154: iface: fix hrtimer cancel on ifdown
>       mac802154: iface: flush workqueue before stop
>       at86rf230: use level high as fallback default
>       at86rf230: add support for sleep state
>       fakelb: add xmit_async after stop testcase
>       at86rf230: fix phy settings while sleeping
>       at86rf230: add recommended csma backoffs settings
>       at86rf230: cleanup start and stop callbacks
>       mac802154: iface: fix order while interface up
>       mac802154: iface: cleanup stack variable
>
> Alexander Drozdov (1):
>       netfilter: ipset: make ip_set_get_ip*_port to use skb_network_o=
ffset
>
> Alexander Duyck (24):
>       etherdev: Avoid unnecessary byte swap in check for Ethertype
>       etherdev: Process is_multicast_ether_addr at same size as other=
 operations
>       etherdev: Use skb->data to retrieve Ethernet header instead of =
eth_hdr
>       e1000e: Cleanup handling of VLAN_HLEN as a part of max frame si=
ze
>       e1000e: Do not allow CRC stripping to be disabled on 82579 w/ j=
umbo frames
>       etherdev: Fix sparse error, make test usable by other functions
>       ebtables: Use eth_proto_is_802_3
>       ipv4/ip_tunnel_core: Use eth_proto_is_802_3
>       openvswitch: Use eth_proto_is_802_3
>       vlan: Use eth_proto_is_802_3
>       net: Use cached copy of pfmemalloc to avoid accessing page
>       igb: Don't use NETDEV_FRAG_PAGE_MAX_SIZE in descriptor calculat=
ion
>       net: Store virtual address instead of page in netdev_alloc_cach=
e
>       mm/net: Rename and move page fragment handling from net/ to mm/
>       net: Add skb_free_frag to replace use of put_page in freeing sk=
b->head
>       netcp: Replace put_page(virt_to_head_page(ptr)) w/ skb_free_fra=
g
>       mvneta: Replace put_page(virt_to_head_page(ptr)) w/ skb_free_fr=
ag
>       e1000: Replace e1000_free_frag with skb_free_frag
>       hisilicon: Replace put_page(virt_to_head_page()) with skb_free_=
frag()
>       bnx2x, tg3: Replace put_page(virt_to_head_page()) with skb_free=
_frag()
>       net: Reserve skb headroom and set skb->dev even if using __allo=
c_skb
>       ip_tunnel: Report Rx dropped in ip_tunnel_get_stats64
>       fm10k: fold fm10k_pull_tail into fm10k_add_rx_frag
>       fm10k: Fix missing braces after if statement
>
> Alexander Popov (1):
>       net: fs_enet: Fix NETIF_F_SG feature for Freescale MPC5121
>
> Alexei Starovoitov (17):
>       net: sched: run ingress qdisc without locks
>       pktgen: introduce xmit_mode '<start_xmit|netif_receive>'
>       pktgen: fix packet generation
>       bpf: allow bpf programs to tail-call other bpf programs
>       x86: bpf_jit: implement bpf_tail_call() helper
>       samples/bpf: bpf_tail_call example for tracing
>       samples/bpf: bpf_tail_call example for networking
>       bpf: allow BPF programs access skb->skb_iif and skb->dev->ifind=
ex fields
>       bpf: add missing rcu protection when releasing programs from pr=
og_array
>       bpf: introduce bpf_clone_redirect() helper
>       bpf: fix build due to missing tc_verd
>       bpf: make programs see skb->data =3D=3D L2 for ingress and egre=
ss
>       bpf: allow programs to write to certain skb fields
>       bpf: introduce current->pid, tgid, uid, gid, comm accessors
>       bpf: allow networking programs to use bpf_trace_printk() for de=
bugging
>       bpf: let kprobe programs use bpf_get_smp_processor_id() helper
>       bpf: disallow bpf tc programs access current->pid,uid
>
> Alexey Brodkin (1):
>       stmmac: troubleshoot unexpected bits in des0 & des1
>
> Alexey Dobriyan (1):
>       Bluetooth: Stop sabotaging list poisoning
>
> Alexis Green (3):
>       mac80211: Fix incorrectly named last_hop_metric variable in mes=
h_rx_path_sel_frame
>       mac80211: Always check rates and capabilities in mesh mode
>       mac80211: Fix a case of incorrect metric used when forwarding a=
 PREQ
>
> Amir Vadai (5):
>       net/mlx5_core,mlx5_ib: Do not use vmap() on coherent memory
>       net/mlx5: Ethernet Datapath files
>       net/mlx5: Ethernet resource handling files
>       net/mlx5: Extend mlx5_core to support ConnectX-4 Ethernet funct=
ionality
>       net/mlx5_en: Add missing check for memory allocation failure
>
> Amitkumar Karwar (7):
>       mwifiex: fix SDIO firmware dump problem
>       mwifiex: fix a possible double free issue
>       mwifiex: dump driver information for PCIe interface
>       mwifiex: minor changes in debug messages
>       mwifiex: use generic name 'device dump'
>       mwifiex: device dump support via devcoredump framework
>       mwifiex: add missing break statement in switch case
>
> Andrea Parri (1):
>       pkt_sched: sch_qfq: remove redundant -if- control statement
>
> Andreas Gr=C3=B6ger (2):
>       can: janz-ican3: add documentation for existing sysfs entries
>       can: janz-ican3: add support for CAL/CANopen firmware
>
> Andrei Otcheretianski (2):
>       mac80211: adjust reserved chan_ctx when assigned to vif
>       iwlwifi: mvm: Configure agg. queue before assigning it to STA
>
> Andrew Lunn (19):
>       net: ipv4: route: Fix sending IGMP messages with link address
>       net: dsa: Centralise global and port setup code into mv88e6xxx.
>       net: dsa: Centralize setting up ports
>       net: dsa: Converting remaining registers to mnemonics
>       net: dsa: Move mv88e6172 support into mv88e6352 family driver
>       net: dsa: mv88e6171: Add other members of the family
>       net: dsa: mv88e6131: Add support for mv88e6185
>       net: dsa: mv88e6xxx: Replace PHY mutex by SMI mutex
>       net: dsa: mv88e6xxx: Replace stats mutex with SMI mutex
>       net: dsa: mv88e6xxx: Fix false positive lockdep splat
>       net: dsa: Add lockdep class to tx queues to avoid lockdep splat
>       net: dsa: mv88e6xxx: Fix deadlock by double lock
>       dsa: mv88e6xxx: Add debugfs interface for registers
>       dsa: mv88e6xxx: Add debugfs interface for ATU
>       dsa: mv88x6xxx: Refactor getting a single statistic
>       dsa: mv88x6xxx: Add debugfs interface for statistics
>       dsa: mv88x6xxx: Add debugfs interface for device map
>       dsa: mv88x6xxx: Add debugfs interface for scratch registers
>       dsa: mv88x6xxx: Zero statistics counters
>
> Andy Gospodarek (3):
>       bonding: add netlink support for sys prio, actor sys mac, and p=
ort key
>       net: track link-status of ipv4 nexthops
>       net: ipv4 sysctl option to ignore routes when nexthop link is d=
own
>
> Andy Zhou (4):
>       ipv4: introduce frag_expire_skip_icmp()
>       IPv4: skip ICMP for bridge contrack users when defrag expires
>       bridge_netfilter: No ICMP packet on IPv4 fragmentation error
>       ip: remove unused function prototype
>
> Anish Bhatt (1):
>       dcb : Fix incorrect documentation for struct dcb_app
>
> Anjali Singhai Jain (4):
>       i40e/i40evf: Add ATR support for tunneled TCP/IPv4/IPv6 packets=
=2E
>       i40e/i40evf: Add stats to count Tunnel ATR hits
>       i40e: Remove unnecessary pf members
>       i40e: Move the FD ATR/SB messages to a higher debug level
>
> Antonio Borneo (2):
>       net: via-rhine: remove unneeded include file
>       net: via/Kconfig: replace USE_OF with OF_???
>
> Antonio Murdaca (2):
>       ethernet: micrel: use time_after_eq
>       ethernet: micrel: use time_is_before_eq_jiffies
>
> Antonio Quartulli (4):
>       batman-adv: Use common declaration order in *_send_skb_(packet|=
unicast)
>       batman-adv: split name from variable for uint mesh attributes
>       batman-adv: add bat_neigh_free API
>       batman-adv: change the MAC of each VLAN upon ndo_set_mac_addres=
s
>
> Arend van Spriel (20):
>       brcmfmac: use static superset of channels for wiphy bands
>       brcmfmac: update wiphy band information upon updating regulator=
y domain
>       brcmfmac: add description for feature flags
>       brcmfmac: make scheduled scan support conditional
>       brcmfmac: add support for BCM4324 rev B5 chipset
>       brcmfmac: process interrupt regardless sdiod state
>       brcmfmac: fix sdio suspend and resume
>       brcmfmac: add support for BCM4358 PCIe device
>       brcmfmac: allow device tree node without 'interrupts' property
>       brcmfmac: fix invalid access to struct acpi_device fields
>       brcmfmac: remove chipinfo debugfs entry
>       brcmfmac: remove watchdog reset from brcmf_pcie_buscoreprep()
>       brcmfmac: use debugfs_create_devm_seqfile() helper function
>       brcmfmac: rework .get_station() callback
>       brcmfmac: have sdio return -EIO when device communication is no=
t possible
>       brcmfmac: free ifp for non-netdev interface in p2p module
>       brcmfmac: move p2p attach/detach functions
>       brcmfmac: assure p2pdev is unregistered upon driver unload
>       brcmfmac: fix double free of p2pdev interface
>       brcmfmac: make brcmf_p2p_detach() call conditional
>
> Arik Nemtsov (5):
>       iwlwifi: mvm: iterate all interfaces during HW recovery cleanup
>       cfg80211: change GO_CONCURRENT to IR_CONCURRENT for STA
>       mac80211: TDLS: use the BSS chandef for HT/VHT operation IEs
>       mac80211: disconnect TDLS stations on STA CSA
>       iwlwifi: mvm: clean interfaces on drv_stop
>
> Arnd Bergmann (4):
>       mac802154: select CRYPTO when needed
>       be2net: make hwmon interface optional
>       brcmfmac: avoid gcc-5.1 warning
>       net: thunderx: add 64-bit dependency
>
> Arron Wang (2):
>       Bluetooth: Make l2cap_recv_acldata() and sco_recv_scodata() ret=
urn void
>       Bluetooth: Move SCO support under BT_BREDR config option
>
> Ashok Raj Nagarajan (2):
>       ath10k: enable Adaptive Noise Immunity (ANI) by default
>       ath10k: allow user to toggle ani_enable via debugfs
>
> Avinash Patil (14):
>       revert "mwifiex: enable aggregation for TID 6 and 7 streams"
>       mwifiex: reduce severity of debug messages for mgmt rx
>       mwifiex: verbose logging for association failure messages
>       mwifiex: correct bss_type assignment
>       mwifiex: support AP reset after bss_stop
>       mwifiex: enable 11d after bss reset
>       mwifiex: reset 11h active flag when chandef does not require df=
s
>       mwifiex: disable CAC upon radar detection event
>       mwifiex: parse power constraint IE from Tail
>       mwifiex: support downloading IEs from tail
>       mwifiex: drop block-ack action frames
>       mwifiex: advertise PS ON by default support to cfg80211
>       mwifiex: update AP WMM settings from BSS_START event
>       mwifiex: update current config_band info in start_ap
>
> Avraham Stern (4):
>       cfg80211: Allow GO concurrent relaxation after BSS disconnectio=
n
>       iwlwifi: mvm: print scanned channel list on scan iteration comp=
lete notification
>       iwlwifi: mvm: add UMAC scan iteration complete notification
>       iwlwifi: mvm: add support for 8 level scan priority API
>
> Avri Altman (2):
>       iwlwifi: pcie: Remove redundant check for family type
>       iwlwifi: pcie: Control access to the NIC's PM registers via iwl=
_cfg
>
> Bartosz Markowski (2):
>       ath10k: update MODULE_FIRMWARE definitions for QCA6174
>       ath10k: fix PMF by using AES-CMAC/IGTK software crypto
>
> Bernhard Thaler (8):
>       bridge: change BR_GROUPFWD_RESTRICTED to allow forwarding of LL=
DP frames
>       netfilter: bridge: refactor clearing BRNF_NF_BRIDGE_PREROUTING
>       netfilter: bridge: re-order br_nf_pre_routing_finish_ipv6()
>       netfilter: bridge: detect NAT66 correctly and change MAC addres=
s
>       netfilter: bridge: refactor frag_max_size
>       netfilter: bridge: rename br_parse_ip_options
>       netfilter: bridge: re-order check_hbh_len()
>       netfilter: bridge: forward IPv6 fragmented packets
>
> Bert Vermeulen (1):
>       mdio-gpio: Propagate mii_bus.phy_ignore_ta_mask
>
> Bob Copeland (1):
>       mac80211: introduce plink lock for plink fields
>
> Brenden Blanco (1):
>       samples/bpf: fix in-source build of samples with clang
>
> Brent Taylor (1):
>       ath6kl: Fix multiple clients associating in AP mode
>
> Brian Haley (1):
>       cls_flower: Fix compile error
>
> Carlo Caione (1):
>       Bluetooth: btrtl: Create separate module for Realtek BT driver
>
> Carol L Soto (1):
>       net/mlx4_core: double free of dev_vfs
>
> Carol Soto (2):
>       net/mlx4_core: need to call close fw if alloc icm is called twi=
ce
>       net/mlx4_core: fix typo in mlx4_set_vf_mac
>
> Catherine Sullivan (1):
>       i40e: Bump version to 1.3.4
>
> Cathy Luo (1):
>       mwifiex: reduce spinlock usage in main process
>
> Chan-yeol Park (2):
>       Bluetooth: btusb: Support QCA61x4 ROME v2.0
>       Bluetooth: hci_uart: Fix dereferencing of ERR_PTR
>
> Chaya Rachel Ivgi (2):
>       mac80211: fix ignored HT/VHT override configs
>       iwlwifi: mvm: make thermal throttling values configurable per N=
IC family
>
> Chin-ran Lo (1):
>       mwifiex: add support for FW memory read/write operations
>
> Christoffer Holmstedt (1):
>       nl802154: fix misspelled enum
>
> Christoph Paasch (1):
>       tcp: Do not call tcp_fastopen_reset_cipher from interrupt conte=
xt
>
> Christophe Ricard (14):
>       NFC: nci: Add NCI_RESET return code check before setup
>       NFC: nci: Add nci init ops for early device initialization
>       NFC: nci: Add nci_prop_cmd allowing to send proprietary nci cmd
>       NFC: st21nfcb: Do not remove header once the payload is sent
>       NFC: st21nfcb: remove st21nfcb_nci_i2c_disable
>       NFC: st21nfcb: Add ndlc_close in st21nfcb_nci_remove
>       NFC: st21nfcb: Fix st21nfcb_nci_close
>       NFC: st21nfcb: Add support for nci proprietary commands
>       NFC: nci: Move close ops call in nci_close_device
>       NFC: st21nfcb: Move st21nfcb_nci_remove in ndlc_remove
>       NFC: st21nfcb: Move powered flag from phy to ndlc layer
>       NFC: st21nfcb: disable irq when st21nfcb is disabled
>       NFC: st21nfcb: Configure CLF with NCI proprietary command
>       nfc: st-nci: Rename st21nfcb to st-nci
>
> Chun-Yeow Yeoh (3):
>       cfg80211: allow the plink state blocking for user managed mesh
>       mac80211: fix the beacon csa counter for mesh and ibss
>       ath9k_htc: add support of channel switch
>
> Chunfan Chen (1):
>       mwifiex: handle BT coex event to adjust Rx BA window size
>
> Claudiu Manoil (2):
>       gianfar: Move TxFIFO underrun handling to reset path
>       gianfar: Enable changing mac addr when if up
>
> Colin Ian King (1):
>       fddi: print an address with %p format specifier rather than %x
>
> Craig Gallek (4):
>       sock_diag: define destruction multicast groups
>       sock_diag: specify info_size per inet protocol
>       sock_diag: implement a get_info handler for inet
>       sock_diag: fetch source port from inet_sock
>
> Cyrille Pitchen (1):
>       net/macb: add config for Atmel sama5d2 SoCs
>
> Dan Carpenter (5):
>       brcmfmac: cleanup a sizeof()
>       net: macb: OR vs AND typos
>       ath9k_htc: memory corruption calling set_bit()
>       rndis_wlan: harmless issue calling set_bit()
>       net/mlx5_core: fix an error code
>
> Dan Murphy (2):
>       net: phy: dp83867: Add TI dp83867 phy
>       net: phy: dp83867: Fix device tree entries
>
> Daniel Borkmann (13):
>       test_bpf: indicate whether bpf prog got jited in test suite
>       net: filter: add __GFP_NOWARN flag for larger kmem allocs
>       seccomp, filter: add and use bpf_prog_create_from_user from sec=
comp
>       net: sched: consolidate handle_ing and ing_filter
>       net: sched: further simplify handle_ing
>       net: sched: fix typo in net_device ifdef
>       test_bpf: add tests related to BPF_MAXINSNS
>       tcp: add rfc3168, section 6.1.1.1. fallback
>       net: dev: reduce both ingress hook ifdefs
>       test_bpf: add more eBPF jump torture cases
>       test_bpf: add similarly conflicting jump test case only for cla=
ssic
>       ebpf: allow bpf_ktime_get_ns_proto also for networking
>       ebpf: misc core cleanup
>
> Daniel Drake (2):
>       Bluetooth: btusb: fix Realtek suspend/resume
>       rtlwifi: btcoexist: Fix interference between rtl8723be and Blue=
tooth
>
> Daniel Pieczko (17):
>       sfc: Move and rename efx_vf struct to siena_vf
>       sfc: Record [rt]x_dpcpu_fw_id in EF10 nic_data
>       sfc: record the PF's vport ID in nic_data
>       sfc: create VEB vswitch and vport above default firmware setup
>       sfc: get the PF number and record in nic_data
>       sfc: Enable a VF to get its own MAC address
>       sfc: add "port_" prefix to MAC stats
>       sfc: set the port-id when calling MC_CMD_MAC_STATS
>       sfc: display vadaptor statistics for all interfaces
>       sfc: DMA the VF stats only when requested
>       sfc: update netdevice statistics to use vadaptor stats
>       sfc: suppress ENOENT error messages from MC_CMD_MAC_STATS
>       sfc: suppress vadaptor stats when EVB is not present
>       sfc: don't update stats on VF when called in atomic context
>       sfc: do not allow VFs to be destroyed if assigned to guests
>       sfc: force removal of VF and vport on driver removal
>       sfc: leak vports if a VF is assigned during PF unload
>
> Daniel Wagner (1):
>       bpf: BPF based latency tracing
>
> David Herrmann (1):
>       netlink: add API to retrieve all group memberships
>
> David Jander (1):
>       can: flexcan: add MB/FIFO specific column to comment table of I=
P versions
>
> David Malcolm (1):
>       drivers/net/ethernet/dec/tulip/uli526x.c: fix misleading indent=
ation in uli526x_timer
>
> David S. Miller (131):
>       Merge branch 'xgene-next'
>       Merge branch 'rt6_pmtu'
>       Merge git://git.kernel.org/.../davem/net
>       Merge branch 'eth_type_trans'
>       Merge branch 'rhashtable-test'
>       Merge branch 'tcp_sack_rttm'
>       Merge branch 'flow_keys_digest'
>       Merge branch 'via-rhine-rework'
>       Merge branch 'igmp_mld_export'
>       Merge branch 'tipc-topology-cleanup'
>       Merge branch 'master' of git://git.kernel.org/.../jkirsher/next=
-queue
>       Merge branch 'eth_proto_is_802_3'
>       Merge branch 'ipvlan-mcast'
>       Merge branch 'cxgb4-next'
>       Merge branch 'dsa-next'
>       Merge branch 'sfc-next'
>       Merge branch 'be2net'
>       Merge branch 'tcp-more-reliable-window-probes'
>       Merge tag 'mac80211-next-for-davem-2015-05-06' of git://git.ker=
nel.org/.../jberg/mac80211-next
>       Merge branch 'bpf_seccomp'
>       Merge tag 'linux-can-next-for-4.2-20150506' of git://git.kernel=
=2Eorg/.../mkl/linux-can-next
>       Merge branch 'netns-scalability'
>       Merge branch 'pktgen-next'
>       Merge branch 'kernel_socket_netns'
>       Merge branch 'bonding_netlink_lacp'
>       Merge branch 'handle_ing_lightweight'
>       Merge branch 'netdev_page_frags'
>       Merge branch 'switchdev_spring_cleanup'
>       Merge branch 'systemport-irq-coalesce'
>       Merge branch 'switchdev-cleanups'
>       Merge git://git.kernel.org/.../davem/net
>       Merge branch 'sfc-next'
>       Merge branch 'cls_flower'
>       Merge branch 'packet_rollover'
>       Merge branch 'geneve_tunnel_driver'
>       Merge branch 'nf-ingress'
>       Merge branch 'be2net-next'
>       Merge branch 'tipc-next'
>       Merge branch 'phy_turn_around'
>       Merge branch 'stmmac-platform-glue'
>       Merge branch 'amd-xgbe-next'
>       Merge branch 'tcp_mem_pressure'
>       Merge branch 'qeth-next'
>       Merge git://git.kernel.org/.../pablo/nf-next
>       Merge branch 'icmp_frag'
>       Merge tag 'mac80211-next-for-davem-2015-05-19' of git://git.ker=
nel.org/.../jberg/mac80211-next
>       Merge branch 'cxgb4-next'
>       Merge branch 'ebpf-tail-call'
>       Merge branch 'rocker-transaction-fixes'
>       Merge branch 'sfc-next'
>       Merge branch 'cxgb4-next'
>       Merge branch 'tcp_src_port_selection'
>       Merge branch 'stmmac-probe-refactoring'
>       Merge branch 'pktgen-new-scripts'
>       Merge git://git.kernel.org/.../davem/net
>       Merge branch 'mlx4-next'
>       Merge tag 'wireless-drivers-next-for-davem-2015-05-21' of git:/=
/git.kernel.org/.../kvalo/wireless-drivers-next
>       Merge branch 'af_unix_sendpage'
>       Merge branch 'amd-xgbe-next'
>       Merge branch 'ipv6_route_sharing'
>       Merge branch 'rocker-cleanups'
>       Merge branch 'cpsw-cleanups'
>       ipv4: Fix fib_trie.c build, missing linux/vmalloc.h include.
>       Merge branch 'phy_rgmii'
>       Merge branch 'ip_frag_next'
>       Merge branch 'sfc-next'
>       Merge branch 'thunderx'
>       Merge branch 'cxgb4-next'
>       treewide: Add missing vmalloc.h inclusion.
>       Merge branch 'master' of git://git.kernel.org/.../klassert/ipse=
c-next
>       Merge branch 'stmmac-IPQ806x'
>       Merge branch 'master' of git://git.kernel.org/.../jkirsher/next=
-queue
>       Merge branch 'mlx5-next'
>       Merge branch 'for-upstream' of git://git.kernel.org/.../bluetoo=
th/bluetooth-next
>       Merge branch 'mlx4-next'
>       Merge branch 'systemport-next'
>       Merge git://git.kernel.org/.../pablo/nf-next
>       Merge branch 'hv_netvsc-next'
>       Merge tag 'batman-adv-for-davem' of git://git.open-mesh.org/lin=
ux-merge
>       Merge tag 'mac80211-next-for-davem-2015-05-29' of git://git.ker=
nel.org/.../jberg/mac80211-next
>       Merge branch 'rds-next'
>       net: Add priority to packet_offload objects.
>       Merge branch 'rocker-next'
>       Merge branch 'cxgb4-next'
>       Merge git://git.kernel.org/.../davem/net
>       Merge branch 'thunderx-next'
>       Merge branch 'sfc-next'
>       Merge branch 'master' of git://git.kernel.org/.../jkirsher/next=
-queue
>       Merge tag 'batman-adv-for-davem' of git://git.open-mesh.org/lin=
ux-merge
>       Merge branch 'cxgb4-next'
>       Merge tag 'wireless-drivers-next-for-davem-2015-06-03' of git:/=
/git.kernel.org/.../kvalo/wireless-drivers-next
>       Merge branch 'switchdev-next'
>       Merge branch 'flow_key_hashing'
>       Merge branch 'mlx5-next'
>       Merge branch 'cxgb4-next'
>       Merge branch 'phy-micrel'
>       Merge git://git.kernel.org/.../davem/net
>       Merge tag 'batman-adv-for-davem' of git://git.open-mesh.org/lin=
ux-merge
>       Merge tag 'linux-can-next-for-4.2-20150609' of git://git.kernel=
=2Eorg/.../mkl/linux-can-next
>       Merge branch 'cxgb4-next'
>       Merge branch 'master' of git://git.kernel.org/.../jkirsher/next=
-queue
>       Merge tag 'mac80211-next-for-davem-2015-06-10' of git://git.ker=
nel.org/.../jberg/mac80211-next
>       Merge branch 'brcm-pseudo-phy-addr'
>       Merge branch 'broadcom-MDIO-turn-around'
>       Merge branch 'mlx5-next'
>       Merge branch 'bna-next'
>       Merge branch 'tcp-gso-settings-defer'
>       Merge branch 'flow_dissector-next'
>       Merge git://git.kernel.org/.../davem/net
>       Merge git://git.kernel.org/.../pablo/nf-next
>       Merge branch 'bpf-share-helpers'
>       Merge branch 'rocker-no-wait'
>       Merge branch 'bond-netlink-3ad-attrs'
>       Merge tag 'nfc-next-4.2-1' of git://git.kernel.org/.../sameo/nf=
c-next
>       Merge branch 'mlx4-vf-counters'
>       Merge branch 'sock_diag_destruction_events'
>       Merge branch 'master' of git://git.kernel.org/.../jkirsher/next=
-queue
>       Merge git://git.kernel.org/.../pablo/nf-next
>       Merge branch 'bna-cleanups'
>       Merge tag 'wireless-drivers-next-for-davem-2015-06-18' of git:/=
/git.kernel.org/.../kvalo/wireless-drivers-next
>       Merge branch 'macb-sama5d2'
>       Merge branch 'for-upstream' of git://git.kernel.org/.../bluetoo=
th/bluetooth-next
>       Merge tag 'nfc-next-4.2-2' of git://git.kernel.org/.../sameo/nf=
c-next
>       Merge branch 'dsa-mv88e6xxx-debugfs'
>       Merge tag 'linux-can-fixes-for-4.1-20150621' of git://git.kerne=
l.org/.../mkl/linux-can
>       Merge branch 'stmmac-rk3368'
>       Merge branch 'switchdev-vlan'
>       Merge branch 'xgene-next'
>       Merge branch 'mlx-next'
>       Merge branch 'ipv4-nexthop-link-status'
>       Merge git://git.kernel.org/.../davem/net
>
> David Spinadel (4):
>       iwlwifi: mvm: remove deprecated command IDs
>       iwlwifi: mvm: include wildcard SSID in scans
>       iwlwifi: mvm: add inactive state to ebs status
>       iwlwifi: mvm: don't use EBS for P2P find
>
> David Ward (1):
>       net_sched: gred: add TCA_GRED_LIMIT attribute
>
> Denys Vlasenko (2):
>       net: deinline netif_tx_stop_all_queues(), remove WARN_ON in net=
if_tx_stop_queue()
>       netfilter: ipset: deinline ip_set_put_extensions()
>
> Dmitry Torokhov (1):
>       mwifiex: do not return success when command times out
>
> Dmitry Tunin (3):
>       ath3k: Add support of 0489:e076 AR3012 device
>       ath3k: add support of 13d3:3474 AR3012 device
>       Bluetooth: ath3k: Add support of 04ca:300d AR3012 device
>
> Don Skidmore (18):
>       ixgbe: add array of MAC type dependent values
>       ixgbe: add support for WoL and autoneg FC for some X550 devices
>       ixgbe: add define for X557 PHY ID
>       ixgbe: Add a PHY power state method
>       ixgbe: Restore ESDP settings after MAC reset
>       ixgbe: add X550 support for external PHY and forced 1G/10G supp=
ort
>       ixgbe: Add reset for X550 device
>       ixgbe: Add const string for overheat message
>       ixgbe: add support for interrupts from X550 external PHY
>       ixgbe: fix issue with sfp events with new X550 devices
>       ixgbe: fix bug in not clearing counters for X550 devices
>       ixgbe: fix X550 devices init flow
>       ixgbe: fix X550 PHY function pointers
>       ixgbe: Add support for another X550 device.
>       ixgbe: add link check for X550 copper
>       ixgbe: Set lan_id before using I2C
>       ixgbe: fix X550 default set_phy_power method
>       ixgbe: Remember to write ixfi changes after modifying
>
> Edward Cree (10):
>       sfc: Cope with permissions enforcement added to firmware for SR=
-IOV
>       sfc: nicer log message on PTP probe fail
>       sfc: suppress some MCDI error messages in PTP
>       sfc: nicer log message on Siena SR-IOV probe fail
>       sfc: protect filter table against use-after-free
>       sfc: add ndo_set_vf_link_state() function for EF10
>       sfc: add tracing of MCDI commands
>       sfc: add sysfs entry to control MCDI tracing
>       sfc: add module parameter to enable MCDI logging on new functio=
ns
>       sfc: mark state UNINIT after unregister
>
> Eliad Peller (5):
>       iwlwifi: mvm: avoid use-after-free on iwl_mvm_d0i3_enable_tx() =
[BUGFIX]
>       wl18xx: fallback to default conf in case of invalid conf file
>       iwlwifi: mvm: fix ROC reference accounting
>       iwlwifi: tracing: add rx cmd header fields
>       iwlwifi: pcie: re-enable interrupts on resume
>
> Emmanuel Grumbach (16):
>       iwlwifi: dvm: don't sleep in event_callback callback
>       mac80211: notify the driver upon BAR Rx
>       mac80211: notify the driver on reordering buffer timeout
>       Merge remote-tracking branch 'iwlwifi-fixes/master' into iwlwif=
i-next
>       iwlwifi: mvm: allow scheduled scan for all the firmwares
>       iwlwifi: clarify the device / firmware mapping in Kconfig
>       iwlwifi: allow to limit the size of the external buffer for fir=
mware debugging
>       Merge remote-tracking branch 'iwlwifi-fixes/master' into iwlwif=
i-next
>       iwlwifi: bump API to 14
>       iwlwifi: pcie: simplify return value
>       iwlwifi: mvm: BT Coex - remove useless code
>       iwlwifi: mvm: BT Coex - allocate a short command on the stack
>       iwlwifi: mvm: BT Coex - fix shared antenna check with new API
>       Merge tag 'mac80211-next-for-davem-2015-05-06' into iwlwifi-nex=
t
>       iwlwifi: mvm: implement the BlockAck related debug triggers
>       iwlwifi: bump the iwlmvm API number to 15
It is time to update
https://wireless.wiki.kernel.org/en/users/drivers/iwlwifi#firmware

Thanks

>
> Eran Ben Elisha (15):
>       net/mlx4_core: Check before cleaning counters bitmap
>       net/mlx4_core: Reset counters data when freed
>       net/mlx4_core: Add sink counter
>       net/mlx4_core: Remove counters table allocation from VF flow
>       net/mlx4_core: Adjust counter grant policy in the resource trac=
ker
>       net/mlx4_core: Add port attribute when tracking counters
>       net/mlx4_core: Allocate default counter per port
>       IB/mlx4: Add RoCE/IB dedicated counters
>       IB/mlx4: Set VF to read from QP counters
>       net/mlx4_core: Add helper to query counters
>       net/mlx4_en: Show PF own statistics via ethtool
>       net/core: Add reading VF statistics through the PF netdevice
>       net/mlx4_en: Support ndo_get_vf_stats
>       net/mlx4_en: Fix off-by-four in ethtool
>       net/mlx4_en: Use HW counters for rx/tx bytes/packets in PF devi=
ce
>
> Eran Harary (1):
>       iwlwifi: 8000: fallback to default NVM file
>
> Eric B Munson (1):
>       tcp: Return error instead of partial read for saved syn headers
>
> Eric Dumazet (49):
>       tcp_westwood: fix tcp_westwood_info()
>       ipv4: speedup ip_idents_reserve()
>       tcp: provide SYN headers for passive connections
>       tcp: adjust window probe timers to safer values
>       tcp: add TCPWinProbe and TCPKeepAlive SNMP counters
>       codel: add ce_threshold attribute
>       net: sched: deprecate enqueue_root()
>       tcp/dccp: tw_timer_handler() is static
>       ipv4: __ip_local_out_sk() is static
>       tcp: syncookies: extend validity range
>       net: fix sparse error in csum_replace4()
>       ipip: fix one sparse error
>       netfilter: synproxy: fix sparse errors
>       net: fix two sparse errors
>       net: fix sk_mem_reclaim_partial()
>       tcp: rename sk_forced_wmem_schedule() to sk_forced_mem_schedule=
()
>       tcp: introduce tcp_under_memory_pressure()
>       tcp: fix behavior for epoll edge trigger
>       tcp: allow one skb to be received per socket under memory press=
ure
>       tcp: halves tcp_mem[] limits
>       tcp: add a force_schedule argument to sk_stream_alloc_skb()
>       inet_hashinfo: remove bsocket counter
>       tcp: improve REUSEADDR/NOREUSEADDR cohabitation
>       ipv6: ipv6_select_ident() returns a __be32
>       pktgen: remove one sparse error
>       net: remove a sparse error in secure_dccpv6_sequence_number()
>       net: fix inet_proto_csum_replace4() sparse errors
>       tcp: fix/cleanup inet_ehash_locks_alloc()
>       tcp: tcp_tso_autosize() minimum is one packet
>       tcp/dccp: try to not exhaust ip_local_port_range in connect()
>       qla4xxx: add a missing include
>       tcp: connect() from bound sockets can be faster
>       tcp/dccp: warn user for preferred ip_local_port_range
>       tcp: remove redundant checks
>       inet: add IP_BIND_ADDRESS_NO_PORT to overcome bind(0) limitatio=
ns
>       tcp: remove redundant checks II
>       tcp: get_cookie_sock() consolidation
>       net: tcp: dctcp_update_alpha() fixes.
>       tcp: reserve tcp_skb_mss() to tcp stack
>       tcp: fill shinfo->gso_type at last moment
>       tcp: tcp_set_skb_tso_segs() no longer need struct sock paramete=
r
>       tcp: fill shinfo->gso_size at last moment
>       tcp: remove obsolete check in tcp_set_skb_tso_segs()
>       flow_dissector: fix ipv6 dst, hop-by-hop and routing ext hdrs
>       tcp: tcp_v6_connect() cleanup
>       netfilter: x_tables: remove XT_TABLE_INFO_SZ and a dereference.
>       net: make u64_stats_init() a function
>       netfilter: x_tables: align per cpu xt_counter
>       packet: read num_members once in packet_rcv_fanout()
>
> Eric W Biederman (1):
>       netfilter: Remove spurios included of netfilter.h
>
> Eric W. Biederman (10):
>       tun: Utilize the normal socket network namespace refcounting.
>       net: Add a struct net parameter to sock_create_kern
>       net: Pass kern from net_proto_family.create to sk_alloc
>       net: Modify sk_alloc to not reference count the netns of kernel=
 sockets.
>       netlink: Create kernel netlink sockets in the proper network na=
mespace
>       net: kill sk_change_net and sk_release_kernel
>       netfilter: Kill unused copies of RCV_SKB_FAIL
>       net: sched: Simplify em_ipset_match
>       netfilter: nftables: Do not run chains in the wrong network nam=
espace
>       netfilter: nf_qeueue: Drop queue entries on nf_unregister_hook
>
> Erik Kline (1):
>       neigh: Better handling of transition to NUD_PROBE state
>
> Eugene Crosser (6):
>       qeth: fix handling of IPA return codes
>       qeth: remove locks from sysfs _show
>       qeth: IFF_PROMISC flag to BRIDGE PORT mode
>       qeth: OSA version of SETBRIDGEPORT command
>       qeth: BRIDGEPORT "sanity check"
>       qeth: replace ENOSYS with EOPNOTSUPP
>
> Eyal Reizer (1):
>       wl18xx: wlan_irq: support platform dependent interrupt types
>
> Eyal Shapira (2):
>       iwlwifi: rs: cleanup last_txrate_idx
>       iwlwifi: mvm: rs: pass rate directly to column checks
>
> Fabian Frederick (6):
>       net/mlx4: use swap() in mlx4_init_qp_table()
>       net/mlx4_core: use swap() in mlx4_make_profile()
>       net/ibm/emac: use swap() in emac_make_bootlist()
>       net: fs_enet: use swap() in fs_enet_rx_napi()
>       vxge: use swap() in vxge_hw_channel_dtr_alloc()
>       net: rds: use for_each_sg() for scatterlist parsing
>
> Felix Fietkau (3):
>       bcma: use absolute base for SoC GPIO pins
>       bcma: enable 32 GPIO pins for BCM4707
>       ath9k: fix DMA stop sequence for AR9003+
>
> Firo Yang (2):
>       fib_trie: coding style: Use pointer after check
>       NFC: st21nfcb: Remove inappropriate kfree on a devm_kzalloc poi=
nter
>
> Florian Fainelli (21):
>       net: systemport: Implement TX coalescing control knobs
>       net: systemport: Implement RX coalescing control knobs
>       net: phy: Add phy_ignore_ta_mask to account for broken turn-aro=
und
>       of: mdio: Add a "broken-turn-around" property
>       net: phy: mdio-gpio: Handle phy_ignore_ta_mask
>       net: phy: Add state machine state transitions debug prints
>       net: dsa: bcm_sf2: properly propagate carrier down state for Mo=
CA
>       net: phy: Add phy_interface_is_rgmii helper
>       net: phy: Utilize phy_interface_is_rgmii
>       net: systemport: Pre-calculate and utilize cb->bd_addr
>       net: systemport: rewrite bcm_sysport_rx_refill
>       net: systemport: Add a check for oversized packets
>       net: bcmgenet: improve TX timeout
>       net: phy: bcm7xxx: update workaround to fix 100BaseT corner cas=
es
>       net: phy: broadcom: include phy.h for brcmphy.h
>       net: phy: broadcom: define Broadcom pseudo-PHY address in brcmp=
hy.h
>       b44: Utilize BRCM_PSEUDO_PHY_ADDR
>       bgmac: Utilize BRCM_PSEUDO_PHY_ADDR
>       net: dsa: bcm_sf2: Utilize BRCM_PSEUDO_PHY_ADDR
>       net: bcmgenet: handle broken turn-around for specific PHYs
>       net: phy: mdio-bcm-unimac: handle broken turn-around for specif=
ic PHYs
>
> Florian Grandel (21):
>       Bluetooth: mgmt: fix typos
>       Bluetooth: hci_core/mgmt: Introduce multi-adv list
>       Bluetooth: hci_core/mgmt: move adv timeout to hdev
>       Bluetooth: mgmt: dry update_scan_rsp_data()
>       Bluetooth: mgmt: rename update_*_data_for_instance()
>       Bluetooth: mgmt: multi adv for read_adv_features()
>       Bluetooth: mgmt: multi adv for get_current_adv_instance()
>       Bluetooth: mgmt: multi adv for get_adv_instance_flags()
>       Bluetooth: mgmt: improve get_adv_instance_flags() readability
>       Bluetooth: mgmt: multi adv for enable_advertising()
>       Bluetooth: mgmt: multi adv for create_instance_scan_rsp_data()
>       Bluetooth: mgmt: multi adv for create_instance_adv_data()
>       Bluetooth: mgmt: multi adv for set_advertising*()
>       Bluetooth: mgmt: multi adv for clear_adv_instances()
>       Bluetooth: mgmt/hci_core: multi-adv for add_advertising*()
>       Bluetooth: mgmt: multi adv for remove_advertising*()
>       Bluetooth: mgmt: program multi-adv on power on
>       Bluetooth: mgmt: multi-adv for trigger_le_scan()
>       Bluetooth: mgmt: multi-adv for mgmt_reenable_advertising()
>       Bluetooth: hci_core: remove obsolete adv_instance
>       Bluetooth: hci_core: increase max adv inst
>
> Florian Westphal (18):
>       net: sched: remove TC_MUNGED bits
>       net: sched: use counter to break reclassify loops
>       netfilter: bridge: neigh_head and physoutdev can't be used at s=
ame time
>       netfilter: bridge: free nf_bridge info on xmit
>       net: core: set qdisc pkt len before tc_classify
>       ipv6: reject locally assigned nexthop addresses
>       net: sched: pkt_cls: remove unused macros from uapi
>       ip: reject too-big defragmented DF-skb when forwarding
>       ipv6: don't increase size when refragmenting forwarded ipv6 skb=
s
>       netfilter: remove unused comefrom hookmask argument
>       net: ipv4: avoid repeated calls to ip_skb_dst_mtu helper
>       ip_fragment: don't forward defragmented DF packet
>       net: ip_fragment: remove BRIDGE_NETFILTER mtu special handling
>       netfilter: bridge: restore vlan tag when refragmenting
>       netfilter: xtables: use percpu rule counters
>       netfilter: xtables: avoid percpu ruleset duplication
>       net: ipv4: un-inline ip_finish_output2
>       netfilter: xtables: fix warnings on 32bit platforms
>
> Franky Lin (3):
>       brcmfmac: remove pci shared structure rev4 support
>       brcmfmac: remove dummy cache flush/invalidate function
>       brcmfmac: add support for dma indices feature
>
> Frederic Danis (11):
>       Bluetooth: Fix calls to __hci_cmd_sync()
>       Bluetooth: btusb: Fix calls to __hci_cmd_sync()
>       Bluetooth: btintel: Fix calls to __hci_cmd_sync()
>       Bluetooth: btbcm: Fix calls to __hci_cmd_sync()
>       Bluetooth: btbcm: Move request/release_firmware()
>       Bluetooth: btbcm: Add BCM4324B3 UART device
>       Bluetooth: hci_uart: Support operational speed during setup
>       Bluetooth: btbcm: Add helper functions for UART setup
>       Bluetooth: hci_uart: Update Broadcom UART setup
>       Bluetooth: hci_uart: Add bcm_set_baudrate()
>       Bluetooth: hci_uart: Fix speed selection
>
> Fu, Zhonghui (1):
>       brcmfmac: prohibit ACPI power management for brcmfmac driver
>
> Fugang Duan (1):
>       net: fec: ptp: correct the ENET_ATCOR value
>
> Gabriel Krisman Bertazi (1):
>       bnx2x: Alloc 4k fragment for each rx ring buffer element
>
> Gal Pressman (1):
>       net/mlx5e: Enforce max flow-tables level >=3D 3
>
> Geert Uytterhoeven (1):
>       enic: Grammar s/an negative/a negative/
>
> Geoff Levand (1):
>       net/ps3_gelic: Fix build error with DEBUG
>
> Gilad Ben-Yossef (1):
>       rocker: call correct unregister function on error
>
> Glenn Ruben Bakke (5):
>       Bluetooth: 6lowpan: Enable delete_netdev to be scheduled when l=
ast peer is deleted
>       Bluetooth: 6lowpan: Rename ambiguous variable
>       Bluetooth: 6lowpan: Move netdev sysfs device reference
>       Bluetooth: 6lowpan: Fix double kfree of netdev priv
>       Bluetooth: 6lowpan: Fix module refcount
>
> Greg Rose (2):
>       i40e: Disable offline diagnostics if VFs are enabled
>       i40e/i40evf: Remove unneeded TODO
>
> Gustavo Zacarias (1):
>       net: phy: davicom: add IDs for DM9161B and C variants
>
> Hadar Hen Zion (1):
>       net/ethtool: Add current supported tunable options
>
> Haggai Abramonvsky (4):
>       net/mlx5_core: Apply proper name convention to helpers
>       net/mlx5_core: Enable XRCs and SRQs when using ISSI > 0
>       net/mlx5_core: Check the return bitmask when querying ISSI
>       mlx5: Enable mutual support for IB and Ethernet
>
> Hamad Kadmany (1):
>       wil6210: Support hidden SSID
>
> Hannes Frederic Sowa (4):
>       net: skbuff: add skb_append_pagefrags and use it
>       net: af_unix: implement stream sendpage support
>       net: make skb_splice_bits more configureable
>       net: af_unix: implement splice for stream af_unix sockets
>
> Hans Ulli Kroll (1):
>       rtlwifi: fix tm_trigger usage
>
> Hante Meuleman (4):
>       brcmfmac: add additional 43602 pcie device id.
>       brcmfmac: Add support for multiple PCIE devices in nvram.
>       brcmfmac: Improve throughput by scheduling msbug flow worker.
>       brcmfmac: Update msgbuf read pointer quicker.
>
> Harini Katakam (4):
>       devicetree: Add compatible string for Zynq Ultrascale+ MPSoC
>       net: macb: Add compatible string for Zynq Ultrascale+ MPSoC
>       net: macb: Add support for jumbo frames
>       net: macb: Add change_mtu callback with jumbo support
>
> Hariprasad Shenai (34):
>       cxgb4: Make sure that Freelist size is larger than Egress Conge=
stion Threshold
>       cxgb4: Enable congestion notification from SGE for IQs and FLs.
>       cxgb4: Pass in a Congestion Channel Map to t4_sge_alloc_rxq()
>       cxgb4: Add device node to ULD info
>       cxgb4: Move SGE Ingress DMA state monitor code to a new routine
>       cxgb4: Discard the packet if the length is greater than mtu
>       cxgb4: Initialize RSS mode for all Ports
>       cxgb4/cxgb4vf: Cleanup macros, add comments and add new MACROS
>       cxgb4: Remove dead function t4_read_edc and t4_read_mc
>       cxgb4: replace ntoh{s, l} and hton{s, l} calls with the generic=
 byteorder
>       cxgb4: Optimize and cleanup setup memory window code
>       cxgb4: Update T4/T5 adapter register ranges
>       cxgb4: Add PHY firmware support for T420-BT cards
>       cxgb4: Add debugfs facility to inject FL starvation
>       cxgb4/cxgb4vf: function and argument name cleanup
>       cxgb4: remove unused fn to enable/disable db coalescing
>       cxgb4: Add is_t6 macro and T6 register ranges
>       cxgb4: Adds support for T6 adapter
>       cxgb4vf: Adds SRIOV driver changes for T6 adapter
>       cxgb4: Add ethtool support to get adapter stats
>       cxgb4: Add support in ethtool to dump channel stats
>       cxgb4: Add support to dump loopback port stats
>       cxgb4: Remove WOL get/set ethtool support
>       cxgb4: Free Virtual Interfaces in remove routine
>       cxgb4: Add sge ec context flush service
>       cxgb4: Rename t4_link_start() to t4_link_l1cfg
>       cxgb4: Set mac addr from vpd, when we can't contact firmware
>       cxgb4: program pci completion timeout
>       cxgb4: Use FW LDST cmd to access TP_PIO_{ADDR, DATA} register f=
irst
>       cxgb4: Fix static checker warning
>       cxgb4: Add a debugfs entry to dump CIM MA logic analyzer logs
>       cxgb4: Add debugfs entry to dump CIM PIF logic analyzer content=
s
>       cxgb4: Add debugfs entry to dump channel rate
>       cxgb4: Add PCI device ID for custom T522 & T520 adapter
>
> Harout Hedeshian (1):
>       netfilter: xt_socket: add XT_SOCKET_RESTORESKMARK flag
>
> Hauke Mehrtens (1):
>       bcma: add module_bcma_driver()
>
> Heiko St=C3=BCbner (4):
>       net: stmmac: dwmac-rk: remove unused gpio register defines
>       net: stmmac: dwmac-rk: Fix clk rate when provided by soc
>       net: stmmac: dwmac-rk: abstract access to mac settings in GRF
>       net: stmmac: dwmac-rk: add rk3368-specific data
>
> Herbert Xu (1):
>       netlink: Use random autobind rover
>
> Hiroaki SHIMODA (1):
>       inet_diag: Remove _bh suffix in inet_diag_dump_reqs().
>
> Ido Shamay (1):
>       net/mlx4_core: Move affinity hints to mlx4_core ownership
>
> Ido Yariv (1):
>       iwlwifi: update thermal throttling values for 8000 devices
>
> Ilan Peer (2):
>       mac80211_hwsim: Set VHT capabilities only for the 5.2 GHz band
>       mac80211_hwsim: Fix the supported VHT mcs rates
>
> Ilya Faenson (2):
>       Bluetooth: btbcm: Support the BCM4354 Bluetooth UART device
>       Bluetooth: hci_uart: Add new line discipline enhancements
>
> Ivan Vecera (23):
>       be2net: log link status
>       bna: use ether_addr_copy instead of memcpy
>       bna: get rid of mac_t
>       bna: replace pragma(pack) with attribute __packed
>       bna: get rid of duplicate and unused macros
>       bna: use BIT(x) instead of (1 << x)
>       bna: remove unused cbfn parameter
>       bna: remove pause_cbfn from struct bna_enet
>       bna: remove oper_state_cbfn from struct bna_rxf
>       bna: remove prio_change_cbfn oper_state_cbfn from struct bna_tx
>       bna: remove RXF_E_PAUSE and RXF_E_RESUME events
>       bna: remove paused from bna_rx_config and flags from bna_rxf
>       bna: remove TX_E_PRIO_CHANGE event and BNA_TX_F_PRIO_CHANGED fl=
ag
>       bna: correct comparisons/assignments to bool
>       bna: use memdup_user to copy userspace buffers
>       bna: remove useless pointer assignment
>       bna: get rid of private macros for manipulation with lists
>       bna: use list_for_each_entry where appropriate
>       bna: fix timeout API argument type
>       bna: use netdev_* and dev_* instead of printk and pr_*
>       bna: remove unnecessary cast of BIT value
>       bna: make pointers to read-only inputs const
>       bna: remove superfluous parentheses
>
> Iyappan Subramanian (5):
>       drivers: net: xgene: Change ring manager to use function pointe=
rs
>       drivers: net: xgene: Add ring manager v2 functions
>       drivers: net: xgene: Add 10GbE support with ring manager v2
>       drivers: net: xgene: Add SGMII based 1GbE support with ring man=
ager v2
>       drivers: net: xgene: fix kbuild warnings
>
> Jacob Keller (15):
>       fm10k: ignore invalid multicast address entries
>       fm10k: use correct ethernet driver Tx timestamp function
>       fm10k: move setting shinfo inside ts_tx_enqueue
>       fm10k: fix incorrect free on skb in ts_tx_enqueue
>       fm10k: add call to fm10k_clean_all_rx_rings in fm10k_down
>       fm10k: use an unsigned int for i in ethtool_get_strings
>       fm10k: remove extraneous NULL check on l2_accel
>       fm10k: trivial fixup message style to include a colon
>       fm10k: use dma_set_mask_and_coherent in fm10k_probe
>       fm10k: force LPORT delete when updating VLAN or MAC address
>       fm10k: re-map all possible VF queues after a VFLR
>       fm10k: pack TLV overlay structures
>       fm10k: fix incorrect DIR_NEVATIVE bit in 1588 code
>       fm10k: remove err_no reference in fm10k_mbx.c
>       fm10k: fix iov_msg_lport_state_pf issue
>
> Jaeden Amero (3):
>       net/phy: micrel: Be more const correct
>       net/phy: micrel: Comment MMD address of extended registers
>       net/phy: micrel: Center FLP timing at 16ms
>
> Jaganath Kanakkassery (1):
>       Bluetooth: Fix potential NULL dereference in RFCOMM bind callba=
ck
>
> Jakub Kicinski (7):
>       add mt7601u driver
>       mt7601u: unify paged and non-paged RX dma paths
>       mt7601u: watch out for invalid-length frames
>       mt7601u: don't cleanup device second time after .resume()
>       mt7601u: set promiscous mode based on FIF_OTHER_BSS
>       mac80211: remove obsolete sentence from documentation
>       mt7601u: don't warn about devices without per-rate power table
>
> Jamal Hadi Salim (1):
>       tc: remove unused redirect ttl
>
> Janusz Dziedzic (8):
>       ath10k: add WMI support for WOW
>       ath10k: add WOW disconnect/magic-packet support
>       ath10k: add WMI support for WOW patterns
>       ath10k: add WOW patterns support
>       ath10k: disable burst mode
>       ath10k: enable ibss-rsn
>       ath10k: enable ASPM
>       ath10k: fix idle power consumption
>
> Janusz.Dziedzic@tieto.com (1):
>       ath10k: setup maximum number of supported stations
>
> Jason Baron (2):
>       tcp: set SOCK_NOSPACE under memory pressure
>       tcp: ensure epoll edge trigger wakeup when write queue is empty
>
> Jean Sacren (1):
>       e100: don't initialize int object to zero
>
> Jeff Kirsher (1):
>       e1000e: fix call to do_div() to use u64 arg
>
> Jesper Dangaard Brouer (11):
>       pktgen: adjust flag NO_TIMESTAMP to be more pktgen compliant
>       pktgen: remove obsolete "max_before_softirq" from pktgen doc
>       pktgen: adjust spacing in proc file interface output
>       pktgen: doc were missing several config options
>       pktgen: document ability to add same device to several threads
>       pktgen: make /proc/net/pktgen/pgctrl report fail on invalid inp=
ut
>       pktgen: new pktgen helper functions for samples scripts
>       pktgen: add sample script pktgen_sample01_simple.sh
>       pktgen: add sample script pktgen_sample02_multiqueue.sh
>       pktgen: add sample script pktgen_sample03_burst_single_flow.sh
>       pktgen: add benchmark script pktgen_bench_xmit_mode_netif_recei=
ve.sh
>
> Jesse Brandeburg (3):
>       i40evf: skb->xmit_more support
>       i40e/i40evf: force inline transmit functions
>       i40e/i40evf: remove time_stamp member
>
> Jiri Pirko (19):
>       switchdev: s/netdev_switch_/switchdev_/ and s/NETDEV_SWITCH_/SW=
ITCHDEV_/
>       switchdev: s/swdev_/switchdev_/
>       net: change name of flow_dissector header to match the .c file =
name
>       flow_dissector: remove unused function flow_get_hlen declaratio=
n
>       net: move *skb_get_poff declarations into correct header
>       flow_dissector: fix doc for __skb_get_hash and remove couple of=
 empty lines
>       net: move __skb_get_hash function declaration to flow_dissector=
=2Eh
>       net: move __skb_tx_hash to dev.c
>       net: move netdev_pick_tx and dependencies to net/core/dev.c
>       flow_dissector: fix doc for skb_get_poff
>       flow_dissector: introduce programable flow_dissector
>       flow_dissect: use programable dissector in skb_flow_dissect and=
 friends
>       flow_dissector: add missing header includes
>       flow_dissector: introduce support for ipv6 addressses
>       flow_dissector: introduce support for Ethernet addresses
>       flow_dissector: change port array into src, dst tuple
>       tc: introduce Flower classifier
>       flow_dissector: remove bogus return in tipc section
>       flow_dissector: do not break if ports are not needed in flowlab=
el
>
> Jiri Slaby (1):
>       bna: remove obsolete use of EXTRA_CFLAGS
>
> Joachim Eastwood (15):
>       stmmac: add dwmac glue for NXP 18xx/43xx family
>       doc: dt: add documentation for nxp,lpc1850-dwmac
>       stmmac: prepare stmmac platform to support stand alone drivers
>       stmmac: add a generic dwmac driver
>       stmmac: convert dwmac-lpc18xx to a platform driver
>       stmmac: convert dwmac-meson to platform driver
>       stmmac: convert dwmac-rk to platform driver
>       stmmac: convert dwmac-socfpga to platform driver
>       stmmac: convert dwmac-sti to platform driver
>       stmmac: convert dwmac-sunxi to platform driver
>       stmmac: drop driver from stmmac platform code
>       stmmac: move driver data setting into stmmac_dvr_probe
>       stmmac: let stmmac_dvr_probe take a struct of resources
>       stmmac: change the stmmac_dvr_probe return type to int
>       stmmac: drop unnecessary dt checks in stmmac_probe_config_dt
>
> Joe Perches (5):
>       netfilter: Use correct return for seq_show functions
>       spider_net: Use DECLARE_BITMAP
>       qlge: Move jiffies_to_usecs immediately before loop
>       neterion: s2io: Fix kernel doc formatting
>       NFC: nci: hci: Fix releasing uninitialized skbs
>
> Johan Hedberg (11):
>       Bluetooth: Add debug logs for legacy SMP crypto functions
>       Bluetooth: Fix encryption key size handling for LTKs
>       Bluetooth: Fix exposing full value of shortened LTKs
>       Bluetooth: Add debugfs support for max LE encryption key size
>       Bluetooth: Add debugfs support for min LE encryption key size
>       Bluetooth: Move SC-only check outside of BT_CONFIG branch
>       Bluetooth: Read encryption key size for BR/EDR connections
>       Bluetooth: Use actual encryption key size for SMP over BR/EDR
>       Bluetooth: Remove redundant check for ACL_LINK
>       Bluetooth: Use zalloc when possible
>       Bluetooth: Fix warning of potentially uninitialized adv_instanc=
e variable
>
> Johannes Berg (53):
>       mac80211: lock rate control
>       mac80211: add TX fastpath
>       mac80211_hwsim: enable IEEE80211_HW_SUPPORT_FAST_XMIT
>       mac80211: extend fast-xmit to driver fragmentation
>       mac80211: extend fast-xmit for more ciphers
>       mac80211: extend fast-xmit to cover IBSS
>       wlcore: enable IEEE80211_HW_SUPPORT_FAST_XMIT
>       ath10k: enable IEEE80211_HW_SUPPORT_FAST_XMIT
>       mac80211: allow checksum offload only in fast-xmit
>       mac80211: allow drivers to support S/G
>       mac80211: allow segmentation offloads
>       mac80211: make station hash table max_size configurable
>       mac80211: remove support for IFF_PROMISC
>       mac80211: remove IEEE80211_RX_RA_MATCH
>       mac80211: clean up/rename prepare_for_handlers()
>       mac80211: OCB: remove pointless check for broadcast BSSID
>       mac80211: don't update dev->trans_start
>       mac80211: use per-CPU TX/RX statistics
>       iwlwifi: mvm: don't reset key index on HW restart
>       mac80211: clean up global debugfs statistics
>       mac80211: move dot11 counters under MAC80211_DEBUG_COUNTERS
>       mac80211: remove sta->tx_fragments counter
>       mac80211: clean up station debugfs
>       mac80211: make LED trigger names const
>       mac80211: make LED triggering depend on activation
>       mac80211: remove useless skb->encapsulation check
>       mac80211: extend get_tkip_seq to all keys
>       mac80211: extend get_key() to return PN for all ciphers
>       mac80211: validate cipher scheme PN length better
>       mac80211: add missing documentation for rate_ctrl_lock
>       mac80211: check fast-xmit if IBSS STA QoS changed
>       mac80211: fix throughput LED trigger
>       mac80211: fix memory leak
>       mac80211: add missing drv_priv description for TXQ struct
>       cfg80211: properly send NL80211_ATTR_DISCONNECTED_BY_AP in disc=
onnect
>       iwlwifi: refactor common transport alloc/init code
>       iwlwifi: mvm: advertise randomised netdetect MAC address
>       iwlwifi: mvm: handle device start failure correctly
>       mac80211: act upon and report deauth while associating
>       mac80211: move TX PN to public part of key struct
>       mac80211: copy nl80211 mgmt TX SKB for status
>       mac80211: stop using pointers as userspace cookies
>       mac80211: remove short slot/short preamble incapable flags
>       mac80211: rename single hw-scan flag to follow naming conventio=
n
>       iwlwifi: mvm: enable IEEE80211_HW_SUPPORT_FAST_XMIT
>       iwlwifi: dvm: enable IEEE80211_HW_SUPPORT_FAST_XMIT
>       iwlwifi: mvm: simplify iwl_mvm_stop_roc()
>       iwlwifi: prepare for higher API/CAPA bits
>       iwlwifi: mvm: advertise only HW-supported ciphers
>       mac80211: handle aggregation session timeout on fast-xmit path
>       Merge remote-tracking branch 'net-next/master' into mac80211-ne=
xt
>       mac80211: convert HW flags to unsigned long bitmap
>       mac80211: fix locking in update_vlan_tailroom_need_count()
>
> John Fastabend (2):
>       ethtool: Add helper routines to pass vf to rx_flow_spec
>       ixgbe: Allow flow director to use entire queue space
>
> John W. Linville (7):
>       geneve: remove MODULE_ALIAS_RTNL_LINK from net/ipv4/geneve.c
>       geneve: move definition of geneve_hdr() to geneve.h
>       geneve: Rename support library as geneve_core
>       geneve_core: identify as driver library in modules description
>       geneve: add initial netdev driver for GENEVE tunnels
>       geneve: allow user to specify TTL for tunnel frames
>       geneve: allow user to specify TOS info for tunnel frames
>
> Jon Cooper (3):
>       sfc: Add use of shared RSS contexts.
>       sfc: Initialise MCDI buffers to 0 on declaration.
>       sfc: Change entity reset on MC reboot to a new datapath-only re=
set.
>
> Jon Paul Maloy (9):
>       tipc: simplify resetting and disabling of bearers
>       tipc: simplify link timer handling
>       tipc: simplify include dependencies
>       tipc: simplify packet sequence number handling
>       tipc: rename fields in struct tipc_link
>       tipc: simplify link supervision checkpointing
>       tipc: improve link congestion algorithm
>       tipc: add packet sequence number at instant of transmission
>       tipc: fix bug in link protocol message create function
>
> Jonathan Corbet (1):
>       mac80211: Fix mac80211.h docbook comments
>
> Jozsef Kadlecsik (13):
>       netfilter: ipset: Fix sparse warning
>       netfilter: ipset: Give a better name to a macro in ip_set_core.=
c
>       netfilter: ipset: Use better include files in xt_set.c
>       netfilter: ipset: Use MSEC_PER_SEC consistently
>       netfilter: ipset: Fix cidr handling for hash:*net* types
>       netfilter: ipset: Fix parallel resizing and listing of the same=
 set
>       netfilter: ipset: Make sure listing doesn't grab a set which is=
 just being destroyed.
>       netfilter:ipset Remove rbtree from hash:net,iface
>       netfilter: ipset: Prepare the ipset core to use RCU at set leve=
l
>       netfilter: ipset: Introduce RCU locking in bitmap:* types
>       netfilter: ipset: Introduce RCU locking in hash:* types
>       netfilter: ipset: Introduce RCU locking in list type
>       netfilter: ipset: Fix coding styles reported by checkpatch.pl
>
> Julia Lawall (2):
>       ipv6: drop unneeded goto
>       wl1251: drop unneeded goto
>
> Julian Anastasov (2):
>       neigh: do not modify unlinked entries
>       ip: report the original address of ICMP messages
>
> Julien Grall (3):
>       net/xen-netfront: Correct printf format in xennet_get_responses
>       net/xen-netback: Remove unused code in xenvif_rx_action
>       net/xen-netback: Don't mix hexa and decimal with 0x in the prin=
tf format
>
> Justin Cormack (2):
>       macvtap add missing ioctls - fix wrapping
>       fix missing copy_from_user in macvtap
>
> K. Y. Srinivasan (2):
>       hv_netvsc: Allocate the receive buffer from the correct NUMA no=
de
>       hv_netvsc: Allocate the sendbuf in a NUMA aware way
>
> KY Srinivasan (2):
>       hv_netvsc: Use the xmit_more skb flag to optimize signaling the=
 host
>       hv_netvsc: Properly size the vrss queues
>
> Kalesh AP (3):
>       be2net: add support for spoofchk setting
>       be2net: check for INSUFFICIENT_VLANS error
>       be2net: use be_virtfn() instead of !be_physfn()
>
> Kalle Valo (9):
>       ath10k: bump up FW API to 5
>       Merge mac80211-next into ath-next
>       ath10k: fix HTT op backwards compatibility for QCA6174
>       Merge ath-next from ath.git
>       ath10k: add ATH10K_FW_FEATURE_IGNORE_OTP_RESULT
>       Merge tag 'iwlwifi-next-for-kalle-2015-05-03' of https://git.ke=
rnel.org/.../iwlwifi/iwlwifi-next
>       Merge ath-next from ath.git
>       Merge tag 'iwlwifi-next-for-kalle-2015-06-03' of https://git.ke=
rnel.org/.../iwlwifi/iwlwifi-next
>       Merge ath-next from ath.git
>
> Kees Cook (1):
>       cxgb3: avoid needless buffer copy for firmware
>
> Kenneth Klette Jonassen (6):
>       tcp: move struct tcp_sacktag_state to tcp_ack()
>       tcp: improve RTT from SACK for CC
>       tcp: invoke pkts_acked hook on every ACK
>       tcp: export tcp_enter_cwr()
>       tcp: add CDG congestion control
>       tcp: cdg: use div_u64()
>
> Kevin Lo (1):
>       rtlwifi: fix typos in Kconfig
>
> Lars-Peter Clausen (2):
>       net: rfkill: Switch to PM ops
>       cfg80211: Switch to PM ops
>
> Lauri Kentt=C3=A4 (1):
>       rtlwifi: rtl8188ee: Fix pwrseqcmd.h include path.
>
> Lendacky, Thomas (10):
>       amd-xgbe: Add additional stats to be reported via ethtool
>       amd-xgbe: Add netif_* message support to the driver
>       amd-xgbe: Rework the Rx path SKB allocation
>       amd-xgbe: Move the PHY support into amd-xgbe
>       amd-xgbe: Support defining PHY resources in ETH device node
>       amd-xgbe: Fix flow control setting logic
>       amd-xgbe: Remove manual check and set of dma_mask pointer
>       amd-xgbe: Add setting of a missing hardware feature
>       amd-xgbe: Fix initial mode when auto-negotiation is disabled
>       amd-xgbe: Add more netif_dbg output to the driver
>
> Lennert Buytenhek (10):
>       mac802154: Avoid rtnl deadlock in mac802154_wpan_ioctl().
>       ieee802154 socket: Return EMSGSIZE from raw_sendmsg() if packet=
 too big.
>       Documentation/networking/ieee802154.txt: fix various inaccuraci=
es.
>       ieee802154: Remove ieee802154_reduced_mlme_ops references.
>       ieee802154: Remove 802.15.4/6LoWPAN checks for interface MTU.
>       ieee802154 socket: No need to check for ARPHRD_IEEE802154 in ra=
w_bind().
>       mac802154: mac802154_mlme_start_req() optimisation.
>       ieee802154: Fix generation of random EUI-64 addresses.
>       ieee802154: Fix EUI-64 station address validation.
>       ieee802154: Fix sockaddr_ieee802154 implicit padding informatio=
n leak.
>
> Leo Yan (1):
>       Bluetooth: btwilink: remove DEBUG define
>
> Li RongQing (8):
>       xfrm: remove the xfrm_queue_purge definition
>       xfrm: optimise the use of walk list header in xfrm_policy/state=
_walk
>       xfrm: fix the return code when xfrm_*_register_afinfo failed
>       xfrm: slightly optimise xfrm_input
>       ipv4: remove the unnecessary codes in fib_info_hash_move
>       xfrm: remove the unnecessary checking before call xfrm_pol_hold
>       xfrm: move the checking for old xfrm_policy hold_queue to begin=
ning
>       xfrm: optimise to search the inexact policy list
>
> Liad Kaufman (4):
>       iwlwifi: rs: remove code duplication when filling lq cmd
>       iwlwifi: pcie: support marbh fw dbg mode
>       iwlwifi: rs: remove unneeded check of average tpt in window
>       iwlwifi: wrt: add mipi type to debug types
>
> Linus L=C3=BCssing (4):
>       bridge: multicast: call skb_checksum_{simple_, }validate
>       net: Export IGMP/MLD message validation code
>       net: fix two sparse warnings introduced by IGMP/MLD parsing exp=
orts
>       bridge: allow setting hash_max + multicast_router if interface =
is down
>
> Loic Poulain (2):
>       Bluetooth: Reorder HCI user channel socket release
>       Bluetooth: Don't call shutdown when leaving user channel
>
> Luciano Coelho (44):
>       iwlwifi: mvm: add scan parameters debugging info
>       iwlwifi: mvm: don't increase max_out_time when low priority sca=
n is requested
>       iwlwifi: mvm: convert scan_status to a bitmap
>       iwlwifi: mvm: don't wait for scan stopped work when cancelling =
scans
>       iwlwifi: mvm: check if scan can be started before cancelling ot=
her scans
>       iwlwifi: mvm: generalize the other-scan stopping code
>       iwlwifi: mvm: rename unified_scan symbols to just scan
>       iwlwifi: mvm: move scan code from mac80211.c to scan.c
>       iwlwifi: mvm: differentiate net-detect from sched scan
>       iwlwifi: mvm: some clean ups in fw-api-scan.h
>       iwlwifi: mvm: always use iwl_mvm_scan_size to calculate the sca=
n size
>       iwlwifi: mvm: combine scan size checks into a common function
>       iwlwifi: mvm: combine parts of UMAC and LMAC scans
>       iwlwifi: mvm: combine parts of UMAC and LMAC sched scans
>       iwlwifi: mvm: add common scan params to thw iwl_mvm_scan_params=
 struct
>       iwlwifi: mvm: combine ssid_bitmap setting for regular scans
>       iwlwifi: mvm: revert order of SSIDs for sched scans
>       iwlwifi: mvm: combine SSID functions for sched and regular scan=
s
>       iwlwifi: mvm: rename scan_calc_params to scan_calc_dwell
>       iwlwifi: mvm: combine LMAC and UMAC preq generation
>       iwlwifi: mvm: add number of scan iterations and multiplier to p=
arams
>       iwlwifi: mvm: combine LMAC scans into one
>       iwlwifi: mvm: trim sched scan delay down to 16-bit for LMAC as =
well
>       iwlwifi: mvm: combine UMAC scans into one
>       iwlwifi: mvm: move all UMAC scan flags setting into the relevan=
t function
>       iwlwifi: mvm: move all LMAC scan flags into a single funtion
>       iwlwifi: mvm: rename generic_scan_cmd functions to dwell
>       iwlwifi: mvm: remove some unused stuff from scan.c
>       iwlwifi: pcie: don't call set_pwr functions for family 8000
>       iwlwifi: mvm: small fix in a comment about UMAC scan schedules
>       iwlwifi: mvm: remove the UMAC specific scan types
>       iwlwifi: mvm: fix the net-detect SSIDs report order
>       iwlwifi: mvm: make iwl_mvm_config_sched_scan_profiles() static
>       iwlwifi: mvm: reorganize scan stopping functions
>       iwlwifi: mvm: don't stop regular scans when going out of idle s=
tate
>       iwlwifi: mvm: combine part of the scan stop flows
>       iwlwifi: mvm: rename umac scan stop function
>       iwlwifi: mvm: rename some LMAC-specific scan functions
>       iwlwifi: mvm: refactor UMAC scan UID handling
>       iwlwifi: mvm: remove code that stops multiple UMAC scans of a t=
ype
>       iwlwifi: mvm: combine UMAC and LMAC scan_stop functions
>       iwlwifi: mvm: combine regular and sched scan stop functions
>       iwlwifi: mvm: make UMAC scans use the stopping scan status
>       iwlwifi: mvm: treat scan races also on UMAC scans
>
> Mahesh Bandewar (6):
>       ipvlan: Defer multicast / broadcast processing to a work-queue
>       ipvlan: Always set broadcast bit in multicast filter
>       bonding: Allow userspace to set actors' system_priority in AD s=
ystem
>       bonding: Allow userspace to set actors' macaddr in an AD-system=
=2E
>       bonding: Implement user key part of port_key in an AD system.
>       bonding: Display LACP info only to CAP_NET_ADMIN capable user
>
> Majd Dibbiny (9):
>       net/mlx5_core: Make the vport helpers available for the IB driv=
er too
>       net/mlx5_core: Add new query HCA vport commands
>       net/mlx5_core: Get vendor-id using the query adapter command
>       net/mlx5_core: Use port number in the query port mtu helpers
>       net/mlx5_core: Use port number when querying port ptys
>       net/mlx5_core: Add more query port helpers
>       IB/mlx5: Avoid using the MAD_IFC command under ISSI > 0 mode
>       IB/mlx5: Don't create IB instance over Ethernet ports
>       net/mlx5_core: Fix static checker warnings around system guid q=
uery flow
>
> Maninder Singh (1):
>       packet: remove handling of tx_ring
>
> Marc Kleine-Budde (3):
>       can: flexcan: add documentation about mailbox organization
>       can: flexcan: rename struct flexcan_regs::crl2 -> ctrl2
>       can: flexcan: replace open coded "mailbox code" by proper defin=
e
>
> Marcel Holtmann (6):
>       Bluetooth: Fix race condition with user channel and setup stage
>       Bluetooth: btusb: Fix memory leak in Intel setup routine
>       Bluetooth: btusb: Remove double error check from local version =
command
>       Bluetooth: btusb: Remove unneeded btusb_read_local_version func=
tion
>       Bluetooth: btusb: Fix secure send command length alignment on I=
ntel 8260
>       Bluetooth: Increment management interface revision
>
> Marcelo Ricardo Leitner (3):
>       tcp: add tcpi_segs_in and tcpi_segs_out to tcp_info
>       netfilter: conntrack: warn the user if there is a better helper=
 to use
>       sctp: fix ASCONF list handling
>
> Marek Lindner (2):
>       batman-adv: checkpatch - comparison to NULL could be rewritten
>       batman-adv: checkpatch - spaces preferred around that '*'
>
> Marek Puzyniak (5):
>       ath10k: make peer type configurable
>       ath10k: store max tdls vdevs that fw can handle
>       ath10k: update station counting
>       ath10k: add wmi support for tdls
>       ath10k: introduce basic tdls functionality
>
> Mark A. Greer (1):
>       NFC: trf7970a: Handle extra byte in response to Type 5 RMB comm=
ands
>
> Mark Rustad (3):
>       ixgbe: Fix IOSF SB access issues
>       ixgbe: Release semaphore bits in the right order
>       ixgbe: Use a signed type to hold error codes
>
> Markus Pargmann (19):
>       batman-adv: debugfs, avoid compiling for !DEBUG_FS
>       batman-adv: tvlv realloc, move error handling into if block
>       batman-adv: Makefile, Sort alphabetically
>       batman-adv: iv_ogm_iface_enable, direct return values
>       batman-adv: iv_ogm_aggr_packet, bool return value
>       batman-adv: iv_ogm_send_to_if, declare char* as const
>       batman-adv: iv_ogm_can_aggregate, code readability
>       batman-adv: iv_ogm_orig_update, remove unnecessary brackets
>       batman-adv: iv_ogm_aggregate_new, simplify error handling
>       batman-adv: iv_ogm_queue_add, Simplify expressions
>       batman-adv: iv_ogm_orig_update, style, add missing brackets
>       batman-adv: iv_ogm, Fix dup_status comment
>       batman-adv: iv_ogm, fix coding style
>       batman-adv: iv_ogm, fix comment function name
>       batman-adv: types, Fix comment on bcast_own
>       batman-adv: main, Convert is_my_mac() to bool
>       batman-adv: main, batadv_compare_eth return bool
>       batman-adv: Remove unnecessary ret variable
>       batman-adv: Remove unnecessary ret variable in algo_register
>
> Martin KaFai Lau (16):
>       ipv6: Consider RTF_CACHE when searching the fib6 tree
>       ipv6: Stop /128 route from disappearing after pmtu update
>       ipv6: Stop rt6_info from using inet_peer's metrics
>       ipv6: Remove DST_METRICS_FORCE_OVERWRITE and _rt6i_peer
>       ipv6: Check RTF_LOCAL on rt->rt6i_flags instead of rt->dst.flag=
s
>       ipv6: Clean up ipv6_select_ident() and ip6_fragment()
>       ipv6: Remove external dependency on rt6i_dst and rt6i_src
>       ipv6: Remove external dependency on rt6i_gateway and RTF_ANYCAS=
T
>       ipv6: Combine rt6_alloc_cow and rt6_alloc_clone
>       ipv6: Only create RTF_CACHE routes after encountering pmtu exce=
ption
>       ipv6: Add rt6_get_cookie() function
>       ipv6: Set FLOWI_FLAG_KNOWN_NH at flowi6_flags
>       ipv6: Create RTF_CACHE clone when FLOWI_FLAG_KNOWN_NH is set
>       ipv6: Keep track of DST_NOCACHE routes in case of iface down/un=
register
>       ipv6: Break up ip6_rt_copy()
>       ipv6: Create percpu rt6_info
>
> Martin Townsend (1):
>       mac802154: fakelb: Fix potential NULL pointer dereference.
>
> Masanari Iida (2):
>       wireless: fix typos in mwifiex and rtlwifi
>       NFC: Fix typo in nfc-hci.txt
>
> Matan Barak (3):
>       net/mlx4_core: Demote simple multicast and broadcast flow steer=
ing rules
>       net/mlx4: Add EQ pool
>       net/mlx4_core: Make sure there are no pending async events when=
 freeing CQ
>
> Mathieu Olivari (4):
>       stmmac: add phy-handle support to the platform layer
>       stmmac: add fixed-link device-tree support
>       stmmac: add ipq806x glue layer
>       net: stmmac: ipq806x: document device tree bindings
>
> Matti Gottlieb (5):
>       mac80211: force off channel transmission for public action fram=
es
>       iwlwifi: mvm: ROC: Reduce the aux roc max delay
>       iwlwifi: mvm: Add debugfs entry for Tx power limit
>       iwlwifi: mvm: Remove old scan commands
>       iwlwifi: mvm: Add DC2DC_CONFIG_CMD (0x83) cmd & TLV
>
> Michael Holzheu (4):
>       test_bpf: add 173 new testcases for eBPF
>       test_bpf: fix sparse warnings
>       test_bpf: Add backward jump test case
>       s390/bpf: implement bpf_tail_call() helper
>
> Michal Kazior (71):
>       ath10k: fix AP/IBSS CSA with template based fw
>       ath10k: fix broken traffic for 802.1x in client mode
>       ath10k: fix broken traffic for static WEP in IBSS
>       ath10k: fix ap u-apsd cmd on qca6174 w/ wmi-tlv
>       ath10k: fix TxBF VHT capabilities for 2+ RF-chain devices
>       ath10k: refactor p2p noa code
>       ath10k: implement handling of p2p noa event
>       ath10k: improve 11b coex
>       ath10k: fix some pci wake/sleep issues
>       ath10k: save/restore pci config space properly
>       ath10k: fix patching mistake for AP/IBSS CSA
>       ath10k: fix CAC regression
>       ath10k: fix WPA crypto
>       ath10k: implement wmi roam event
>       ath10k: add hw connection monitor support
>       ath10k: strip qos data bit always
>       ath10k: protect driver from unsolicited htc ep0 events
>       ath10k: clear htt.freq
>       ath10k: unify tx mode and dispatch
>       ath10k: move rate definitions to file start
>       ath10k: derive rate from bitrate
>       ath10k: drop RATETAB_ENT macro
>       ath10k: add hw rate definitions
>       ath10k: use hw rate definitions for fixed rate
>       ath10k: simplify fixed rate selection
>       ath10k: rework legacy rx rate decoding
>       ath10k: deduplicate bitrate to rate idx conversion
>       ath10k: document ofdm/5ghz rate offset with a macro
>       ath10k: fix aid setup in station mode
>       ath10k: fix survey reporting
>       ath10k: don't call quiet mode if it's not implemented
>       ath10k: allow empty ssid vdev config
>       ath10k: implement chanctx API
>       ath10k: implement adaptive qcs command
>       ath10k: rework tx queue locking
>       ath10k: implement tx pause wmi event
>       ath10k: enable multi-channel on supported devices
>       ath10k: allocate fw resources for iface combinations
>       ath10k: clean up set_bitrate_mask handling
>       ath10k: fix IBSS scanning on wmi-tlv and qca6174
>       ath10k: fix insufficient tracing buffer size
>       ath10k: replenish htc tx credits always
>       ath10k: fix arvif->wep_keys clearing
>       ath10k: fix static wep with more than 1 key in client mode
>       ath10k: fix hw roc expiration
>       ath10k: use scan burst for hw roc
>       ath10k: fix error handling in pci_probe
>       ath10k: add extra check for frame tracing
>       ath10k: change static wep key handling for client mode
>       ath10k: don't use reassoc flag
>       ath10k: fix multiple key static wep with ibss
>       ath10k: set def key idx for ibss
>       ath10k: share board file loading code across FW APIs
>       ath10k: allow loading device specific board files
>       ath10k: fix qca61x4 hw2.1 support
>       ath10k: implement more versatile set_bitrate_mask
>       mac80211: check fast-xmit on station change
>       ath10k: enable pci soc powersaving
>       ath10k: add new 4addr related fw_feature
>       mac80211: prevent possible crypto tx tailroom corruption
>       cfg80211: ignore netif running state when changing iftype
>       ath10k: move cycle_count macro
>       ath10k: handle cycle counter wraparound
>       ath10k: fix inconsistent survey reports
>       ath10k: add missing firmware declarations
>       ath10k: fix possible ps sleep crash
>       ath10k: fix ar->rx_channel updating logic
>       ath10k: remove ath10k_chanctx struct
>       ath10k: fix channel switching
>       ath10k: prevent memory leak in wmi rx ops
>       mac80211: release channel on auth failure
>
> Michal Simek (4):
>       net: axienet: Fix comments blocks
>       net: axienet: Fix kernel-doc warnings
>       net: ll_temac: Use one return statement instead of two
>       net: ll_temac: Remove sparse warnings
>
> Neerav Parikh (1):
>       i40e: Collect PFC XOFF RX stats even in single TC case
>
> Neil McKee (1):
>       openvswitch: include datapath actions with sampled-packet upcal=
l to userspace
>
> Nicholas Krause (1):
>       iwlwifi: Remove use of the deprecacted PTR_RET
>
> Nicholas Mc Guire (13):
>       ath10k: mac: match wait_for_completion_timeout return type
>       ath10k: htc: match wait_for_completion_timeout return type
>       ath10k: debug: match wait_for_completion_timeout return type
>       ath10k: thermal: match wait_for_completion_timeout return type
>       ath10k: core: match wait_for_completion_timeout return type
>       ath10k: harmonize error case handling in ath10k_core_start
>       irda: irda-usb: use msecs_to_jiffies for conversions
>       irda: use msecs_to_jiffies for conversion to jiffies
>       carl9170: match wait_for_completion_timeout return type
>       wan: dscc4: fix build warning Wunused-but-set-variable
>       cosa: use msecs_to_jiffies for conversions
>       wan: dscc4: use msecs_to_jiffies for conversions
>       atm: use msecs_to_jiffies for conversions
>
> Nick Kossifidis (11):
>       ath9k: Add a new debug flag for FFT spectral scan
>       ath9k: Fix hanlding of maximum magnitude index
>       ath9k: Move processing of FFT frames to different functions
>       ath9k: Perform integrity checks when processing FFT frames
>       ath9k: Support processing of multiple FFT frames per report.
>       ath9k: Skip malformed frames on normal FFT report
>       ath9k: No need for that extra memcpy
>       ath9k: Skip FFT reports if we are out of output buffers
>       ath9k: No need for that extra memset
>       ath9k: Mix the received FFT bins to the random pool
>       ath9k: Enable short repeat by default on ath9k_htc
>
> Nicolai Stange (1):
>       isdn: disable HiSax NetJet driver on microblaze arch
>
> Nicolas Dichtel (8):
>       netns: returns always an id in __peernet2id()
>       netns: always provide the id to rtnl_net_fill()
>       netns: rename peernet2id() to peernet2id_alloc()
>       netns: notify new nsid outside __peernet2id()
>       netns: use a spin_lock to protect nsid management
>       netlink: rename private flags and states
>       netlink: allow to listen "all" netns
>       netns: fix unbalanced spin_lock on error
>
> Nicolas Ferre (3):
>       net/macb: bindings doc: fix compatibility string
>       net/macb: bindings doc/trivial: fix sama5d4 comment
>       net/macb: bindings doc: add sama5d2 compatibility sting
>
> Nicolas Schichan (3):
>       net: filter: add a callback to allow classic post-verifier tran=
sformations
>       seccomp: simplify seccomp_prepare_filter and reuse bpf_prepare_=
filter
>       ARM: net: add JIT support for loads from struct seccomp_data.
>
> Nikolay Aleksandrov (7):
>       bridge: make br_fdb_delete also check if the port matches
>       bonding: export slave's actor_oper_port_state via sysfs and net=
link
>       bonding: export slave's partner_oper_port_state via sysfs and n=
etlink
>       bridge: fix br_stp_set_bridge_priority race conditions
>       bridge: multicast: start querier timer when running user-space =
stp
>       bridge: multicast: add a comment to br_port_state_selection abo=
ut blocking state
>       bridge: vlan: flush the dynamically learned entries on port vla=
n delete
>
> Nimrod Andy (1):
>       net: fec: init MAC prior to mii bus probe
>
> Noam Camus (1):
>       NET: Add ezchip ethernet driver
>
> Okash Khawaja (2):
>       adm8211: fix checkpatch errors for indentation and new line
>       adm8211: fixed the possible pci cache line sizes inside switch-=
case
>
> Oleg Zhurakivskyy (1):
>       NFC: nxp-nci_i2c: Add support for enumerating through ACPI
>
> Oleksij Rempel (1):
>       ath9k: split ar5008_hw_spur_mitigate and reuse common code in a=
r9002_hw_spur_mitigate.
>
> Oliver Hartkopp (2):
>       can: cangw: introduce optional uid to reference created routing=
 jobs
>       can: fix loss of CAN frames in raw_rcv
>
> Or Gerlitz (8):
>       net/mlx4_core: Enhance the MAD_IFC wrapper to convert VF port t=
o physical
>       IB/mlx4: Convert slave port before building address-handle
>       net/mlx4_core: Modify port values when generting EQEs for VFs
>       net/mlx4_core: Adjust the schedule queue port for single ported=
 IB VFs
>       net/mlx4_core: Adjust the schedule queue port in reset-to-init =
too
>       net/mlx4_core: Enable single ported IB VFs
>       net/mlx4_core: Fix build failure introduced by the EQ pool chan=
ges
>       net/mlx4_core: Disable Granular QoS per VF under IB/Eth VPI con=
figuration
>
> Pablo Neira (6):
>       net: kill useless net_*_ingress_queue() definitions when NET_CL=
S_ACT is unset
>       netfilter: cleanup struct nf_hook_ops indentation
>       netfilter: add hook list to nf_hook_state
>       netfilter: add nf_hook_list_active()
>       net: add CONFIG_NET_INGRESS to enable ingress filtering
>       netfilter: add netfilter ingress hook after handle_ing() under =
unique static key
>
> Pablo Neira Ayuso (14):
>       netfilter: x_tables: add context to know if extension runs from=
 nft_compat
>       netfilter: default CONFIG_NETFILTER_INGRESS to y
>       netfilter: nf_tables: allow to bind table to net_device
>       netfilter: nf_tables: add netdev table to filter from ingress
>       netfilter: Kconfig: get rid of parens around depends on
>       Merge branch 'master' of git://blackhole.kfki.hu/nf-next
>       netfilter: nf_tables: attach net_device to basechain
>       netfilter: nf_tables: add nft_register_basechain() and nft_unre=
gister_basechain()
>       netfilter: nf_tables_netdev: unregister hooks on net_device rem=
oval
>       netfilter: bridge: rename br_netfilter.c to br_netfilter_hooks.=
c
>       netfilter: bridge: split ipv6 code into separated file
>       net: include missing headers in net/net_namespace.h
>       netfilter: use forward declaration instead of including linux/p=
roc_fs.h
>       netfilter: don't pull include/linux/netfilter.h from netns head=
ers
>
> Padmanabh Ratnakar (1):
>       be2net: set interrupt moderation for Skyhawk-R using EQ-DB
>
> Palik, Imre (1):
>       xen-netback: fix a BUG() during initialization
>
> Pankaj Gupta (1):
>       macvtap: Increase limit of macvtap queues
>
> Parav Pandit (1):
>       net-next: ethtool: Added port speed macros.
>
> Paul Gortmaker (1):
>       drivers/net: remove all references to obsolete Ethernet-HOWTO
>
> Pavel Fedin (1):
>       net: Cavium: Fix MAC address setting in shutdown state
>
> Peter Crosthwaite (2):
>       net: axienet: Handle 0 packet receive gracefully
>       net: axienet: Service completion interrupts ASAP
>
> Peter Oberparleiter (1):
>       s390/lcs: Fix null-pointer access in msg
>
> Peter Oh (9):
>       ath: introduce chirp parameter used by DFS
>       ath10k: update chirp value in pulse event
>       ath: enhance radar detection by looking up chirp
>       ath10k: enable channel 144 on 5GHz band
>       ath: support new FCC DFS Radar Type 1
>       ath: define JP DFS patterns separated from FCC
>       ath: lower JP W53 band DFS detection threshold around 30%
>       ath10k: use MAC clock rate same as FW uses for survey accuracy
>       ath10k: increase relay buffer size of spectral scan
>
> Phil Sutter (1):
>       net: inet_diag: export IPV6_V6ONLY sockopt
>
> Philippe Reynes (1):
>       net: fec: add support of ethtool get_regs
>
> Pontus Fuchs (2):
>       brcmfmac: Check if firmware supports p2p
>       brcmfmac: Build wiphy mode and interface combinations dynamical=
ly
>
> Prasanna Karthik (3):
>       Bluetooth: vhci: Clean up coding style fix
>       Bluetooth: hci_bcsp: Clean up code Fix
>       Bluetooth: bt3c_cs: Fix coding style -- clean up
>
> Rafa=C5=82 Mi=C5=82ecki (11):
>       brcmfmac: check result of USB firmware request
>       brcmfmac: simplify check stripping v2 NVRAM
>       brcmfmac: simplify check finding NVRAM v1 device path
>       brcmfmac: treat \0 as end of comment when parsing NVRAM
>       brcmfmac: allow NVRAM values to contain spaces
>       brcmfmac: support NVRAMs containing pci devpaths (instead of pc=
ie)
>       brcmfmac: set wiphy perm_addr to hardware MAC address
>       brcmfmac: use direct data pointer in NVRAM parser struct
>       b43: fix support for 14e4:4321 PCI dev with BCM4321 chipset
>       bcma: make calls to PCI hostmode functions config-safe
>       bcma: lower dependency of BCMA_DRIVER_PCI_HOSTMODE
>
> Raghu Vatsavayi (3):
>       Add support of Cavium Liquidio ethernet adapters
>       Fix Cavium Liquidio build related errors and warnings
>       Modify Liquidio Kconfig for crc lib
>
> Raja Mani (2):
>       ath10k: free wmi mgmt event skb when parsing fails
>       ath10k: remove unused variable 'id' in ath10k_pci_tx_pipe_clean=
up()
>
> Rajkumar Manoharan (13):
>       ath10k: increase copy engine entries for rx wmi
>       ath10k: increase duty cycle maximum limit
>       ath10k: fix wrong symlink name on error path
>       ath10k: fix rts profile for second rate series
>       ath10k: increase station kickout threshold
>       ath10k: add debugfs entry to configure quiet period
>       ath10k: fix interpretation of cooling device state
>       ath10k: configure thermal throttle while powering up
>       ath10k: do not restrict thermal throttling to ap mode
>       ath10k: cache throttle state when device is down
>       ath10k: move driver state check before setting throttle
>       ath10k: add ATH10K_FW_IE_HTT_OP_VERSION
>       ath10k: bypass PLL setting on target init for QCA9888
>
> Ralf Baechle (1):
>       NET: ROSE: Don't dereference NULL neighbour pointer.
>
> Rana Shahout (2):
>       net/mlx5_core: Implement get/set port status
>       net/mlx5_core: Modify CQ moderation parameters
>
> Rasmus Villemoes (1):
>       net: tulip: rearrange order of searching for substrings
>
> Richard Alpe (3):
>       tipc: fix default link prop regression in nl compat
>       tipc: add broadcast link window set/get to nl api
>       tipc: send explicit not supported error in nl compat
>
> Richard Cochran (4):
>       net: cpsw: fix misplaced break statements.
>       net: cpsw: remove two unused global functions
>       net: cpsw: remove redundant calls enabling dma interrupts.
>       net: cpsw: remove redundant calls disabling dma interrupts.
>
> Robert Richter (1):
>       net: thunderx: Cleanup duplicate NODE_ID macros, add nic_get_no=
de_id()
>
> Romain Perier (1):
>       net: stmmac: dwmac-rk: Don't add function name in info or err m=
essages
>
> Roman Kubiak (1):
>       netfilter: nfnetlink_queue: add security context information
>
> Roopa Prabhu (1):
>       ipv4: include NLM_F_APPEND flag in append route notifications
>
> Saeed Mahameed (12):
>       net/mlx5_core: Set irq affinity hints
>       net/mlx5_core: HW data structs/types definitions cleanup
>       net/mlx5_core: New device capabilities handling
>       net/mlx5_core: Implement access functions of ptys register fiel=
ds
>       net/mlx5_core: Set/Query port MTU commands
>       net/mlx5e: Fix HW MTU settings
>       net/mlx5e: Add HW cacheline start padding
>       net/mlx5e: Disable client vlan TX acceleration
>       net/mlx5e: Support NETIF_F_SG
>       net/mlx5e: Static mapping of netdev priv resources to/from netd=
ev TX queues
>       net/mlx5e: Use skb_shinfo(skb)->gso_segs rather than counting t=
hem
>       net/mlx5e: Prefetch skb data on RX
>
> Samudrala, Sridhar (1):
>       switchdev: add support for fdb add/del/dump via switchdev_port_=
obj ops.
>
> Samuel Ortiz (5):
>       NFC: nxp-nci: Fix build warning
>       NFC: nci: Handle proprietary response and notifications
>       NFC: Introduce vendor commands structures
>       NFC: netlink: Implement vendor command support
>       NFC: nci: Export nci_req_complete
>
> Sara Sharon (2):
>       iwlwifi: pcie: New RBD allocation model
>       mac80211: ignore invalid scan RSSI values
>
> Sathya Perla (1):
>       be2net: update the driver version to 10.6.0.2
>
> Satish Ashok (1):
>       bridge: multicast: restore router configuration on port link do=
wn/up
>
> Scott Feldman (51):
>       switchdev: introduce get/set attrs ops
>       switchdev: convert parent_id_get to switchdev attr get
>       rocker: support prepare-commit transaction model
>       switchdev: convert STP update to switchdev attr set
>       switchdev: introduce switchdev add/del obj ops
>       switchdev: add port vlan obj
>       rocker: use switchdev add/del obj for bridge port vlans
>       switchdev: add bridge port flags attr
>       switchdev: add new switchdev bridge setlink
>       switchdev: cut over to new switchdev_port_bridge_setlink
>       switchdev: remove old switchdev_port_bridge_setlink
>       bridge: restore br_setlink back to original
>       switchdev: add new switchdev_port_bridge_dellink
>       switchdev: cut over to new switchdev_port_bridge_dellink
>       switchdev: remove unused switchdev_port_bridge_dellink
>       bridge: revert br_dellink change back to original
>       switchdev: add new switchdev_port_bridge_getlink
>       switchdev: cut over to new switchdev_port_bridge_getlink
>       switchdev: convert fib_ipv4_add/del over to switchdev_port_obj_=
add/del
>       switchdev: remove NETIF_F_HW_SWITCH_OFFLOAD feature flag
>       rocker: make checkpatch -f clean
>       switchdev: bring documentation up-to-date
>       switchdev: sparse warning: make __switchdev_port_obj_add static
>       switchdev: sparse warning: pass ipv4 fib dst as network-byte or=
der
>       switchdev: align comment with other comments in block
>       switchdev: apply review comments on documentation
>       switchdev: don't use anonymous union on switchdev attr/obj stru=
cts
>       rocker: zero allocate ports array
>       rocker: cleanup vlan table on error adding vlan
>       rocker: install untagged VLAN (vid=3D0) support for each port
>       rocker: install/remove router MAC for untagged VLAN when joinin=
g/leaving bridge
>       rocker: remove support for legacy VLAN ndo ops
>       switchdev: documentation: fix longer-than-80-char lines
>       switchdev: documentation: fix grammer error
>       switchdev: documentation: for static FDB ops, use switchdev_por=
t_fdb_xxx ops
>       switchdev: documentation: use switchdev_port_obj_xxx for IPv4 F=
IB add/modify/delete ops
>       switchdev: fix handling for drivers not supporting IPv4 fib add=
/del ops
>       switchdev: fix BUG when port driver doesn't support set attr op
>       bridge: use either ndo VLAN ops or switchdev VLAN ops to instal=
l MASTER vlans
>       rocker: gaurd against NULL rocker_port when removing ports
>       rocker: fix neigh tbl index increment race
>       rocker: revert back to support for nowait processes
>       rocker: mark neigh update event processing as 'no wait'
>       rocker: mark STP update as 'no wait' processing
>       rocker: move MAC learn event back to 'no wait' processing
>       rocker: move port stop to 'no wait' processing
>       bridge: del external_learned fdbs from device on flush or ageou=
t
>       switchdev: fdb filter_dev is always NULL for self (device), so =
remove check
>       switchdev: rename vlan vid_start to vid_begin
>       switchdev; add VLAN support for port's bridge_getlink
>       switchdev: change BUG_ON to WARN for attr set failure case
>
> SenthilKumar Jegadeesan (1):
>       ath10k: increase AST table SKID length limit
>
> Sergei Shtylyov (2):
>       Renesas Ethernet AVB driver proper
>       Renesas Ethernet AVB PTP clock driver
>
> Sergey Popovich (16):
>       netfilter: ipset: Properly calculate extensions offsets and tot=
al length
>       netfilter: ipset: No need to make nomatch bitfield
>       netfilter: ipset: Preprocessor directices cleanup
>       netfilter: ipset: Return ipset error instead of bool
>       netfilter: ipset: Check IPSET_ATTR_PORT only once
>       netfilter: ipset: Use HOST_MASK literal to represent host addre=
ss CIDR len
>       netfilter: ipset: Return bool values instead of int
>       netfilter: ipset: Check for comment netlink attribute length
>       netfilter: ipset: Fix ext_*() macros
>       netfilter: ipset: Fix hashing for ipv6 sets
>       netfilter: ipset: Improve preprocessor macros checks
>       netfilter: ipset: Use SET_WITH_*() helpers to test set extensio=
ns
>       netfilter: ipset: Check extensions attributes before getting ex=
tensions.
>       netfilter: ipset: Permit CIDR equal to the host address CIDR in=
 IPv6
>       netfilter: ipset: Make sure we always return line number on bat=
ch
>       netfilter: ipset: Check CIDR value only when attribute is given
>
> Shailendra Verma (6):
>       Bluetooth: btusb: Change 1 to true in bool type variable assign=
ment
>       Bluetooth: hci_uart: Change 1 to true for bool type variables a=
ssignments
>       net:xen-netback - Change 1 to true for bool type variable.
>       atm:he - Change 1 to true for bool type variable.
>       ray_cs: Change 1 to true for bool type variable.
>       atm:he - Do not initialise statics to 0.
>
> Shao Fu (5):
>       rtlwifi: Update regulatory database
>       rtlwifi: rtl8188ee: Apply the new regulatory information
>       rtlwifi: rtl8192ee: Apply the regulatory changes to driver
>       rtlwifi: rtl8723be: Update driver for regulatory changes
>       rtlwifi: rtl8821ae: Fix problem with regulatory information
>
> Shawn Landden (1):
>       can.h: make padding given by gcc explicit
>
> Shengzhou Liu (1):
>       net/phy: Add support for Realtek RTL8211F
>
> Shradha Shah (22):
>       sfc: Own header for nic-specific sriov functions, single instan=
ce of netdev_ops and sriov removed from Falcon code
>       sfc: Enable VF's via a write to the sysfs file sriov_numvfs
>       sfc: Use MCDI to set FILTER_OP_IN_TX_DOMAIN
>       sfc: Prepare to bind the sfc driver to the VF.
>       sfc: create vports for VFs and assign random MAC addresses
>       sfc: manually allocate and free vadaptors
>       sfc: Bind the sfc driver to any available VF's
>       sfc: Add permissions to MCDI commands
>       sfc: change definition of MC_CMD_VADAPTOR_ALLOC
>       sfc: MC_CMD_SET_MAC can only be called by the link control Func=
tion
>       sfc: Store vf_index in nic_data for Ef10.
>       sfc: save old MAC address in case sriov_mac_address_changed fai=
ls
>       sfc: Store the efx_nic struct of the current VF in the VF data =
struct
>       sfc: add ndo_set_vf_mac() function for EF10
>       sfc: Add ndo_get_vf_config() function for EF10
>       sfc: add ndo_set_vf_vlan() function for EF10
>       sfc: Implement dummy disable of VF spoof check for EF10
>       sfc: set the MAC address using MC_CMD_VADAPTOR_SET_MAC
>       sfc: Add code to export port_num in netdev->dev_port
>       sfc: Add paranthesis correctly on all branches of the if statem=
ent
>       sfc: Add sysfs entry for flags (link control and primary)
>       sfc: Implement ndo_gets_phys_port_id() for EF10 VFs
>
> Shreyas Bhatewara (3):
>       vmxnet3: Register shutdown handler for device (fwd)
>       vmxnet3: Fix memory leaks in rx path (fwd)
>       vmxnet3: Changes for vmxnet3 adapter version 2 (fwd)
>
> Simon Horman (8):
>       net: rocker: Use ether_addr_equal
>       rocker: do not delete fdb entries in rocker_port_fdb_flush() wh=
en preparing transactions
>       rocker: do not modify fdb table in rocker_port_fdb() when prepa=
ring transactions
>       rocker: do not make neighbour entry changes when preparing tran=
sactions
>       rocker: make rocker_port_internal_vlan_id_{get, put}() non-tran=
sactional
>       rocker: remove unused rocker_port parameter from rocker_port_kf=
ree
>       rocker: mark parameters and local variables as const
>       rocker: remove rocker parameter from functions that have rocker=
_port parameter
>
> Simon Wunderlich (1):
>       batman-adv: Start new development cycle
>
> Somnath Kotur (1):
>       be2net: receive pkts with L3, L4 errors on VFs
>
> Sorin Dumitru (2):
>       vxlan: release lock after each bucket in vxlan_cleanup
>       net: limit tcp/udp rmem/wmem to SOCK_{RCV,SND}BUF_MIN
>
> Sowmini Varadhan (3):
>       net/rds: Declare SO_RDS_TRANSPORT and RDS_TRANS_* constants in =
uapi/linux/rds.h
>       net/rds: Add setsockopt support for SO_RDS_TRANSPORT
>       net/rds Add getsockopt support for SO_RDS_TRANSPORT
>
> Srikanth Thokala (8):
>       net: axienet: Support for RGMII
>       net: axienet: Handle jumbo frames for lesser frame sizes
>       net: axienet: Support phy-less mode of operation
>       net: axienet: Removed coding style errors and warnings
>       net: axienet: Use pdev instead of op
>       net: axienet: Use devm_* calls
>       net: axienet: Use of_property_* calls
>       net: axienet: Removed _of_ prefix in probe and remove functions
>
> Stanislaw Gruszka (2):
>       MAINTAINERS: remove rt2x00.serialmonkey.com list and web page
>       rt2800: fix assigning same WCID for different stations
>
> Stas Sergeev (1):
>       mvneta: add forgotten initialization of autonegotiation bits
>
> Stefan Schmidt (10):
>       ieee802154/atusb: Warn about outdated device firmware.
>       ieee802154/atusb: Mark driver as AACK enabled in hardware.
>       ieee802154/atusb: Set default ed level to 0xbe like the rest of=
 these drivers
>       ieee802154/atusb: Add function for partial register writes
>       ieee802154/atusb: Add .set_txpower operation to the driver
>       ieee802154/atusb: Add .set_promiscuous_mode driver operation
>       MAINTAINERS: Add myself as maintainer for the atusb driver
>       mac802154/iface: remove superfluous WARN_ON call in slave_open(=
)
>       ieee802154/mrf24j40: make sure we do not override return values
>       ieee802154: cc2520: check for return values in cc2520_filter()
>
> Steffen Klassert (1):
>       ipv6: Extend the route lookups to low priority metrics.
>
> Stephen Boyd (1):
>       clk: qcom: Add support for NSS/GMAC clocks and resets
>
> Stephen Rothwell (1):
>       drivers: net: xgene: fix for ACPI support without ACPI
>
> Stephen Smalley (1):
>       net/unix: support SCM_SECURITY for stream sockets
>
> Sujith Manoharan (1):
>       ath10k: fix no-ack frame status
>
> Suman Tripathi (4):
>       drivers: net: xgene: Fix the ACPI support for RGMII/SGMII0/XFI =
interface of APM X-Gene SoC ethernet controller.
>       drivers: net: xgene: Implement the backward compatibility with =
the old and new firmware w.r.t Tx completion IRQ interrupt.
>       drivers: net: xgene: Add ACPI support for SGMII0 and XFI1 inter=
face of 2nd H/W version of APM X-Gene SoC ethernet controller.
>       drivers: net: xgene: Check for IS_ERR rather than NULL for cloc=
k.
>
> Sunil Goutham (2):
>       pci: Add Cavium PCI vendor id
>       net: Adding support for Cavium ThunderX network controller
>
> Suresh Reddy (1):
>       be2net: post full RXQ on interface enable
>
> Sven Eckelmann (9):
>       batman-adv: update copyright years for 2015
>       batman-adv: Check total_size when queueing fragments
>       batman-adv: Use only queued fragments when merging
>       batman-adv: Use safer default config for optional features
>       batman-adv: Remove unnecessary check for orig_ifinfo not NULL
>       batman-adv: Use common Jenkins Hash implementation
>       batman-adv: Add required includes to all files
>       batman-adv: Clarify calculation precedence for '&' and '?'
>       batman-adv: Remove unused post-VLAN ethhdr in batadv_gw_dhcp_re=
cipient_get
>
> Taehee Yoo (10):
>       rtlwifi: rtl8192cu: Remove setting REG_BCN_MAX_ERR code in _rtl=
92cu_set_media_status().
>       rtlwifi: rtl8192cu: Remove rtl92c_init_beacon_max_error's param=
eter
>       rtlwifi: rtl8192cu: Fix performance issue.
>       rtlwifi: rtl8192cu: remove IS_HARDWARE_TYPE_8192CE and IS_HARDW=
ARE_TYPE_8192CU
>       rtlwifi: rtl8192cu: remove _InitBeaconParameters().
>       rtlwifi: rtl8192cu: remove INTF_PCI and INTF_USB
>       rtlwifi: rtl8192cu: remove duplicated routine in _rtl92c_phy_rf=
6052_config_parafile
>       rtlwifi: rtl8192cu: debug message change "RTL8192CE" to "RTL819=
2CU"
>       rtlwifi: rtl8192cu: Fix variable isfirst_ampdu
>       rtlwifi: rtl8192c: Add init codes for "fw_version" and "fw_subv=
ersion".
>
> Tedd Ho-Jeong An (1):
>       Bluetooth: btusb: Add routine for applying Intel DDC parameters
>
> Thomas Falcon (4):
>       ibmveth: change rx buffer default allocation for CMO
>       ibmveth: Add support for TSO
>       ibmveth: Add GRO support
>       ibmveth: Add support for Large Receive Offload
>
> Thomas Graf (9):
>       rhashtable-test: Remove unused TEST_NEXPANDS
>       rhashtable-test: Measure time to insert, remove & traverse entr=
ies
>       rhashtable-test: Get rid of ptr in test_obj structure
>       rhashtable-test: Do not allocate individual test objects
>       rhashtable-test: Use walker to test bucket statistics
>       rhashtable-test: Detect insertion failures
>       rhashtable: Simplify iterator code
>       rhashtable-test: Fix 64bit division
>       vxlan: Correctly set flow*i_mark and flow4i_proto in route look=
ups
>
> Thomas Richter (1):
>       qeth: fix rx checksum offload handling
>
> Todd Fujinaka (1):
>       igb: simplify and clean up igb_enable_mas()
>
> Tom Herbert (21):
>       ipv6: Flow label state ranges
>       net: Add skb_get_hash_perturb
>       sched: Call skb_get_hash_perturb in sch_fq_codel
>       sched: Call skb_get_hash_perturb in sch_hhf
>       sched: Call skb_get_hash_perturb in sch_sfb
>       sched: Call skb_get_hash_perturb in sch_sfq
>       net: Add flow_keys digest
>       sch_choke: Use flow_keys_digest
>       net: Simplify GRE case in flow_dissector
>       mpls: Add definition for IPPROTO_MPLS
>       net: Remove superfluous setting of key_basic
>       net: Get skb hash over flow_keys structure
>       net: Add full IPv6 addresses to flow_keys
>       net: Add keys for TIPC address
>       net: Get rid of IPv6 hash addresses flow keys
>       net: Add VLAN ID to flow_keys
>       net: Add IPv6 flow label to flow_keys
>       net: Add GRE keyid in flow_keys
>       mpls: Add MPLS entropy label in flow_keys
>       flow_dissector: Fix MPLS entropy label handling in flow dissect=
or
>       flow_dissector: add support for dst, hop-by-hop and routing ext=
 hdrs
>
> Tomas Krcka (1):
>       can: mcp251x: use correct register address for acceptance filte=
rs
>
> Tomas Winkler (1):
>       NFC: microread: drop unused variable
>
> Toshiaki Makita (1):
>       vlan: Add GRO support for non hardware accelerated vlan
>
> Uwe Kleine-K=C3=B6nig (2):
>       net: rfkill: gpio: make better use of gpiod API
>       NFC: pn544: use flags argument of devm_gpiod_get to set directi=
on
>
> Vaishali Thakkar (7):
>       net: mv643xx_eth: Use setup_timer
>       net: dl2k: Use setup_timer
>       isdn/capi: Use setup_timer
>       ethernet/intel: Use setup_timer
>       xen-netfront: Use setup_timer
>       isdn/hisax: Convert use of __constant_cpu_to_le16 to cpu_to_le1=
6
>       atm: idt77105: Use setup_timer
>
> Valentin Rothberg (1):
>       NFC: Remove obsolete setting of DEBUG
>
> Varka Bhadram (13):
>       ethernet: qualcomm: use spi instead of spi_device
>       ieee802154: add set transmit power support
>       ieee802154: fix typo for file name
>       cc2520: fix in default tx power setting
>       cc2520: fix CC2591 handling
>       cc2520: add set transmit power setting support
>       cc2520: update initial transmit power value
>       cc2520: update current channel
>       mac802154: add trace functionality for driver ops
>       cfg802154: fix rdev-ops naming convension and format specifiers
>       nl802154: export supported commands
>       mac802154: cleanup llsec param flags
>       mac802154: rx packet handle cleanup
>
> Vasanthakumar Thiagarajan (3):
>       ath10k: move ath10k_vdev_stop() up before ath10k_vdev_start_res=
tart()
>       ath10k: fix interrupt storm
>       ath10k: fix survey information reporting
>
> Vasu Dev (1):
>       i40e: fix unrecognized FCOE EOF case
>
> Vasundhara Volam (2):
>       be2net: simplify UFI compatibility checking
>       be2net: update copyright year to 2015
>
> Venkata Duvvuru (3):
>       be2net: Export board temperature using hwmon-sysfs interface.
>       be2net: Report a "link down" to the stack when a fatal error or=
 fw reset happens.
>       be2net: Support for OS2BMC.
>
> Vincent Cuissard (13):
>       NFC: nfcmrvl: remove integration related settings
>       NFC: nfcmrvl: add support of HCI-based transport
>       NFC: nfcmrvl: update nci recv frame API
>       NFC: nfcmrvl: update USB device id
>       NFC: nfcmrvl: add chip reset management
>       NFC: nci: add generic uart support
>       NFC: nfcmrvl: add platform_data and DT configuration
>       NFC: nfcmrvl: add UART driver
>       NFC: nfcmrvl: small fix in USB driver
>       NFC: nfcmrvl: Allow ISO15693 protocol
>       NFC: nci: remove current SLEEP mode management
>       NFC: nfcmrvl: set PB_BAIL_OUT at setup
>       NFC: nci: fix mistake in uart generic driver
>
> Vincent Fann (1):
>       rtlwifi: Remove the clear interrupt routine from all drivers
>
> Vineet Gupta (1):
>       stmmac: replace open coded __netdev_alloc_skb_ip_align() with a=
ctual call
>
> Vivien Didelot (2):
>       if_vlan: fix vlaue -> value typo
>       net: switchdev: ignore unsupported bridge flags
>
> Vladimir Kondratiev (18):
>       wil6210: fw debug mode
>       wil6210: debug [add|del]_key operations
>       wil6210: trace disconnect source
>       wil6210: stop_ap to leave interface closed
>       wil6210: update FW file name
>       wil6210: increase timeout for the "echo" command
>       wil6210: update Rx descriptor fields
>       wil6210: fix boot loader "ready" indication
>       wil6210: fix for probe_resp IE's
>       wil6210: Add pmc debug mechanism memory management
>       wil6210: broadcast for secure link
>       wil6210: support WSC for STA mode
>       wil6210: fix format specifier for dma_addr_t
>       wil6210: modparam for bcast ring size
>       wil6210: add NIC memory region mac_rgf_ext
>       wil6210: add per-MCS Rx stats
>       wil6210: platform hooks for modile init/exit
>       wil6210: reorder init sequence
>
> Vladimir Zapolskiy (1):
>       net: qlcnic: clean up sysfs error codes
>
> WANG Cong (1):
>       netns: make nsid_lock per net
>
> Wang Long (1):
>       netevent: remove automatic variable in register_netevent_notifi=
er()
>
> Wei Liu (1):
>       tcp: double default TSQ output bytes limit
>
> Willem de Bruijn (11):
>       packet: rollover prepare: move code out of callsites
>       packet: rollover prepare: per-socket state
>       packet: rollover only to socket with headroom
>       packet: rollover lock contention avoidance
>       packet: rollover huge flows before small flows
>       packet: rollover statistics
>       packet: fix warnings in rollover lock contention
>       net-packet: fix null pointer exception in rollover mode
>       selftests/net: expect headroom in psock_fanout rollover
>       packet: free packet_rollover after synchronize_net
>       packet: avoid out of bounds read in round robin fanout
>
> Wilson Kok (1):
>       bridge: skip fdb add if the port shouldn't learn
>
> Xi Wang (1):
>       test: bpf: extend "load 64-bit immediate" testcase
>
> Xinming Hu (8):
>       mwifiex: parsing aid while receiving association response
>       Bluetooth: btmrvl: fix compilation warning
>       mwifiex: add cfg80211 get_channel handler
>       mwifiex: maintain station statistic in uap mode
>       mwifiex: add sta_list firmware command
>       mwifiex: dump station support in uap mode
>       mwifiex: using right tid for addressing ra_list
>       mwifiex: do not decrease tx_pending for AMSDU packet once more
>
> Yanbo Li (3):
>       ath10k: change the fw stats access mask
>       ath10k: add the WMI Air Time Fairness service define
>       ath10k: enable the BT-coex feature
>
> Yanir Lubetkin (9):
>       e1000e: i219 fix unit hang on reset and runtime D3
>       e1000e: i219 execute unit hang fix on every reset or power stat=
e transition
>       e1000e: remove call to do_div and sign mismatch warning
>       e1000e: fix logical error in flush_desc_rings
>       e1000e: fix flush_desc_ring implementation
>       e1000e: fix legacy interrupt handling in i219
>       e1000e: fix systim issues
>       e1000e: fix unit hang during loopback test
>       e1000e: Bump the version to 3.2.5
>
> Ying Xue (9):
>       tipc: rename functions defined in subscr.c
>       tipc: introduce tipc_subscrb_create routine
>       tipc: involve reference counter for subscriber
>       tipc: adjust locking policy of subscription
>       tipc: deal with return value of tipc_conn_new callback
>       net: make skb_dst_pop routine static
>       tipc: use sock_create_kern interface to create kernel socket
>       rocker: fix a neigh entry leak issue
>       tipc: unconditionally put sock refcnt when sock timer to be del=
eted is pending
>
> Zhang Chunyu (1):
>       netfilter: xt_MARK: Add ARP support
>
> Zhaowei Yuan (1):
>       net: Update out-of-date comment
>
> Zhaoyang Liu (5):
>       mwifiex: fix invalid HT IE configuration in FW
>       mwifiex: add prints debug ctrl support
>       mwifiex: add dump data debug support
>       mwifiex: change dbg print func to mwifiex_dbg
>       mwifiex: change debug dump issue since skb maybe null
>
> fran=C3=A7ois romieu (9):
>       via-rhine: commit receive buffer address before descriptor stat=
us update.
>       via-rhine: allocate and map receive buffer in a single transact=
ion
>       via-rhine: gotoize rhine_open error path.
>       via-rhine: forbid holes in the receive descriptor ring.
>       via-rhine: kiss rx_head_desc goodbye.
>       via-rhine: add consistent memory barrier in vlan receive code.
>       via-rhine: dma_wmb transmit barrier.
>       via-rhine: close SMP transmit races.
>       net: batch of last_rx update avoidance in ethernet drivers.
>
> sixiao@microsoft.com (2):
>       hv_netvsc: use per_cpu stats to calculate TX/RX data
>       hv_netvsc: change member name of struct netvsc_stats
>
>  Documentation/ABI/testing/sysfs-bus-pci-drivers-janz-cmodio         =
   |    8 +
>  Documentation/ABI/testing/sysfs-class-net                           =
   |   19 +
>  Documentation/ABI/testing/sysfs-class-net-janz-ican3                =
   |   19 +
>  Documentation/devicetree/bindings/net/amd-xgbe-phy.txt              =
   |   48 -
>  Documentation/devicetree/bindings/net/amd-xgbe.txt                  =
   |   40 +-
>  Documentation/devicetree/bindings/net/ezchip_enet.txt               =
   |   15 +
>  Documentation/devicetree/bindings/net/ipq806x-dwmac.txt             =
   |   35 +
>  Documentation/devicetree/bindings/net/macb.txt                      =
   |    6 +-
>  Documentation/devicetree/bindings/net/nfc/nfcmrvl.txt               =
   |   29 +
>  Documentation/devicetree/bindings/net/nfc/{st21nfcb.txt =3D> st-nci.=
txt} |    4 +-
>  Documentation/devicetree/bindings/net/nfc/trf7970a.txt              =
   |    4 +
>  Documentation/devicetree/bindings/net/nxp,lpc1850-dwmac.txt         =
   |   20 +
>  Documentation/devicetree/bindings/net/phy.txt                       =
   |    3 +
>  Documentation/devicetree/bindings/net/renesas,ravb.txt              =
   |   48 +
>  Documentation/devicetree/bindings/net/rockchip-dwmac.txt            =
   |    2 +-
>  Documentation/devicetree/bindings/net/ti,dp83867.txt                =
   |   25 +
>  Documentation/networking/bonding.txt                                =
   |   84 ++
>  Documentation/networking/can.txt                                    =
   |    3 +
>  Documentation/networking/dctcp.txt                                  =
   |    1 +
>  Documentation/networking/ieee802154.txt                             =
   |   32 +-
>  Documentation/networking/ip-sysctl.txt                              =
   |   25 +-
>  Documentation/networking/pktgen.txt                                 =
   |  150 +-
>  Documentation/networking/switchdev.txt                              =
   |  419 +++++-
>  Documentation/networking/tc-actions-env-rules.txt                   =
   |    6 -
>  Documentation/nfc/nfc-hci.txt                                       =
   |    2 +-
>  Documentation/s390/qeth.txt                                         =
   |    4 +-
>  MAINTAINERS                                                         =
   |   35 +-
>  arch/arm/net/bpf_jit_32.c                                           =
   |   10 +
>  arch/s390/net/bpf_jit.h                                             =
   |   10 +-
>  arch/s390/net/bpf_jit_comp.c                                        =
   |  106 +-
>  arch/x86/net/bpf_jit_comp.c                                         =
   |  150 +-
>  crypto/af_alg.c                                                     =
   |    4 +-
>  drivers/atm/he.c                                                    =
   |    4 +-
>  drivers/atm/idt77105.c                                              =
   |    6 +-
>  drivers/atm/iphase.c                                                =
   |    2 +-
>  drivers/bcma/Kconfig                                                =
   |   12 +-
>  drivers/bcma/driver_gpio.c                                          =
   |   20 +-
>  drivers/block/drbd/drbd_receiver.c                                  =
   |    4 +-
>  drivers/bluetooth/Kconfig                                           =
   |   15 +
>  drivers/bluetooth/Makefile                                          =
   |    1 +
>  drivers/bluetooth/ath3k.c                                           =
   |    6 +
>  drivers/bluetooth/bt3c_cs.c                                         =
   |    3 +-
>  drivers/bluetooth/btbcm.c                                           =
   |  138 +-
>  drivers/bluetooth/btbcm.h                                           =
   |   61 +-
>  drivers/bluetooth/btintel.c                                         =
   |    6 -
>  drivers/bluetooth/btmrvl_sdio.c                                     =
   |    2 +-
>  drivers/bluetooth/btrtl.c                                           =
   |  390 +++++
>  drivers/bluetooth/btrtl.h                                           =
   |   52 +
>  drivers/bluetooth/btusb.c                                           =
   |  572 ++------
>  drivers/bluetooth/btwilink.c                                        =
   |    2 +-
>  drivers/bluetooth/hci_ath.c                                         =
   |    1 +
>  drivers/bluetooth/hci_bcm.c                                         =
   |  107 +-
>  drivers/bluetooth/hci_bcsp.c                                        =
   |   20 +-
>  drivers/bluetooth/hci_h4.c                                          =
   |    1 +
>  drivers/bluetooth/hci_ldisc.c                                       =
   |  123 ++
>  drivers/bluetooth/hci_uart.h                                        =
   |   11 +
>  drivers/bluetooth/hci_vhci.c                                        =
   |    2 +-
>  drivers/clk/qcom/gcc-ipq806x.c                                      =
   |  594 +++++++-
>  drivers/infiniband/hw/cxgb4/provider.c                              =
   |    8 +-
>  drivers/infiniband/hw/mlx4/alias_GUID.c                             =
   |    7 +-
>  drivers/infiniband/hw/mlx4/mad.c                                    =
   |   49 +-
>  drivers/infiniband/hw/mlx4/main.c                                   =
   |  118 +-
>  drivers/infiniband/hw/mlx4/mlx4_ib.h                                =
   |    8 +-
>  drivers/infiniband/hw/mlx4/qp.c                                     =
   |    7 +-
>  drivers/infiniband/hw/mlx5/Kconfig                                  =
   |    4 +-
>  drivers/infiniband/hw/mlx5/cq.c                                     =
   |   11 +-
>  drivers/infiniband/hw/mlx5/mad.c                                    =
   |  299 +++-
>  drivers/infiniband/hw/mlx5/main.c                                   =
   |  646 ++++++---
>  drivers/infiniband/hw/mlx5/mlx5_ib.h                                =
   |   23 +-
>  drivers/infiniband/hw/mlx5/mr.c                                     =
   |    3 +-
>  drivers/infiniband/hw/mlx5/odp.c                                    =
   |   47 +-
>  drivers/infiniband/hw/mlx5/qp.c                                     =
   |   89 +-
>  drivers/infiniband/hw/mlx5/srq.c                                    =
   |   11 +-
>  drivers/isdn/capi/capidrv.c                                         =
   |    4 +-
>  drivers/isdn/hisax/Kconfig                                          =
   |    4 +-
>  drivers/isdn/hisax/st5481_usb.c                                     =
   |    4 +-
>  drivers/isdn/mISDN/socket.c                                         =
   |   12 +-
>  drivers/mfd/janz-cmodio.c                                           =
   |    4 +
>  drivers/net/Kconfig                                                 =
   |   14 +
>  drivers/net/Makefile                                                =
   |    1 +
>  drivers/net/arcnet/Kconfig                                          =
   |    4 -
>  drivers/net/bonding/bond_3ad.c                                      =
   |   26 +-
>  drivers/net/bonding/bond_main.c                                     =
   |   55 +-
>  drivers/net/bonding/bond_netlink.c                                  =
   |   66 +-
>  drivers/net/bonding/bond_options.c                                  =
   |   91 ++
>  drivers/net/bonding/bond_procfs.c                                   =
   |   93 +-
>  drivers/net/bonding/bond_sysfs.c                                    =
   |   52 +-
>  drivers/net/bonding/bond_sysfs_slave.c                              =
   |   32 +
>  drivers/net/can/dev.c                                               =
   |    5 +
>  drivers/net/can/flexcan.c                                           =
   |   53 +-
>  drivers/net/can/janz-ican3.c                                        =
   |  125 +-
>  drivers/net/can/slcan.c                                             =
   |    1 +
>  drivers/net/can/spi/mcp251x.c                                       =
   |    9 +-
>  drivers/net/can/vcan.c                                              =
   |    3 +
>  drivers/net/dsa/Kconfig                                             =
   |   12 +-
>  drivers/net/dsa/bcm_sf2.c                                           =
   |   14 +-
>  drivers/net/dsa/mv88e6123_61_65.c                                   =
   |  186 +--
>  drivers/net/dsa/mv88e6131.c                                         =
   |  185 +--
>  drivers/net/dsa/mv88e6171.c                                         =
   |  234 +--
>  drivers/net/dsa/mv88e6352.c                                         =
   |  188 +--
>  drivers/net/dsa/mv88e6xxx.c                                         =
   |  980 +++++++++++--
>  drivers/net/dsa/mv88e6xxx.h                                         =
   |  112 +-
>  drivers/net/ethernet/3com/Kconfig                                   =
   |   18 +-
>  drivers/net/ethernet/8390/Kconfig                                   =
   |   26 +-
>  drivers/net/ethernet/Kconfig                                        =
   |    2 +
>  drivers/net/ethernet/Makefile                                       =
   |    2 +
>  drivers/net/ethernet/adaptec/Kconfig                                =
   |    4 +-
>  drivers/net/ethernet/adi/Kconfig                                    =
   |    2 -
>  drivers/net/ethernet/agere/Kconfig                                  =
   |    4 +-
>  drivers/net/ethernet/allwinner/Kconfig                              =
   |    3 +-
>  drivers/net/ethernet/alteon/Kconfig                                 =
   |    4 +-
>  drivers/net/ethernet/amd/Kconfig                                    =
   |   20 +-
>  drivers/net/ethernet/amd/xgbe/xgbe-common.h                         =
   |  155 ++
>  drivers/net/ethernet/amd/xgbe/xgbe-dcb.c                            =
   |   17 +-
>  drivers/net/ethernet/amd/xgbe/xgbe-desc.c                           =
   |   35 +-
>  drivers/net/ethernet/amd/xgbe/xgbe-dev.c                            =
   |   99 +-
>  drivers/net/ethernet/amd/xgbe/xgbe-drv.c                            =
   |  341 ++---
>  drivers/net/ethernet/amd/xgbe/xgbe-ethtool.c                        =
   |   79 +-
>  drivers/net/ethernet/amd/xgbe/xgbe-main.c                           =
   |  384 ++++-
>  drivers/net/ethernet/amd/xgbe/xgbe-mdio.c                           =
   | 1332 +++++++++++++++--
>  drivers/net/ethernet/amd/xgbe/xgbe.h                                =
   |  236 ++-
>  drivers/net/ethernet/apm/xgene/Makefile                             =
   |    2 +-
>  drivers/net/ethernet/apm/xgene/xgene_enet_hw.c                      =
   |   43 +-
>  drivers/net/ethernet/apm/xgene/xgene_enet_hw.h                      =
   |    8 +-
>  drivers/net/ethernet/apm/xgene/xgene_enet_main.c                    =
   |  257 +++-
>  drivers/net/ethernet/apm/xgene/xgene_enet_main.h                    =
   |   30 +-
>  drivers/net/ethernet/apm/xgene/xgene_enet_ring2.c                   =
   |  200 +++
>  drivers/net/ethernet/apm/xgene/xgene_enet_ring2.h                   =
   |   49 +
>  drivers/net/ethernet/apm/xgene/xgene_enet_sgmac.c                   =
   |   73 +-
>  drivers/net/ethernet/apm/xgene/xgene_enet_xgmac.c                   =
   |   12 +-
>  drivers/net/ethernet/apm/xgene/xgene_enet_xgmac.h                   =
   |   20 +
>  drivers/net/ethernet/apple/Kconfig                                  =
   |    7 +-
>  drivers/net/ethernet/arc/Kconfig                                    =
   |    4 +-
>  drivers/net/ethernet/atheros/Kconfig                                =
   |    4 +-
>  drivers/net/ethernet/broadcom/Kconfig                               =
   |    3 +-
>  drivers/net/ethernet/broadcom/b44.h                                 =
   |    8 +-
>  drivers/net/ethernet/broadcom/bcmsysport.c                          =
   |  170 ++-
>  drivers/net/ethernet/broadcom/bcmsysport.h                          =
   |    4 +-
>  drivers/net/ethernet/broadcom/bgmac.h                               =
   |    3 +-
>  drivers/net/ethernet/broadcom/bnx2x/bnx2x.h                         =
   |   16 +-
>  drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c                     =
   |   59 +-
>  drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h                     =
   |   31 +-
>  drivers/net/ethernet/broadcom/genet/bcmgenet.c                      =
   |   67 +
>  drivers/net/ethernet/broadcom/genet/bcmmii.c                        =
   |    7 +-
>  drivers/net/ethernet/broadcom/tg3.c                                 =
   |    2 +-
>  drivers/net/ethernet/brocade/Kconfig                                =
   |    4 +-
>  drivers/net/ethernet/brocade/bna/Makefile                           =
   |    2 -
>  drivers/net/ethernet/brocade/bna/bfa_cee.c                          =
   |    1 -
>  drivers/net/ethernet/brocade/bna/bfa_cs.h                           =
   |   14 -
>  drivers/net/ethernet/brocade/bna/bfa_defs.h                         =
   |   11 +-
>  drivers/net/ethernet/brocade/bna/bfa_defs_cna.h                     =
   |   16 +-
>  drivers/net/ethernet/brocade/bna/bfa_defs_mfg_comm.h                =
   |   10 +-
>  drivers/net/ethernet/brocade/bna/bfa_ioc.c                          =
   |   71 +-
>  drivers/net/ethernet/brocade/bna/bfa_ioc.h                          =
   |   23 +-
>  drivers/net/ethernet/brocade/bna/bfa_ioc_ct.c                       =
   |  101 +-
>  drivers/net/ethernet/brocade/bna/bfa_msgq.c                         =
   |   10 +-
>  drivers/net/ethernet/brocade/bna/bfi.h                              =
   |   84 +-
>  drivers/net/ethernet/brocade/bna/bfi_cna.h                          =
   |   30 +-
>  drivers/net/ethernet/brocade/bna/bfi_enet.h                         =
   |  176 ++-
>  drivers/net/ethernet/brocade/bna/bna.h                              =
   |  199 +--
>  drivers/net/ethernet/brocade/bna/bna_enet.c                         =
   |  101 +-
>  drivers/net/ethernet/brocade/bna/bna_hw_defs.h                      =
   |   70 +-
>  drivers/net/ethernet/brocade/bna/bna_tx_rx.c                        =
   |  673 +++------
>  drivers/net/ethernet/brocade/bna/bna_types.h                        =
   |   19 -
>  drivers/net/ethernet/brocade/bna/bnad.c                             =
   |  119 +-
>  drivers/net/ethernet/brocade/bna/bnad.h                             =
   |    4 +-
>  drivers/net/ethernet/brocade/bna/bnad_debugfs.c                     =
   |   67 +-
>  drivers/net/ethernet/brocade/bna/bnad_ethtool.c                     =
   |   15 +-
>  drivers/net/ethernet/brocade/bna/cna.h                              =
   |   62 -
>  drivers/net/ethernet/brocade/bna/cna_fwimg.c                        =
   |    2 +-
>  drivers/net/ethernet/cadence/Kconfig                                =
   |    2 -
>  drivers/net/ethernet/cadence/macb.c                                 =
   |   61 +-
>  drivers/net/ethernet/cadence/macb.h                                 =
   |    9 +
>  drivers/net/ethernet/cavium/Kconfig                                 =
   |   57 +
>  drivers/net/ethernet/cavium/Makefile                                =
   |    5 +
>  drivers/net/ethernet/cavium/liquidio/Makefile                       =
   |   16 +
>  drivers/net/ethernet/cavium/liquidio/cn66xx_device.c                =
   |  796 +++++++++++
>  drivers/net/ethernet/cavium/liquidio/cn66xx_device.h                =
   |  107 ++
>  drivers/net/ethernet/cavium/liquidio/cn66xx_regs.h                  =
   |  535 +++++++
>  drivers/net/ethernet/cavium/liquidio/cn68xx_device.c                =
   |  198 +++
>  drivers/net/ethernet/cavium/liquidio/cn68xx_device.h                =
   |   33 +
>  drivers/net/ethernet/cavium/liquidio/cn68xx_regs.h                  =
   |   51 +
>  drivers/net/ethernet/cavium/liquidio/lio_ethtool.c                  =
   | 1216 ++++++++++++++++
>  drivers/net/ethernet/cavium/liquidio/lio_main.c                     =
   | 3668 +++++++++++++++++++++++++++++++++++++++++++++++
>  drivers/net/ethernet/cavium/liquidio/liquidio_common.h              =
   |  673 +++++++++
>  drivers/net/ethernet/cavium/liquidio/liquidio_image.h               =
   |   57 +
>  drivers/net/ethernet/cavium/liquidio/octeon_config.h                =
   |  424 ++++++
>  drivers/net/ethernet/cavium/liquidio/octeon_console.c               =
   |  723 ++++++++++
>  drivers/net/ethernet/cavium/liquidio/octeon_device.c                =
   | 1309 +++++++++++++++++
>  drivers/net/ethernet/cavium/liquidio/octeon_device.h                =
   |  649 +++++++++
>  drivers/net/ethernet/cavium/liquidio/octeon_droq.c                  =
   |  989 +++++++++++++
>  drivers/net/ethernet/cavium/liquidio/octeon_droq.h                  =
   |  426 ++++++
>  drivers/net/ethernet/cavium/liquidio/octeon_iq.h                    =
   |  319 +++++
>  drivers/net/ethernet/cavium/liquidio/octeon_main.h                  =
   |  237 ++++
>  drivers/net/ethernet/cavium/liquidio/octeon_mem_ops.c               =
   |  199 +++
>  drivers/net/ethernet/cavium/liquidio/octeon_mem_ops.h               =
   |   75 +
>  drivers/net/ethernet/cavium/liquidio/octeon_network.h               =
   |  224 +++
>  drivers/net/ethernet/cavium/liquidio/octeon_nic.c                   =
   |  189 +++
>  drivers/net/ethernet/cavium/liquidio/octeon_nic.h                   =
   |  227 +++
>  drivers/net/ethernet/cavium/liquidio/request_manager.c              =
   |  766 ++++++++++
>  drivers/net/ethernet/cavium/liquidio/response_manager.c             =
   |  178 +++
>  drivers/net/ethernet/cavium/liquidio/response_manager.h             =
   |  140 ++
>  drivers/net/ethernet/cavium/thunder/Makefile                        =
   |   11 +
>  drivers/net/ethernet/cavium/thunder/nic.h                           =
   |  423 ++++++
>  drivers/net/ethernet/cavium/thunder/nic_main.c                      =
   |  932 ++++++++++++
>  drivers/net/ethernet/cavium/thunder/nic_reg.h                       =
   |  213 +++
>  drivers/net/ethernet/cavium/thunder/nicvf_ethtool.c                 =
   |  600 ++++++++
>  drivers/net/ethernet/cavium/thunder/nicvf_main.c                    =
   | 1341 ++++++++++++++++++
>  drivers/net/ethernet/cavium/thunder/nicvf_queues.c                  =
   | 1545 ++++++++++++++++++++
>  drivers/net/ethernet/cavium/thunder/nicvf_queues.h                  =
   |  381 +++++
>  drivers/net/ethernet/cavium/thunder/q_struct.h                      =
   |  701 +++++++++
>  drivers/net/ethernet/cavium/thunder/thunder_bgx.c                   =
   |  966 +++++++++++++
>  drivers/net/ethernet/cavium/thunder/thunder_bgx.h                   =
   |  220 +++
>  drivers/net/ethernet/chelsio/Kconfig                                =
   |    4 +-
>  drivers/net/ethernet/chelsio/cxgb3/cxgb3_main.c                     =
   |   12 +-
>  drivers/net/ethernet/chelsio/cxgb4/cxgb4.h                          =
   |  220 ++-
>  drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c                  =
   |  363 ++++-
>  drivers/net/ethernet/chelsio/cxgb4/cxgb4_ethtool.c                  =
   |  294 +++-
>  drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c                     =
   |  489 ++++---
>  drivers/net/ethernet/chelsio/cxgb4/cxgb4_uld.h                      =
   |    3 +-
>  drivers/net/ethernet/chelsio/cxgb4/sge.c                            =
   |  382 ++---
>  drivers/net/ethernet/chelsio/cxgb4/t4_hw.c                          =
   | 2215 ++++++++++++++++++++++-------
>  drivers/net/ethernet/chelsio/cxgb4/t4_hw.h                          =
   |   38 +-
>  drivers/net/ethernet/chelsio/cxgb4/t4_msg.h                         =
   |   86 +-
>  drivers/net/ethernet/chelsio/cxgb4/t4_pci_id_tbl.h                  =
   |    2 +
>  drivers/net/ethernet/chelsio/cxgb4/t4_regs.h                        =
   |  184 +++
>  drivers/net/ethernet/chelsio/cxgb4/t4_values.h                      =
   |   24 +
>  drivers/net/ethernet/chelsio/cxgb4/t4fw_api.h                       =
   |   72 +-
>  drivers/net/ethernet/chelsio/cxgb4/t4fw_version.h                   =
   |    5 +
>  drivers/net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c                 =
   |   13 +-
>  drivers/net/ethernet/chelsio/cxgb4vf/sge.c                          =
   |  123 +-
>  drivers/net/ethernet/chelsio/cxgb4vf/t4vf_common.h                  =
   |   18 +-
>  drivers/net/ethernet/chelsio/cxgb4vf/t4vf_hw.c                      =
   |   36 +-
>  drivers/net/ethernet/cirrus/Kconfig                                 =
   |   12 +-
>  drivers/net/ethernet/cisco/Kconfig                                  =
   |    4 +-
>  drivers/net/ethernet/cisco/enic/enic_clsf.c                         =
   |   31 +-
>  drivers/net/ethernet/cisco/enic/enic_ethtool.c                      =
   |   10 +-
>  drivers/net/ethernet/dec/Kconfig                                    =
   |    4 +-
>  drivers/net/ethernet/dec/tulip/Kconfig                              =
   |   10 +-
>  drivers/net/ethernet/dec/tulip/de4x5.c                              =
   |   10 +-
>  drivers/net/ethernet/dec/tulip/uli526x.c                            =
   |    2 +-
>  drivers/net/ethernet/dlink/Kconfig                                  =
   |    4 +-
>  drivers/net/ethernet/dlink/dl2k.c                                   =
   |    4 +-
>  drivers/net/ethernet/emulex/Kconfig                                 =
   |    4 +-
>  drivers/net/ethernet/emulex/benet/Kconfig                           =
   |    9 +
>  drivers/net/ethernet/emulex/benet/be.h                              =
   |   55 +-
>  drivers/net/ethernet/emulex/benet/be_cmds.c                         =
   |   56 +-
>  drivers/net/ethernet/emulex/benet/be_cmds.h                         =
   |   50 +-
>  drivers/net/ethernet/emulex/benet/be_ethtool.c                      =
   |   11 +-
>  drivers/net/ethernet/emulex/benet/be_hw.h                           =
   |   14 +-
>  drivers/net/ethernet/emulex/benet/be_main.c                         =
   |  502 +++++--
>  drivers/net/ethernet/emulex/benet/be_roce.c                         =
   |    2 +-
>  drivers/net/ethernet/emulex/benet/be_roce.h                         =
   |    2 +-
>  drivers/net/ethernet/ezchip/Kconfig                                 =
   |   26 +
>  drivers/net/ethernet/ezchip/Makefile                                =
   |    1 +
>  drivers/net/ethernet/ezchip/nps_enet.c                              =
   |  658 +++++++++
>  drivers/net/ethernet/ezchip/nps_enet.h                              =
   |  336 +++++
>  drivers/net/ethernet/faraday/Kconfig                                =
   |    4 +-
>  drivers/net/ethernet/freescale/Kconfig                              =
   |    4 +-
>  drivers/net/ethernet/freescale/fec_main.c                           =
   |   82 +-
>  drivers/net/ethernet/freescale/fec_ptp.c                            =
   |    1 +
>  drivers/net/ethernet/freescale/fs_enet/fs_enet-main.c               =
   |   33 +-
>  drivers/net/ethernet/freescale/gianfar.c                            =
   |   53 +-
>  drivers/net/ethernet/fujitsu/Kconfig                                =
   |    4 +-
>  drivers/net/ethernet/hisilicon/Kconfig                              =
   |    4 +-
>  drivers/net/ethernet/hisilicon/hip04_eth.c                          =
   |    2 +-
>  drivers/net/ethernet/hisilicon/hix5hd2_gmac.c                       =
   |    1 -
>  drivers/net/ethernet/hp/Kconfig                                     =
   |    8 +-
>  drivers/net/ethernet/i825xx/Kconfig                                 =
   |    4 +-
>  drivers/net/ethernet/ibm/Kconfig                                    =
   |    4 +-
>  drivers/net/ethernet/ibm/emac/core.c                                =
   |   10 +-
>  drivers/net/ethernet/ibm/ibmveth.c                                  =
   |   41 +-
>  drivers/net/ethernet/ibm/ibmveth.h                                  =
   |    5 +-
>  drivers/net/ethernet/intel/Kconfig                                  =
   |    4 +-
>  drivers/net/ethernet/intel/e100.c                                   =
   |    6 +-
>  drivers/net/ethernet/intel/e1000/e1000_main.c                       =
   |   19 +-
>  drivers/net/ethernet/intel/e1000e/80003es2lan.c                     =
   |    2 +-
>  drivers/net/ethernet/intel/e1000e/80003es2lan.h                     =
   |    2 +-
>  drivers/net/ethernet/intel/e1000e/82571.c                           =
   |    4 +-
>  drivers/net/ethernet/intel/e1000e/82571.h                           =
   |    2 +-
>  drivers/net/ethernet/intel/e1000e/defines.h                         =
   |    2 +-
>  drivers/net/ethernet/intel/e1000e/e1000.h                           =
   |    8 +-
>  drivers/net/ethernet/intel/e1000e/ethtool.c                         =
   |   29 +-
>  drivers/net/ethernet/intel/e1000e/hw.h                              =
   |    2 +-
>  drivers/net/ethernet/intel/e1000e/ich8lan.c                         =
   |   26 +-
>  drivers/net/ethernet/intel/e1000e/ich8lan.h                         =
   |   11 +-
>  drivers/net/ethernet/intel/e1000e/mac.c                             =
   |    2 +-
>  drivers/net/ethernet/intel/e1000e/mac.h                             =
   |    2 +-
>  drivers/net/ethernet/intel/e1000e/manage.c                          =
   |    2 +-
>  drivers/net/ethernet/intel/e1000e/manage.h                          =
   |    2 +-
>  drivers/net/ethernet/intel/e1000e/netdev.c                          =
   |  205 ++-
>  drivers/net/ethernet/intel/e1000e/nvm.c                             =
   |    2 +-
>  drivers/net/ethernet/intel/e1000e/nvm.h                             =
   |    2 +-
>  drivers/net/ethernet/intel/e1000e/param.c                           =
   |    2 +-
>  drivers/net/ethernet/intel/e1000e/phy.c                             =
   |    2 +-
>  drivers/net/ethernet/intel/e1000e/phy.h                             =
   |    2 +-
>  drivers/net/ethernet/intel/e1000e/ptp.c                             =
   |    2 +-
>  drivers/net/ethernet/intel/e1000e/regs.h                            =
   |    4 +-
>  drivers/net/ethernet/intel/fm10k/fm10k_ethtool.c                    =
   |    5 +-
>  drivers/net/ethernet/intel/fm10k/fm10k_iov.c                        =
   |   38 +-
>  drivers/net/ethernet/intel/fm10k/fm10k_main.c                       =
   |   66 +-
>  drivers/net/ethernet/intel/fm10k/fm10k_mbx.c                        =
   |    5 -
>  drivers/net/ethernet/intel/fm10k/fm10k_netdev.c                     =
   |   11 +-
>  drivers/net/ethernet/intel/fm10k/fm10k_pci.c                        =
   |   27 +-
>  drivers/net/ethernet/intel/fm10k/fm10k_pf.c                         =
   |   18 +-
>  drivers/net/ethernet/intel/fm10k/fm10k_pf.h                         =
   |    8 +-
>  drivers/net/ethernet/intel/fm10k/fm10k_ptp.c                        =
   |   13 +-
>  drivers/net/ethernet/intel/fm10k/fm10k_type.h                       =
   |    2 +-
>  drivers/net/ethernet/intel/i40e/i40e.h                              =
   |    5 +-
>  drivers/net/ethernet/intel/i40e/i40e_ethtool.c                      =
   |   30 +-
>  drivers/net/ethernet/intel/i40e/i40e_fcoe.c                         =
   |   11 +-
>  drivers/net/ethernet/intel/i40e/i40e_main.c                         =
   |   43 +-
>  drivers/net/ethernet/intel/i40e/i40e_txrx.c                         =
   |  146 +-
>  drivers/net/ethernet/intel/i40e/i40e_txrx.h                         =
   |    2 +-
>  drivers/net/ethernet/intel/i40e/i40e_type.h                         =
   |    1 +
>  drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c                  =
   |    7 +
>  drivers/net/ethernet/intel/i40evf/i40e_txrx.c                       =
   |  160 +--
>  drivers/net/ethernet/intel/i40evf/i40e_txrx.h                       =
   |    2 +-
>  drivers/net/ethernet/intel/i40evf/i40e_type.h                       =
   |    1 +
>  drivers/net/ethernet/intel/igb/igb_main.c                           =
   |   38 +-
>  drivers/net/ethernet/intel/ixgbe/ixgbe.h                            =
   |    1 +
>  drivers/net/ethernet/intel/ixgbe/ixgbe_82598.c                      =
   |    3 +-
>  drivers/net/ethernet/intel/ixgbe/ixgbe_82599.c                      =
   |    7 +-
>  drivers/net/ethernet/intel/ixgbe/ixgbe_common.c                     =
   |   63 +-
>  drivers/net/ethernet/intel/ixgbe/ixgbe_common.h                     =
   |    2 +
>  drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c                    =
   |   51 +-
>  drivers/net/ethernet/intel/ixgbe/ixgbe_main.c                       =
   |  161 ++-
>  drivers/net/ethernet/intel/ixgbe/ixgbe_phy.c                        =
   |   91 +-
>  drivers/net/ethernet/intel/ixgbe/ixgbe_phy.h                        =
   |    1 +
>  drivers/net/ethernet/intel/ixgbe/ixgbe_type.h                       =
   |  272 +++-
>  drivers/net/ethernet/intel/ixgbe/ixgbe_x540.c                       =
   |   46 +-
>  drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c                       =
   | 1000 +++++++++----
>  drivers/net/ethernet/marvell/Kconfig                                =
   |    4 +-
>  drivers/net/ethernet/marvell/mv643xx_eth.c                          =
   |    9 +-
>  drivers/net/ethernet/marvell/mvneta.c                               =
   |    8 +-
>  drivers/net/ethernet/mellanox/Kconfig                               =
   |    4 +-
>  drivers/net/ethernet/mellanox/mlx4/cmd.c                            =
   |  110 +-
>  drivers/net/ethernet/mellanox/mlx4/cq.c                             =
   |   13 +-
>  drivers/net/ethernet/mellanox/mlx4/en_cq.c                          =
   |   56 +-
>  drivers/net/ethernet/mellanox/mlx4/en_ethtool.c                     =
   |   17 +
>  drivers/net/ethernet/mellanox/mlx4/en_netdev.c                      =
   |   30 +-
>  drivers/net/ethernet/mellanox/mlx4/en_port.c                        =
   |   29 +-
>  drivers/net/ethernet/mellanox/mlx4/en_resources.c                   =
   |    2 +-
>  drivers/net/ethernet/mellanox/mlx4/en_rx.c                          =
   |   13 +-
>  drivers/net/ethernet/mellanox/mlx4/eq.c                             =
   |  400 ++++--
>  drivers/net/ethernet/mellanox/mlx4/main.c                           =
   |  266 +++-
>  drivers/net/ethernet/mellanox/mlx4/mlx4.h                           =
   |   17 +-
>  drivers/net/ethernet/mellanox/mlx4/mlx4_en.h                        =
   |    4 +-
>  drivers/net/ethernet/mellanox/mlx4/mlx4_stats.h                     =
   |   10 +-
>  drivers/net/ethernet/mellanox/mlx4/profile.c                        =
   |    8 +-
>  drivers/net/ethernet/mellanox/mlx4/qp.c                             =
   |    9 +-
>  drivers/net/ethernet/mellanox/mlx4/resource_tracker.c               =
   |  208 ++-
>  drivers/net/ethernet/mellanox/mlx5/core/Kconfig                     =
   |   14 +-
>  drivers/net/ethernet/mellanox/mlx5/core/Makefile                    =
   |    5 +-
>  drivers/net/ethernet/mellanox/mlx5/core/alloc.c                     =
   |   96 +-
>  drivers/net/ethernet/mellanox/mlx5/core/cmd.c                       =
   |   36 +-
>  drivers/net/ethernet/mellanox/mlx5/core/cq.c                        =
   |   18 +
>  drivers/net/ethernet/mellanox/mlx5/core/en.h                        =
   |  521 +++++++
>  drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c                =
   |  679 +++++++++
>  drivers/net/ethernet/mellanox/mlx5/core/en_flow_table.c             =
   |  860 +++++++++++
>  drivers/net/ethernet/mellanox/mlx5/core/en_main.c                   =
   | 1915 +++++++++++++++++++++++++
>  drivers/net/ethernet/mellanox/mlx5/core/en_rx.c                     =
   |  252 ++++
>  drivers/net/ethernet/mellanox/mlx5/core/en_tx.c                     =
   |  350 +++++
>  drivers/net/ethernet/mellanox/mlx5/core/en_txrx.c                   =
   |  105 ++
>  drivers/net/ethernet/mellanox/mlx5/core/eq.c                        =
   |   23 +-
>  drivers/net/ethernet/mellanox/mlx5/core/flow_table.c                =
   |  422 ++++++
>  drivers/net/ethernet/mellanox/mlx5/core/fw.c                        =
   |  146 +-
>  drivers/net/ethernet/mellanox/mlx5/core/main.c                      =
   |  343 +++--
>  drivers/net/ethernet/mellanox/mlx5/core/mcg.c                       =
   |    2 +-
>  drivers/net/ethernet/mellanox/mlx5/core/mlx5_core.h                 =
   |   21 +-
>  drivers/net/ethernet/mellanox/mlx5/core/port.c                      =
   |  226 +++
>  drivers/net/ethernet/mellanox/mlx5/core/qp.c                        =
   |    7 +
>  drivers/net/ethernet/mellanox/mlx5/core/srq.c                       =
   |  444 +++++-
>  drivers/net/ethernet/mellanox/mlx5/core/transobj.c                  =
   |  360 +++++
>  drivers/net/ethernet/mellanox/mlx5/core/transobj.h                  =
   |   64 +
>  drivers/net/ethernet/mellanox/mlx5/core/uar.c                       =
   |   44 +-
>  drivers/net/ethernet/mellanox/mlx5/core/vport.c                     =
   |  345 +++++
>  drivers/net/ethernet/mellanox/mlx5/core/wq.c                        =
   |  183 +++
>  drivers/net/ethernet/mellanox/mlx5/core/wq.h                        =
   |  171 +++
>  drivers/net/ethernet/micrel/Kconfig                                 =
   |    4 +-
>  drivers/net/ethernet/micrel/ksz884x.c                               =
   |    4 +-
>  drivers/net/ethernet/microchip/Kconfig                              =
   |    4 +-
>  drivers/net/ethernet/moxa/Kconfig                                   =
   |    4 +-
>  drivers/net/ethernet/moxa/moxart_ether.c                            =
   |    1 -
>  drivers/net/ethernet/myricom/Kconfig                                =
   |    4 +-
>  drivers/net/ethernet/natsemi/Kconfig                                =
   |    7 +-
>  drivers/net/ethernet/neterion/Kconfig                               =
   |    4 +-
>  drivers/net/ethernet/neterion/s2io.c                                =
   |    6 +-
>  drivers/net/ethernet/neterion/vxge/vxge-traffic.c                   =
   |    7 +-
>  drivers/net/ethernet/nuvoton/Kconfig                                =
   |    4 +-
>  drivers/net/ethernet/nvidia/Kconfig                                 =
   |    8 +-
>  drivers/net/ethernet/oki-semi/Kconfig                               =
   |    4 +-
>  drivers/net/ethernet/packetengines/Kconfig                          =
   |    8 +-
>  drivers/net/ethernet/pasemi/Kconfig                                 =
   |    4 +-
>  drivers/net/ethernet/qlogic/Kconfig                                 =
   |    4 +-
>  drivers/net/ethernet/qlogic/qlcnic/qlcnic.h                         =
   |    3 -
>  drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c                    =
   |    2 +-
>  drivers/net/ethernet/qlogic/qlcnic/qlcnic_sysfs.c                   =
   |   77 +-
>  drivers/net/ethernet/qlogic/qlge/qlge_main.c                        =
   |    4 +-
>  drivers/net/ethernet/qualcomm/Kconfig                               =
   |    4 +-
>  drivers/net/ethernet/qualcomm/qca_spi.c                             =
   |   46 +-
>  drivers/net/ethernet/rdc/Kconfig                                    =
   |    4 +-
>  drivers/net/ethernet/realtek/Kconfig                                =
   |   14 +-
>  drivers/net/ethernet/renesas/Kconfig                                =
   |   29 +
>  drivers/net/ethernet/renesas/Makefile                               =
   |    4 +
>  drivers/net/ethernet/renesas/ravb.h                                 =
   |  832 +++++++++++
>  drivers/net/ethernet/renesas/ravb_main.c                            =
   | 1824 ++++++++++++++++++++++++
>  drivers/net/ethernet/renesas/ravb_ptp.c                             =
   |  357 +++++
>  drivers/net/ethernet/rocker/rocker.c                                =
   | 1615 ++++++++++++---------
>  drivers/net/ethernet/rocker/rocker.h                                =
   |   28 +-
>  drivers/net/ethernet/seeq/Kconfig                                   =
   |    4 +-
>  drivers/net/ethernet/sfc/Kconfig                                    =
   |    9 +
>  drivers/net/ethernet/sfc/Makefile                                   =
   |    2 +-
>  drivers/net/ethernet/sfc/ef10.c                                     =
   | 1147 ++++++++++++---
>  drivers/net/ethernet/sfc/ef10_sriov.c                               =
   |  783 ++++++++++
>  drivers/net/ethernet/sfc/ef10_sriov.h                               =
   |   69 +
>  drivers/net/ethernet/sfc/efx.c                                      =
   |  317 +++--
>  drivers/net/ethernet/sfc/efx.h                                      =
   |   15 +
>  drivers/net/ethernet/sfc/enum.h                                     =
   |    2 +
>  drivers/net/ethernet/sfc/ethtool.c                                  =
   |    7 +-
>  drivers/net/ethernet/sfc/falcon.c                                   =
   |   33 +-
>  drivers/net/ethernet/sfc/farch.c                                    =
   |   64 +-
>  drivers/net/ethernet/sfc/mcdi.c                                     =
   |  228 ++-
>  drivers/net/ethernet/sfc/mcdi.h                                     =
   |   16 +-
>  drivers/net/ethernet/sfc/mcdi_pcol.h                                =
   |  434 +++++-
>  drivers/net/ethernet/sfc/mcdi_port.c                                =
   |   13 +-
>  drivers/net/ethernet/sfc/net_driver.h                               =
   |   34 +-
>  drivers/net/ethernet/sfc/nic.h                                      =
   |  251 ++--
>  drivers/net/ethernet/sfc/ptp.c                                      =
   |   40 +-
>  drivers/net/ethernet/sfc/siena.c                                    =
   |   27 +-
>  drivers/net/ethernet/sfc/siena_sriov.c                              =
   |  156 +-
>  drivers/net/ethernet/sfc/siena_sriov.h                              =
   |   79 ++
>  drivers/net/ethernet/sfc/sriov.c                                    =
   |   83 ++
>  drivers/net/ethernet/sfc/sriov.h                                    =
   |   31 +
>  drivers/net/ethernet/sgi/Kconfig                                    =
   |    8 +-
>  drivers/net/ethernet/silan/Kconfig                                  =
   |    4 +-
>  drivers/net/ethernet/sis/Kconfig                                    =
   |    4 +-
>  drivers/net/ethernet/smsc/Kconfig                                   =
   |   18 +-
>  drivers/net/ethernet/stmicro/Kconfig                                =
   |    4 +-
>  drivers/net/ethernet/stmicro/stmmac/Kconfig                         =
   |   90 ++
>  drivers/net/ethernet/stmicro/stmmac/Makefile                        =
   |   14 +-
>  drivers/net/ethernet/stmicro/stmmac/descs.h                         =
   |    2 +
>  drivers/net/ethernet/stmicro/stmmac/dwmac-generic.c                 =
   |   41 +
>  drivers/net/ethernet/stmicro/stmmac/dwmac-ipq806x.c                 =
   |  365 +++++
>  drivers/net/ethernet/stmicro/stmmac/dwmac-lpc18xx.c                 =
   |   99 ++
>  drivers/net/ethernet/stmicro/stmmac/dwmac-meson.c                   =
   |   24 +-
>  drivers/net/ethernet/stmicro/stmmac/dwmac-rk.c                      =
   |  350 +++--
>  drivers/net/ethernet/stmicro/stmmac/dwmac-socfpga.c                 =
   |   21 +-
>  drivers/net/ethernet/stmicro/stmmac/dwmac-sti.c                     =
   |   29 +-
>  drivers/net/ethernet/stmicro/stmmac/dwmac-sunxi.c                   =
   |   25 +-
>  drivers/net/ethernet/stmicro/stmmac/enh_desc.c                      =
   |    3 +-
>  drivers/net/ethernet/stmicro/stmmac/norm_desc.c                     =
   |    3 +-
>  drivers/net/ethernet/stmicro/stmmac/stmmac.h                        =
   |   14 +-
>  drivers/net/ethernet/stmicro/stmmac/stmmac_main.c                   =
   |  108 +-
>  drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c                    =
   |   19 +-
>  drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c               =
   |  129 +-
>  drivers/net/ethernet/stmicro/stmmac/stmmac_platform.h               =
   |    9 +-
>  drivers/net/ethernet/sun/Kconfig                                    =
   |    4 +-
>  drivers/net/ethernet/tehuti/Kconfig                                 =
   |    4 +-
>  drivers/net/ethernet/ti/Kconfig                                     =
   |    8 +-
>  drivers/net/ethernet/ti/cpsw.c                                      =
   |    9 +-
>  drivers/net/ethernet/ti/cpsw_ale.c                                  =
   |   45 -
>  drivers/net/ethernet/ti/cpsw_ale.h                                  =
   |    2 -
>  drivers/net/ethernet/ti/netcp_core.c                                =
   |    3 +-
>  drivers/net/ethernet/tile/tilepro.c                                 =
   |    3 -
>  drivers/net/ethernet/toshiba/Kconfig                                =
   |    4 +-
>  drivers/net/ethernet/toshiba/ps3_gelic_net.c                        =
   |   24 +-
>  drivers/net/ethernet/toshiba/spider_net.c                           =
   |    3 +-
>  drivers/net/ethernet/tundra/Kconfig                                 =
   |    4 +-
>  drivers/net/ethernet/via/Kconfig                                    =
   |    8 +-
>  drivers/net/ethernet/via/via-rhine.c                                =
   |  250 ++--
>  drivers/net/ethernet/wiznet/Kconfig                                 =
   |    4 +-
>  drivers/net/ethernet/xilinx/Kconfig                                 =
   |    4 +-
>  drivers/net/ethernet/xilinx/ll_temac_main.c                         =
   |   16 +-
>  drivers/net/ethernet/xilinx/xilinx_axienet.h                        =
   |  108 +-
>  drivers/net/ethernet/xilinx/xilinx_axienet_main.c                   =
   |  288 ++--
>  drivers/net/ethernet/xilinx/xilinx_axienet_mdio.c                   =
   |   30 +-
>  drivers/net/ethernet/xircom/Kconfig                                 =
   |    4 +-
>  drivers/net/ethernet/xscale/Kconfig                                 =
   |    4 +-
>  drivers/net/fddi/skfp/srf.c                                         =
   |    2 +-
>  drivers/net/geneve.c                                                =
   |  523 +++++++
>  drivers/net/hamradio/bpqether.c                                     =
   |    1 -
>  drivers/net/hyperv/hyperv_net.h                                     =
   |   10 +
>  drivers/net/hyperv/netvsc.c                                         =
   |   54 +-
>  drivers/net/hyperv/netvsc_drv.c                                     =
   |   97 +-
>  drivers/net/hyperv/rndis_filter.c                                   =
   |   16 +-
>  drivers/net/ieee802154/Kconfig                                      =
   |   10 +
>  drivers/net/ieee802154/Makefile                                     =
   |    1 +
>  drivers/net/ieee802154/at86rf230.c                                  =
   |  488 +++----
>  drivers/net/ieee802154/at86rf230.h                                  =
   |  220 +++
>  drivers/net/ieee802154/atusb.c                                      =
   |  762 ++++++++++
>  drivers/net/ieee802154/atusb.h                                      =
   |   84 ++
>  drivers/net/ieee802154/cc2520.c                                     =
   |  153 +-
>  drivers/net/ieee802154/fakelb.c                                     =
   |  212 ++-
>  drivers/net/ieee802154/mrf24j40.c                                   =
   |   12 +-
>  drivers/net/ipvlan/ipvlan.h                                         =
   |    5 +
>  drivers/net/ipvlan/ipvlan_core.c                                    =
   |  138 +-
>  drivers/net/ipvlan/ipvlan_main.c                                    =
   |   25 +-
>  drivers/net/irda/irda-usb.c                                         =
   |    4 +-
>  drivers/net/macvtap.c                                               =
   |   44 +-
>  drivers/net/phy/Kconfig                                             =
   |   13 +-
>  drivers/net/phy/Makefile                                            =
   |    2 +-
>  drivers/net/phy/amd-xgbe-phy.c                                      =
   | 1901 -------------------------
>  drivers/net/phy/bcm7xxx.c                                           =
   |    7 +-
>  drivers/net/phy/davicom.c                                           =
   |   13 +
>  drivers/net/phy/dp83867.c                                           =
   |  239 ++++
>  drivers/net/phy/icplus.c                                            =
   |    5 +-
>  drivers/net/phy/marvell.c                                           =
   |   10 +-
>  drivers/net/phy/mdio-bcm-unimac.c                                   =
   |    8 +-
>  drivers/net/phy/mdio-bitbang.c                                      =
   |    7 +-
>  drivers/net/phy/mdio-gpio.c                                         =
   |    1 +
>  drivers/net/phy/micrel.c                                            =
   |   53 +-
>  drivers/net/phy/phy.c                                               =
   |   34 +-
>  drivers/net/phy/realtek.c                                           =
   |   68 +-
>  drivers/net/ppp/pppoe.c                                             =
   |    4 +-
>  drivers/net/ppp/pppox.c                                             =
   |    2 +-
>  drivers/net/ppp/pptp.c                                              =
   |    6 +-
>  drivers/net/team/team.c                                             =
   |   10 +-
>  drivers/net/tun.c                                                   =
   |   26 +-
>  drivers/net/vmxnet3/vmxnet3_defs.h                                  =
   |   38 +-
>  drivers/net/vmxnet3/vmxnet3_drv.c                                   =
   |  164 ++-
>  drivers/net/vmxnet3/vmxnet3_int.h                                   =
   |    4 +
>  drivers/net/vxlan.c                                                 =
   |   10 +-
>  drivers/net/wan/cosa.c                                              =
   |    2 +-
>  drivers/net/wan/dscc4.c                                             =
   |    9 +-
>  drivers/net/wan/lapbether.c                                         =
   |    1 -
>  drivers/net/wireless/Kconfig                                        =
   |    1 +
>  drivers/net/wireless/Makefile                                       =
   |    2 +
>  drivers/net/wireless/adm8211.c                                      =
   |   35 +-
>  drivers/net/wireless/at76c50x-usb.c                                 =
   |    4 +-
>  drivers/net/wireless/at76c50x-usb.h                                 =
   |    2 +-
>  drivers/net/wireless/ath/ar5523/ar5523.c                            =
   |    9 +-
>  drivers/net/wireless/ath/ath.h                                      =
   |    2 +
>  drivers/net/wireless/ath/ath10k/Makefile                            =
   |    4 +-
>  drivers/net/wireless/ath/ath10k/core.c                              =
   |  182 ++-
>  drivers/net/wireless/ath/ath10k/core.h                              =
   |   65 +-
>  drivers/net/wireless/ath/ath10k/debug.c                             =
   |  127 +-
>  drivers/net/wireless/ath/ath10k/debug.h                             =
   |    1 +
>  drivers/net/wireless/ath/ath10k/htc.c                               =
   |   50 +-
>  drivers/net/wireless/ath/ath10k/htt.c                               =
   |   98 ++
>  drivers/net/wireless/ath/ath10k/htt.h                               =
   |  132 +-
>  drivers/net/wireless/ath/ath10k/htt_rx.c                            =
   |  208 +--
>  drivers/net/wireless/ath/ath10k/htt_tx.c                            =
   |   34 +-
>  drivers/net/wireless/ath/ath10k/hw.c                                =
   |   21 +
>  drivers/net/wireless/ath/ath10k/hw.h                                =
   |   59 +-
>  drivers/net/wireless/ath/ath10k/mac.c                               =
   | 2922 ++++++++++++++++++++++++++++----------
>  drivers/net/wireless/ath/ath10k/mac.h                               =
   |   29 +
>  drivers/net/wireless/ath/ath10k/p2p.c                               =
   |  156 ++
>  drivers/net/wireless/ath/ath10k/p2p.h                               =
   |   28 +
>  drivers/net/wireless/ath/ath10k/pci.c                               =
   |  362 +++--
>  drivers/net/wireless/ath/ath10k/pci.h                               =
   |   95 +-
>  drivers/net/wireless/ath/ath10k/rx_desc.h                           =
   |   22 +
>  drivers/net/wireless/ath/ath10k/spectral.c                          =
   |    5 +-
>  drivers/net/wireless/ath/ath10k/thermal.c                           =
   |  134 +-
>  drivers/net/wireless/ath/ath10k/thermal.h                           =
   |   10 +-
>  drivers/net/wireless/ath/ath10k/trace.h                             =
   |   22 +-
>  drivers/net/wireless/ath/ath10k/txrx.c                              =
   |    9 +-
>  drivers/net/wireless/ath/ath10k/wmi-ops.h                           =
   |  194 ++-
>  drivers/net/wireless/ath/ath10k/wmi-tlv.c                           =
   |  582 +++++++-
>  drivers/net/wireless/ath/ath10k/wmi-tlv.h                           =
   |  168 +++
>  drivers/net/wireless/ath/ath10k/wmi.c                               =
   |  312 ++--
>  drivers/net/wireless/ath/ath10k/wmi.h                               =
   |  229 ++-
>  drivers/net/wireless/ath/ath10k/wow.c                               =
   |  321 +++++
>  drivers/net/wireless/ath/ath10k/wow.h                               =
   |   40 +
>  drivers/net/wireless/ath/ath5k/ath5k.h                              =
   |    1 -
>  drivers/net/wireless/ath/ath5k/base.c                               =
   |   12 +-
>  drivers/net/wireless/ath/ath5k/led.c                                =
   |    2 +-
>  drivers/net/wireless/ath/ath5k/mac80211-ops.c                       =
   |   16 +-
>  drivers/net/wireless/ath/ath6kl/cfg80211.c                          =
   |    4 +-
>  drivers/net/wireless/ath/ath6kl/wmi.h                               =
   |    2 +-
>  drivers/net/wireless/ath/ath9k/ar5008_phy.c                         =
   |  155 +-
>  drivers/net/wireless/ath/ath9k/ar9002_phy.c                         =
   |  144 +-
>  drivers/net/wireless/ath/ath9k/common-spectral.c                    =
   |  740 ++++++++--
>  drivers/net/wireless/ath/ath9k/common-spectral.h                    =
   |   35 +-
>  drivers/net/wireless/ath/ath9k/htc.h                                =
   |    8 +-
>  drivers/net/wireless/ath/ath9k/htc_drv_beacon.c                     =
   |   19 +
>  drivers/net/wireless/ath/ath9k/htc_drv_init.c                       =
   |   25 +-
>  drivers/net/wireless/ath/ath9k/htc_drv_main.c                       =
   |   20 +-
>  drivers/net/wireless/ath/ath9k/htc_drv_txrx.c                       =
   |    9 +-
>  drivers/net/wireless/ath/ath9k/hw.h                                 =
   |    2 +
>  drivers/net/wireless/ath/ath9k/init.c                               =
   |   24 +-
>  drivers/net/wireless/ath/ath9k/main.c                               =
   |   15 +-
>  drivers/net/wireless/ath/ath9k/recv.c                               =
   |    5 -
>  drivers/net/wireless/ath/carl9170/fw.c                              =
   |    5 +-
>  drivers/net/wireless/ath/carl9170/led.c                             =
   |    2 +-
>  drivers/net/wireless/ath/carl9170/main.c                            =
   |   27 +-
>  drivers/net/wireless/ath/carl9170/usb.c                             =
   |    5 +-
>  drivers/net/wireless/ath/dfs_pattern_detector.c                     =
   |   72 +-
>  drivers/net/wireless/ath/dfs_pattern_detector.h                     =
   |    4 +
>  drivers/net/wireless/ath/dfs_pri_detector.c                         =
   |    4 +
>  drivers/net/wireless/ath/wcn36xx/main.c                             =
   |   12 +-
>  drivers/net/wireless/ath/wcn36xx/smd.c                              =
   |    4 +-
>  drivers/net/wireless/ath/wil6210/Makefile                           =
   |    1 +
>  drivers/net/wireless/ath/wil6210/cfg80211.c                         =
   |  174 ++-
>  drivers/net/wireless/ath/wil6210/debugfs.c                          =
   |  115 +-
>  drivers/net/wireless/ath/wil6210/main.c                             =
   |   33 +-
>  drivers/net/wireless/ath/wil6210/netdev.c                           =
   |    8 +-
>  drivers/net/wireless/ath/wil6210/pcie_bus.c                         =
   |  105 +-
>  drivers/net/wireless/ath/wil6210/pmc.c                              =
   |  375 +++++
>  drivers/net/wireless/ath/wil6210/pmc.h                              =
   |   27 +
>  drivers/net/wireless/ath/wil6210/txrx.c                             =
   |   50 +-
>  drivers/net/wireless/ath/wil6210/txrx.h                             =
   |   24 +-
>  drivers/net/wireless/ath/wil6210/wil6210.h                          =
   |   33 +-
>  drivers/net/wireless/ath/wil6210/wil_platform.c                     =
   |   14 +-
>  drivers/net/wireless/ath/wil6210/wil_platform.h                     =
   |    3 +
>  drivers/net/wireless/ath/wil6210/wmi.c                              =
   |   75 +-
>  drivers/net/wireless/ath/wil6210/wmi.h                              =
   |   50 +-
>  drivers/net/wireless/b43/main.c                                     =
   |   16 +-
>  drivers/net/wireless/b43legacy/main.c                               =
   |   13 +-
>  drivers/net/wireless/brcm80211/brcmfmac/bcmsdh.c                    =
   |   37 +-
>  drivers/net/wireless/brcm80211/brcmfmac/cfg80211.c                  =
   |  521 ++++---
>  drivers/net/wireless/brcm80211/brcmfmac/chip.c                      =
   |    1 +
>  drivers/net/wireless/brcm80211/brcmfmac/commonring.c                =
   |   37 +-
>  drivers/net/wireless/brcm80211/brcmfmac/commonring.h                =
   |    3 +-
>  drivers/net/wireless/brcm80211/brcmfmac/core.c                      =
   |    4 +-
>  drivers/net/wireless/brcm80211/brcmfmac/debug.c                     =
   |   50 +-
>  drivers/net/wireless/brcm80211/brcmfmac/feature.c                   =
   |    2 +
>  drivers/net/wireless/brcm80211/brcmfmac/feature.h                   =
   |    8 +-
>  drivers/net/wireless/brcm80211/brcmfmac/firmware.c                  =
   |  251 +++-
>  drivers/net/wireless/brcm80211/brcmfmac/firmware.h                  =
   |    6 +
>  drivers/net/wireless/brcm80211/brcmfmac/flowring.c                  =
   |    5 +-
>  drivers/net/wireless/brcm80211/brcmfmac/flowring.h                  =
   |    4 +-
>  drivers/net/wireless/brcm80211/brcmfmac/fwil_types.h                =
   |   79 +-
>  drivers/net/wireless/brcm80211/brcmfmac/fwsignal.c                  =
   |    2 +-
>  drivers/net/wireless/brcm80211/brcmfmac/msgbuf.c                    =
   |   32 +-
>  drivers/net/wireless/brcm80211/brcmfmac/of.c                        =
   |   11 +-
>  drivers/net/wireless/brcm80211/brcmfmac/p2p.c                       =
   |  203 +--
>  drivers/net/wireless/brcm80211/brcmfmac/pcie.c                      =
   |  200 ++-
>  drivers/net/wireless/brcm80211/brcmfmac/sdio.c                      =
   |   17 +-
>  drivers/net/wireless/brcm80211/brcmfmac/usb.c                       =
   |    9 +-
>  drivers/net/wireless/brcm80211/brcmsmac/mac80211_if.c               =
   |   12 +-
>  drivers/net/wireless/brcm80211/brcmsmac/main.c                      =
   |    2 +-
>  drivers/net/wireless/brcm80211/include/brcm_hw_ids.h                =
   |    3 +
>  drivers/net/wireless/cw1200/main.c                                  =
   |   16 +-
>  drivers/net/wireless/cw1200/sta.c                                   =
   |   10 +-
>  drivers/net/wireless/iwlegacy/3945-mac.c                            =
   |   10 +-
>  drivers/net/wireless/iwlegacy/4965-mac.c                            =
   |   16 +-
>  drivers/net/wireless/iwlwifi/Kconfig                                =
   |   12 +-
>  drivers/net/wireless/iwlwifi/Makefile                               =
   |    1 +
>  drivers/net/wireless/iwlwifi/dvm/mac80211.c                         =
   |   33 +-
>  drivers/net/wireless/iwlwifi/iwl-7000.c                             =
   |   25 +-
>  drivers/net/wireless/iwlwifi/iwl-8000.c                             =
   |   71 +-
>  drivers/net/wireless/iwlwifi/iwl-config.h                           =
   |   45 +
>  drivers/net/wireless/iwlwifi/iwl-devtrace-iwlwifi.h                 =
   |   15 +-
>  drivers/net/wireless/iwlwifi/iwl-drv.c                              =
   |   32 +-
>  drivers/net/wireless/iwlwifi/iwl-fh.h                               =
   |    6 -
>  drivers/net/wireless/iwlwifi/iwl-fw-error-dump.h                    =
   |    6 +-
>  drivers/net/wireless/iwlwifi/iwl-fw-file.h                          =
   |  107 +-
>  drivers/net/wireless/iwlwifi/iwl-fw.h                               =
   |   24 +-
>  drivers/net/wireless/iwlwifi/iwl-nvm-parse.c                        =
   |    2 +-
>  drivers/net/wireless/iwlwifi/iwl-prph.h                             =
   |    3 +
>  drivers/net/wireless/iwlwifi/iwl-trans.c                            =
   |  113 ++
>  drivers/net/wireless/iwlwifi/iwl-trans.h                            =
   |   22 +-
>  drivers/net/wireless/iwlwifi/mvm/coex.c                             =
   |  103 +-
>  drivers/net/wireless/iwlwifi/mvm/d3.c                               =
   |   22 +-
>  drivers/net/wireless/iwlwifi/mvm/debugfs-vif.c                      =
   |   21 +-
>  drivers/net/wireless/iwlwifi/mvm/debugfs.c                          =
   |   14 +-
>  drivers/net/wireless/iwlwifi/mvm/fw-api-scan.h                      =
   |   91 +-
>  drivers/net/wireless/iwlwifi/mvm/fw-api.h                           =
   |   63 +-
>  drivers/net/wireless/iwlwifi/mvm/fw.c                               =
   |   23 +-
>  drivers/net/wireless/iwlwifi/mvm/mac-ctxt.c                         =
   |    4 +-
>  drivers/net/wireless/iwlwifi/mvm/mac80211.c                         =
   |  443 +++---
>  drivers/net/wireless/iwlwifi/mvm/mvm.h                              =
   |  162 +--
>  drivers/net/wireless/iwlwifi/mvm/nvm.c                              =
   |   16 +-
>  drivers/net/wireless/iwlwifi/mvm/ops.c                              =
   |   37 +-
>  drivers/net/wireless/iwlwifi/mvm/rs.c                               =
   |   44 +-
>  drivers/net/wireless/iwlwifi/mvm/rs.h                               =
   |    2 -
>  drivers/net/wireless/iwlwifi/mvm/rx.c                               =
   |    4 +-
>  drivers/net/wireless/iwlwifi/mvm/scan.c                             =
   | 1418 +++++++++---------
>  drivers/net/wireless/iwlwifi/mvm/sta.c                              =
   |   14 +-
>  drivers/net/wireless/iwlwifi/mvm/time-event.c                       =
   |   33 +-
>  drivers/net/wireless/iwlwifi/mvm/tt.c                               =
   |   40 +-
>  drivers/net/wireless/iwlwifi/mvm/tx.c                               =
   |   35 +-
>  drivers/net/wireless/iwlwifi/mvm/utils.c                            =
   |    2 +-
>  drivers/net/wireless/iwlwifi/pcie/drv.c                             =
   |   17 +-
>  drivers/net/wireless/iwlwifi/pcie/internal.h                        =
   |   51 +-
>  drivers/net/wireless/iwlwifi/pcie/rx.c                              =
   |  415 ++++--
>  drivers/net/wireless/iwlwifi/pcie/trans.c                           =
   |  135 +-
>  drivers/net/wireless/iwlwifi/pcie/tx.c                              =
   |    2 -
>  drivers/net/wireless/libertas/cfg.c                                 =
   |   13 +-
>  drivers/net/wireless/libertas/cfg.h                                 =
   |    3 +-
>  drivers/net/wireless/libertas/cmd.h                                 =
   |    3 +-
>  drivers/net/wireless/libertas/cmdresp.c                             =
   |   13 +-
>  drivers/net/wireless/libertas_tf/main.c                             =
   |    9 +-
>  drivers/net/wireless/mac80211_hwsim.c                               =
   |   77 +-
>  drivers/net/wireless/mediatek/Kconfig                               =
   |   10 +
>  drivers/net/wireless/mediatek/Makefile                              =
   |    1 +
>  drivers/net/wireless/mediatek/mt7601u/Kconfig                       =
   |    6 +
>  drivers/net/wireless/mediatek/mt7601u/Makefile                      =
   |    9 +
>  drivers/net/wireless/mediatek/mt7601u/core.c                        =
   |   78 +
>  drivers/net/wireless/mediatek/mt7601u/debugfs.c                     =
   |  172 +++
>  drivers/net/wireless/mediatek/mt7601u/dma.c                         =
   |  505 +++++++
>  drivers/net/wireless/mediatek/mt7601u/dma.h                         =
   |  127 ++
>  drivers/net/wireless/mediatek/mt7601u/eeprom.c                      =
   |  418 ++++++
>  drivers/net/wireless/mediatek/mt7601u/eeprom.h                      =
   |  151 ++
>  drivers/net/wireless/mediatek/mt7601u/init.c                        =
   |  628 ++++++++
>  drivers/net/wireless/mediatek/mt7601u/initvals.h                    =
   |  164 +++
>  drivers/net/wireless/mediatek/mt7601u/initvals_phy.h                =
   |  291 ++++
>  drivers/net/wireless/mediatek/mt7601u/mac.c                         =
   |  573 ++++++++
>  drivers/net/wireless/mediatek/mt7601u/mac.h                         =
   |  178 +++
>  drivers/net/wireless/mediatek/mt7601u/main.c                        =
   |  413 ++++++
>  drivers/net/wireless/mediatek/mt7601u/mcu.c                         =
   |  534 +++++++
>  drivers/net/wireless/mediatek/mt7601u/mcu.h                         =
   |   94 ++
>  drivers/net/wireless/mediatek/mt7601u/mt7601u.h                     =
   |  390 +++++
>  drivers/net/wireless/mediatek/mt7601u/phy.c                         =
   | 1251 ++++++++++++++++
>  drivers/net/wireless/mediatek/mt7601u/regs.h                        =
   |  636 +++++++++
>  drivers/net/wireless/mediatek/mt7601u/trace.c                       =
   |   21 +
>  drivers/net/wireless/mediatek/mt7601u/trace.h                       =
   |  400 ++++++
>  drivers/net/wireless/mediatek/mt7601u/tx.c                          =
   |  319 +++++
>  drivers/net/wireless/mediatek/mt7601u/usb.c                         =
   |  367 +++++
>  drivers/net/wireless/mediatek/mt7601u/usb.h                         =
   |   77 +
>  drivers/net/wireless/mediatek/mt7601u/util.c                        =
   |   42 +
>  drivers/net/wireless/mediatek/mt7601u/util.h                        =
   |   77 +
>  drivers/net/wireless/mwifiex/11h.c                                  =
   |   72 +-
>  drivers/net/wireless/mwifiex/11n.c                                  =
   |  128 +-
>  drivers/net/wireless/mwifiex/11n_aggr.c                             =
   |    7 +-
>  drivers/net/wireless/mwifiex/11n_rxreorder.c                        =
   |  136 +-
>  drivers/net/wireless/mwifiex/Kconfig                                =
   |    2 +
>  drivers/net/wireless/mwifiex/README                                 =
   |    6 +-
>  drivers/net/wireless/mwifiex/cfg80211.c                             =
   |  592 +++++---
>  drivers/net/wireless/mwifiex/cfp.c                                  =
   |   50 +-
>  drivers/net/wireless/mwifiex/cmdevt.c                               =
   |  368 +++--
>  drivers/net/wireless/mwifiex/debugfs.c                              =
   |  165 ++-
>  drivers/net/wireless/mwifiex/decl.h                                 =
   |    7 +-
>  drivers/net/wireless/mwifiex/ethtool.c                              =
   |   97 --
>  drivers/net/wireless/mwifiex/fw.h                                   =
   |   71 +-
>  drivers/net/wireless/mwifiex/ie.c                                   =
   |  102 +-
>  drivers/net/wireless/mwifiex/init.c                                 =
   |   54 +-
>  drivers/net/wireless/mwifiex/ioctl.h                                =
   |    7 +
>  drivers/net/wireless/mwifiex/join.c                                 =
   |  254 ++--
>  drivers/net/wireless/mwifiex/main.c                                 =
   |  224 ++-
>  drivers/net/wireless/mwifiex/main.h                                 =
   |   96 +-
>  drivers/net/wireless/mwifiex/pcie.c                                 =
   |  589 ++++----
>  drivers/net/wireless/mwifiex/scan.c                                 =
   |  377 ++---
>  drivers/net/wireless/mwifiex/sdio.c                                 =
   |  458 +++---
>  drivers/net/wireless/mwifiex/sta_cmd.c                              =
   |  159 ++-
>  drivers/net/wireless/mwifiex/sta_cmdresp.c                          =
   |  223 +--
>  drivers/net/wireless/mwifiex/sta_event.c                            =
   |  194 ++-
>  drivers/net/wireless/mwifiex/sta_ioctl.c                            =
   |  147 +-
>  drivers/net/wireless/mwifiex/sta_rx.c                               =
   |   13 +-
>  drivers/net/wireless/mwifiex/sta_tx.c                               =
   |   18 +-
>  drivers/net/wireless/mwifiex/tdls.c                                 =
   |   86 +-
>  drivers/net/wireless/mwifiex/txrx.c                                 =
   |   51 +-
>  drivers/net/wireless/mwifiex/uap_cmd.c                              =
   |   75 +-
>  drivers/net/wireless/mwifiex/uap_event.c                            =
   |  112 +-
>  drivers/net/wireless/mwifiex/uap_txrx.c                             =
   |   54 +-
>  drivers/net/wireless/mwifiex/usb.c                                  =
   |  141 +-
>  drivers/net/wireless/mwifiex/util.c                                 =
   |   84 +-
>  drivers/net/wireless/mwifiex/wmm.c                                  =
   |  107 +-
>  drivers/net/wireless/mwl8k.c                                        =
   |   11 +-
>  drivers/net/wireless/p54/fwio.c                                     =
   |    3 +-
>  drivers/net/wireless/p54/led.c                                      =
   |    2 +-
>  drivers/net/wireless/p54/main.c                                     =
   |   18 +-
>  drivers/net/wireless/ray_cs.c                                       =
   |    2 +-
>  drivers/net/wireless/rndis_wlan.c                                   =
   |    8 +-
>  drivers/net/wireless/rsi/rsi_91x_mac80211.c                         =
   |    7 +-
>  drivers/net/wireless/rt2x00/rt2400pci.c                             =
   |   12 +-
>  drivers/net/wireless/rt2x00/rt2500pci.c                             =
   |   12 +-
>  drivers/net/wireless/rt2x00/rt2500usb.c                             =
   |   13 +-
>  drivers/net/wireless/rt2x00/rt2800.h                                =
   |   10 +
>  drivers/net/wireless/rt2x00/rt2800lib.c                             =
   |   92 +-
>  drivers/net/wireless/rt2x00/rt2800lib.h                             =
   |    5 +-
>  drivers/net/wireless/rt2x00/rt2800pci.c                             =
   |    2 +-
>  drivers/net/wireless/rt2x00/rt2800soc.c                             =
   |    2 +-
>  drivers/net/wireless/rt2x00/rt2800usb.c                             =
   |    2 +-
>  drivers/net/wireless/rt2x00/rt2x00mac.c                             =
   |   22 +-
>  drivers/net/wireless/rt2x00/rt61pci.c                               =
   |   13 +-
>  drivers/net/wireless/rt2x00/rt73usb.c                               =
   |   13 +-
>  drivers/net/wireless/rtl818x/rtl8180/dev.c                          =
   |    9 +-
>  drivers/net/wireless/rtl818x/rtl8187/dev.c                          =
   |    6 +-
>  drivers/net/wireless/rtlwifi/Kconfig                                =
   |    2 +-
>  drivers/net/wireless/rtlwifi/base.c                                 =
   |   22 +-
>  drivers/net/wireless/rtlwifi/btcoexist/halbtc8723b2ant.c            =
   |    7 +-
>  drivers/net/wireless/rtlwifi/core.h                                 =
   |    3 +-
>  drivers/net/wireless/rtlwifi/regd.c                                 =
   |   42 +-
>  drivers/net/wireless/rtlwifi/regd.h                                 =
   |    1 +
>  drivers/net/wireless/rtlwifi/rtl8188ee/dm.c                         =
   |    7 +-
>  drivers/net/wireless/rtlwifi/rtl8188ee/hw.c                         =
   |   20 +-
>  drivers/net/wireless/rtlwifi/rtl8188ee/pwrseq.c                     =
   |    2 +-
>  drivers/net/wireless/rtlwifi/rtl8188ee/pwrseq.h                     =
   |    2 +-
>  drivers/net/wireless/rtlwifi/rtl8192c/dm_common.c                   =
   |    7 +-
>  drivers/net/wireless/rtlwifi/rtl8192c/fw_common.c                   =
   |    3 +-
>  drivers/net/wireless/rtlwifi/rtl8192cu/hw.c                         =
   |   54 +-
>  drivers/net/wireless/rtlwifi/rtl8192cu/mac.c                        =
   |   17 +-
>  drivers/net/wireless/rtlwifi/rtl8192cu/mac.h                        =
   |    5 +-
>  drivers/net/wireless/rtlwifi/rtl8192cu/phy.c                        =
   |   28 +-
>  drivers/net/wireless/rtlwifi/rtl8192cu/rf.c                         =
   |   22 +-
>  drivers/net/wireless/rtlwifi/rtl8192cu/trx.c                        =
   |    2 +-
>  drivers/net/wireless/rtlwifi/rtl8192de/dm.c                         =
   |    7 +-
>  drivers/net/wireless/rtlwifi/rtl8192ee/fw.c                         =
   |    2 +-
>  drivers/net/wireless/rtlwifi/rtl8192ee/hw.c                         =
   |   21 +-
>  drivers/net/wireless/rtlwifi/rtl8192se/dm.c                         =
   |    7 +-
>  drivers/net/wireless/rtlwifi/rtl8723ae/hw.c                         =
   |   13 -
>  drivers/net/wireless/rtlwifi/rtl8723be/dm.c                         =
   |    7 +-
>  drivers/net/wireless/rtlwifi/rtl8723be/fw.c                         =
   |    2 +-
>  drivers/net/wireless/rtlwifi/rtl8723be/hw.c                         =
   |   21 +-
>  drivers/net/wireless/rtlwifi/rtl8821ae/dm.c                         =
   |   14 +-
>  drivers/net/wireless/rtlwifi/rtl8821ae/hw.c                         =
   |   24 +-
>  drivers/net/wireless/rtlwifi/wifi.h                                 =
   |    1 +
>  drivers/net/wireless/ti/wl1251/acx.c                                =
   |    3 -
>  drivers/net/wireless/ti/wl1251/main.c                               =
   |   12 +-
>  drivers/net/wireless/ti/wl18xx/main.c                               =
   |   71 +-
>  drivers/net/wireless/ti/wl18xx/reg.h                                =
   |    1 +
>  drivers/net/wireless/ti/wlcore/main.c                               =
   |   54 +-
>  drivers/net/wireless/zd1211rw/zd_mac.c                              =
   |   12 +-
>  drivers/net/xen-netback/netback.c                                   =
   |   21 +-
>  drivers/net/xen-netback/xenbus.c                                    =
   |    4 +
>  drivers/net/xen-netfront.c                                          =
   |    7 +-
>  drivers/nfc/Kconfig                                                 =
   |    2 +-
>  drivers/nfc/Makefile                                                =
   |    4 +-
>  drivers/nfc/microread/i2c.c                                         =
   |    3 -
>  drivers/nfc/nfcmrvl/Kconfig                                         =
   |   11 +
>  drivers/nfc/nfcmrvl/Makefile                                        =
   |    3 +
>  drivers/nfc/nfcmrvl/main.c                                          =
   |  134 +-
>  drivers/nfc/nfcmrvl/nfcmrvl.h                                       =
   |   60 +-
>  drivers/nfc/nfcmrvl/uart.c                                          =
   |  225 +++
>  drivers/nfc/nfcmrvl/usb.c                                           =
   |   27 +-
>  drivers/nfc/nxp-nci/Makefile                                        =
   |    2 -
>  drivers/nfc/nxp-nci/i2c.c                                           =
   |   52 +
>  drivers/nfc/pn544/i2c.c                                             =
   |   43 +-
>  drivers/nfc/st-nci/Kconfig                                          =
   |   23 +
>  drivers/nfc/st-nci/Makefile                                         =
   |    9 +
>  drivers/nfc/st-nci/core.c                                           =
   |  179 +++
>  drivers/nfc/{st21nfcb =3D> st-nci}/i2c.c                            =
     |  147 +-
>  drivers/nfc/{st21nfcb =3D> st-nci}/ndlc.c                           =
     |   23 +-
>  drivers/nfc/{st21nfcb =3D> st-nci}/ndlc.h                           =
     |    5 +-
>  drivers/nfc/{st21nfcb/st21nfcb.h =3D> st-nci/st-nci.h}              =
     |   30 +-
>  drivers/nfc/{st21nfcb/st21nfcb_se.c =3D> st-nci/st-nci_se.c}        =
     |  383 ++---
>  drivers/nfc/st-nci/st-nci_se.h                                      =
   |   61 +
>  drivers/nfc/st21nfcb/Kconfig                                        =
   |   22 -
>  drivers/nfc/st21nfcb/Makefile                                       =
   |    9 -
>  drivers/nfc/st21nfcb/st21nfcb.c                                     =
   |  143 --
>  drivers/nfc/st21nfcb/st21nfcb_se.h                                  =
   |   61 -
>  drivers/nfc/trf7970a.c                                              =
   |   23 +-
>  drivers/of/of_mdio.c                                                =
   |    3 +
>  drivers/s390/net/lcs.c                                              =
   |    2 +-
>  drivers/s390/net/qeth_core.h                                        =
   |    2 +
>  drivers/s390/net/qeth_core_main.c                                   =
   |    3 +-
>  drivers/s390/net/qeth_core_mpc.c                                    =
   |    3 +-
>  drivers/s390/net/qeth_core_mpc.h                                    =
   |    3 +-
>  drivers/s390/net/qeth_l2_main.c                                     =
   |  124 +-
>  drivers/s390/net/qeth_l2_sys.c                                      =
   |   74 +-
>  drivers/s390/net/qeth_l3_main.c                                     =
   |    9 +-
>  drivers/scsi/cxgbi/libcxgbi.c                                       =
   |    2 +-
>  drivers/scsi/qla2xxx/tcm_qla2xxx.c                                  =
   |    1 +
>  drivers/scsi/qla4xxx/ql4_def.h                                      =
   |    1 +
>  drivers/staging/rtl8723au/os_dep/ioctl_cfg80211.c                   =
   |    2 +-
>  drivers/staging/vt6655/device_main.c                                =
   |   19 +-
>  drivers/staging/vt6656/main_usb.c                                   =
   |   19 +-
>  drivers/staging/wlan-ng/cfg80211.c                                  =
   |    2 +-
>  drivers/target/iscsi/iscsi_target.c                                 =
   |    1 +
>  drivers/target/target_core_file.c                                   =
   |    1 +
>  drivers/target/target_core_pr.c                                     =
   |    1 +
>  drivers/target/target_core_transport.c                              =
   |    1 +
>  drivers/target/target_core_user.c                                   =
   |    1 +
>  drivers/vhost/scsi.c                                                =
   |    1 +
>  fs/afs/rxrpc.c                                                      =
   |    2 +-
>  fs/dlm/lowcomms.c                                                   =
   |   16 +-
>  fs/splice.c                                                         =
   |    1 +
>  include/dt-bindings/clock/qcom,gcc-ipq806x.h                        =
   |    2 +
>  include/dt-bindings/net/ti-dp83867.h                                =
   |   45 +
>  include/dt-bindings/reset/qcom,gcc-ipq806x.h                        =
   |   43 +
>  include/linux/bcma/bcma.h                                           =
   |    9 +
>  include/linux/bcma/bcma_driver_pci.h                                =
   |   11 +
>  include/linux/bpf.h                                                 =
   |   36 +-
>  include/linux/brcmphy.h                                             =
   |    7 +
>  include/linux/etherdevice.h                                         =
   |   42 +-
>  include/linux/filter.h                                              =
   |   30 +-
>  include/linux/gfp.h                                                 =
   |    5 +
>  include/linux/ieee802154.h                                          =
   |   16 +-
>  include/linux/if_link.h                                             =
   |    9 +
>  include/linux/if_macvlan.h                                          =
   |    2 +-
>  include/linux/if_pppox.h                                            =
   |    2 +-
>  include/linux/if_vlan.h                                             =
   |   28 +-
>  include/linux/igmp.h                                                =
   |    1 +
>  include/linux/inet_diag.h                                           =
   |    1 +
>  include/linux/inetdevice.h                                          =
   |    3 +
>  include/linux/mdio-gpio.h                                           =
   |    3 +-
>  include/linux/mlx4/cmd.h                                            =
   |    6 +
>  include/linux/mlx4/device.h                                         =
   |   21 +-
>  include/linux/mlx5/cq.h                                             =
   |    3 +
>  include/linux/mlx5/device.h                                         =
   |  215 ++-
>  include/linux/mlx5/driver.h                                         =
   |  171 ++-
>  include/linux/mlx5/flow_table.h                                     =
   |   54 +
>  include/linux/mlx5/mlx5_ifc.h                                       =
   | 6622 +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++=
++++++++++++++++++++++--
>  include/linux/mlx5/qp.h                                             =
   |   25 +
>  include/linux/mlx5/vport.h                                          =
   |   55 +
>  include/linux/mm_types.h                                            =
   |   18 +
>  include/linux/net.h                                                 =
   |    3 +-
>  include/linux/netdev_features.h                                     =
   |    5 +-
>  include/linux/netdevice.h                                           =
   |   31 +-
>  include/linux/netfilter.h                                           =
   |   45 +-
>  include/linux/netfilter/ipset/ip_set.h                              =
   |   61 +-
>  include/linux/netfilter/ipset/ip_set_comment.h                      =
   |   38 +-
>  include/linux/netfilter/ipset/ip_set_timeout.h                      =
   |   27 +-
>  include/linux/netfilter/x_tables.h                                  =
   |   60 +-
>  include/linux/netfilter_bridge.h                                    =
   |    7 -
>  include/linux/netfilter_defs.h                                      =
   |    9 +
>  include/linux/netfilter_ingress.h                                   =
   |   41 +
>  include/linux/netfilter_ipv6.h                                      =
   |    3 +
>  include/linux/netlink.h                                             =
   |    2 +
>  include/linux/pci_ids.h                                             =
   |    2 +
>  include/linux/phy.h                                                 =
   |   14 +
>  include/linux/platform_data/nfcmrvl.h                               =
   |   40 +
>  include/linux/platform_data/{st21nfcb.h =3D> st-nci.h}              =
     |   14 +-
>  include/linux/platform_data/st_nci.h                                =
   |   29 +
>  include/linux/rtnetlink.h                                           =
   |   16 +-
>  include/linux/skbuff.h                                              =
   |   77 +-
>  include/linux/sock_diag.h                                           =
   |   42 +
>  include/linux/spi/cc2520.h                                          =
   |    1 -
>  include/linux/stmmac.h                                              =
   |    1 +
>  include/linux/tcp.h                                                 =
   |   15 +-
>  include/linux/u64_stats_sync.h                                      =
   |    7 +-
>  include/net/addrconf.h                                              =
   |    1 +
>  include/net/af_unix.h                                               =
   |    1 -
>  include/net/af_vsock.h                                              =
   |    2 +-
>  include/net/bluetooth/bluetooth.h                                   =
   |   11 +
>  include/net/bluetooth/hci.h                                         =
   |   10 +
>  include/net/bluetooth/hci_core.h                                    =
   |   47 +-
>  include/net/bond_options.h                                          =
   |    3 +
>  include/net/bonding.h                                               =
   |    3 +
>  include/net/cfg80211.h                                              =
   |    8 +-
>  include/net/cfg802154.h                                             =
   |   70 +-
>  include/net/checksum.h                                              =
   |    4 +-
>  include/net/codel.h                                                 =
   |   12 +-
>  include/net/dst.h                                                   =
   |   18 -
>  include/net/fib_rules.h                                             =
   |    3 +-
>  include/net/flow_dissector.h                                        =
   |  220 +++
>  include/net/flow_keys.h                                             =
   |   45 -
>  include/net/geneve.h                                                =
   |    5 +
>  include/net/ieee802154_netdev.h                                     =
   |   34 +-
>  include/net/inet_common.h                                           =
   |    2 +-
>  include/net/inet_frag.h                                             =
   |    2 +-
>  include/net/inet_hashtables.h                                       =
   |   49 +-
>  include/net/inet_sock.h                                             =
   |    1 +
>  include/net/ip.h                                                    =
   |   43 +-
>  include/net/ip6_fib.h                                               =
   |   45 +-
>  include/net/ip6_route.h                                             =
   |   21 +-
>  include/net/ip_fib.h                                                =
   |   20 +-
>  include/net/ipv6.h                                                  =
   |   43 +-
>  include/net/llc_conn.h                                              =
   |    2 +-
>  include/net/mac80211.h                                              =
   |  265 ++--
>  include/net/mac802154.h                                             =
   |  160 ++-
>  include/net/net_namespace.h                                         =
   |    5 +
>  include/net/netfilter/br_netfilter.h                                =
   |   60 +
>  include/net/netfilter/nf_queue.h                                    =
   |    2 +
>  include/net/netfilter/nf_tables.h                                   =
   |   15 +
>  include/net/netns/ipv4.h                                            =
   |    3 +
>  include/net/netns/ipv6.h                                            =
   |    1 +
>  include/net/netns/netfilter.h                                       =
   |    4 +-
>  include/net/netns/nftables.h                                        =
   |    1 +
>  include/net/netns/sctp.h                                            =
   |    1 +
>  include/net/netns/x_tables.h                                        =
   |    2 +-
>  include/net/nfc/hci.h                                               =
   |    7 +
>  include/net/nfc/nci.h                                               =
   |    1 +
>  include/net/nfc/nci_core.h                                          =
   |   71 +
>  include/net/nfc/nfc.h                                               =
   |   22 +
>  include/net/nl802154.h                                              =
   |   85 +-
>  include/net/request_sock.h                                          =
   |    4 +-
>  include/net/sch_generic.h                                           =
   |   23 -
>  include/net/sctp/structs.h                                          =
   |    4 +
>  include/net/sock.h                                                  =
   |   32 +-
>  include/net/switchdev.h                                             =
   |  257 +++-
>  include/net/tcp.h                                                   =
   |   95 +-
>  include/uapi/linux/bpf.h                                            =
   |   43 +
>  include/uapi/linux/can.h                                            =
   |    6 +
>  include/uapi/linux/can/gw.h                                         =
   |    5 +
>  include/uapi/linux/dcbnl.h                                          =
   |   10 +-
>  include/uapi/linux/ethtool.h                                        =
   |   37 +-
>  include/uapi/linux/if_link.h                                        =
   |   29 +
>  include/uapi/linux/if_packet.h                                      =
   |    7 +
>  include/uapi/linux/in.h                                             =
   |    3 +
>  include/uapi/linux/inet_diag.h                                      =
   |    4 +-
>  include/uapi/linux/ip.h                                             =
   |    1 +
>  include/uapi/linux/ipv6_route.h                                     =
   |    1 +
>  include/uapi/linux/netfilter.h                                      =
   |    9 +-
>  include/uapi/linux/netfilter/ipset/ip_set.h                         =
   |    6 +-
>  include/uapi/linux/netfilter/nf_tables.h                            =
   |    2 +
>  include/uapi/linux/netfilter/nfnetlink_queue.h                      =
   |    4 +-
>  include/uapi/linux/netfilter/xt_socket.h                            =
   |    8 +
>  include/uapi/linux/netlink.h                                        =
   |   16 +-
>  include/uapi/linux/nfc.h                                            =
   |   10 +
>  include/uapi/linux/nl80211.h                                        =
   |   28 +-
>  include/uapi/linux/openvswitch.h                                    =
   |    4 +
>  include/uapi/linux/pkt_cls.h                                        =
   |   57 +-
>  include/uapi/linux/pkt_sched.h                                      =
   |    7 +-
>  include/uapi/linux/rds.h                                            =
   |   10 +
>  include/uapi/linux/rtnetlink.h                                      =
   |    3 +
>  include/uapi/linux/snmp.h                                           =
   |    2 +
>  include/uapi/linux/sock_diag.h                                      =
   |   10 +
>  include/uapi/linux/tcp.h                                            =
   |    6 +-
>  include/uapi/linux/tty.h                                            =
   |    1 +
>  kernel/bpf/arraymap.c                                               =
   |  113 +-
>  kernel/bpf/core.c                                                   =
   |  105 +-
>  kernel/bpf/helpers.c                                                =
   |  105 +-
>  kernel/bpf/syscall.c                                                =
   |   42 +-
>  kernel/bpf/verifier.c                                               =
   |   54 +-
>  kernel/seccomp.c                                                    =
   |   70 +-
>  kernel/trace/bpf_trace.c                                            =
   |   42 +-
>  lib/rhashtable.c                                                    =
   |    8 +-
>  lib/test_bpf.c                                                      =
   | 2972 +++++++++++++++++++++++++++++++++++---
>  lib/test_rhashtable.c                                               =
   |  215 +--
>  mm/page_alloc.c                                                     =
   |   98 ++
>  net/8021q/vlan.c                                                    =
   |   96 ++
>  net/Kconfig                                                         =
   |    3 +
>  net/appletalk/ddp.c                                                 =
   |    2 +-
>  net/atm/common.c                                                    =
   |    4 +-
>  net/atm/common.h                                                    =
   |    2 +-
>  net/atm/pvc.c                                                       =
   |    2 +-
>  net/atm/svc.c                                                       =
   |    2 +-
>  net/ax25/af_ax25.c                                                  =
   |    5 +-
>  net/ax25/ax25_in.c                                                  =
   |    1 -
>  net/ax25/ax25_ip.c                                                  =
   |    1 -
>  net/ax25/ax25_out.c                                                 =
   |    1 -
>  net/ax25/ax25_uid.c                                                 =
   |    1 -
>  net/batman-adv/Makefile                                             =
   |    6 +-
>  net/batman-adv/bat_algo.h                                           =
   |    2 +-
>  net/batman-adv/bat_iv_ogm.c                                         =
   |  210 +--
>  net/batman-adv/bitarray.c                                           =
   |    6 +-
>  net/batman-adv/bitarray.h                                           =
   |    8 +-
>  net/batman-adv/bridge_loop_avoidance.c                              =
   |   56 +-
>  net/batman-adv/bridge_loop_avoidance.h                              =
   |   12 +-
>  net/batman-adv/debugfs.c                                            =
   |   47 +-
>  net/batman-adv/debugfs.h                                            =
   |   43 +-
>  net/batman-adv/distributed-arp-table.c                              =
   |   47 +-
>  net/batman-adv/distributed-arp-table.h                              =
   |   15 +-
>  net/batman-adv/fragmentation.c                                      =
   |   44 +-
>  net/batman-adv/fragmentation.h                                      =
   |   11 +-
>  net/batman-adv/gateway_client.c                                     =
   |   41 +-
>  net/batman-adv/gateway_client.h                                     =
   |   10 +-
>  net/batman-adv/gateway_common.c                                     =
   |   13 +-
>  net/batman-adv/gateway_common.h                                     =
   |    9 +-
>  net/batman-adv/hard-interface.c                                     =
   |   40 +-
>  net/batman-adv/hard-interface.h                                     =
   |   13 +-
>  net/batman-adv/hash.c                                               =
   |    8 +-
>  net/batman-adv/hash.h                                               =
   |   33 +-
>  net/batman-adv/icmp_socket.c                                        =
   |   35 +-
>  net/batman-adv/icmp_socket.h                                        =
   |    9 +-
>  net/batman-adv/main.c                                               =
   |  103 +-
>  net/batman-adv/main.h                                               =
   |   40 +-
>  net/batman-adv/multicast.c                                          =
   |   31 +-
>  net/batman-adv/multicast.h                                          =
   |    8 +-
>  net/batman-adv/network-coding.c                                     =
   |   53 +-
>  net/batman-adv/network-coding.h                                     =
   |   15 +-
>  net/batman-adv/originator.c                                         =
   |   36 +-
>  net/batman-adv/originator.h                                         =
   |   28 +-
>  net/batman-adv/packet.h                                             =
   |    5 +-
>  net/batman-adv/routing.c                                            =
   |   38 +-
>  net/batman-adv/routing.h                                            =
   |   12 +-
>  net/batman-adv/send.c                                               =
   |   40 +-
>  net/batman-adv/send.h                                               =
   |   15 +-
>  net/batman-adv/soft-interface.c                                     =
   |   72 +-
>  net/batman-adv/soft-interface.h                                     =
   |   13 +-
>  net/batman-adv/sysfs.c                                              =
   |   62 +-
>  net/batman-adv/sysfs.h                                              =
   |   12 +-
>  net/batman-adv/translation-table.c                                  =
   |   91 +-
>  net/batman-adv/translation-table.h                                  =
   |   11 +-
>  net/batman-adv/types.h                                              =
   |   33 +-
>  net/bluetooth/6lowpan.c                                             =
   |   15 +-
>  net/bluetooth/Makefile                                              =
   |    3 +-
>  net/bluetooth/bnep/sock.c                                           =
   |    2 +-
>  net/bluetooth/cmtp/sock.c                                           =
   |    2 +-
>  net/bluetooth/hci_conn.c                                            =
   |    4 +-
>  net/bluetooth/hci_core.c                                            =
   |  153 +-
>  net/bluetooth/hci_event.c                                           =
   |  113 +-
>  net/bluetooth/hci_sock.c                                            =
   |   32 +-
>  net/bluetooth/hidp/sock.c                                           =
   |    2 +-
>  net/bluetooth/l2cap_core.c                                          =
   |   13 +-
>  net/bluetooth/l2cap_sock.c                                          =
   |   10 +-
>  net/bluetooth/mgmt.c                                                =
   |  576 +++++---
>  net/bluetooth/rfcomm/core.c                                         =
   |    2 +-
>  net/bluetooth/rfcomm/sock.c                                         =
   |   28 +-
>  net/bluetooth/sco.c                                                 =
   |   13 +-
>  net/bluetooth/smp.c                                                 =
   |  158 ++-
>  net/bridge/Makefile                                                 =
   |    2 +
>  net/bridge/br.c                                                     =
   |   22 +-
>  net/bridge/br_fdb.c                                                 =
   |   38 +-
>  net/bridge/br_if.c                                                  =
   |    4 +-
>  net/bridge/br_ioctl.c                                               =
   |    2 -
>  net/bridge/br_multicast.c                                           =
   |  266 +---
>  net/bridge/{br_netfilter.c =3D> br_netfilter_hooks.c}               =
     |  312 ++--
>  net/bridge/br_netfilter_ipv6.c                                      =
   |  245 ++++
>  net/bridge/br_netlink.c                                             =
   |   24 +-
>  net/bridge/br_private.h                                             =
   |   13 +-
>  net/bridge/br_stp.c                                                 =
   |   13 +-
>  net/bridge/br_stp_if.c                                              =
   |    6 +-
>  net/bridge/br_sysfs_if.c                                            =
   |    2 +-
>  net/bridge/br_vlan.c                                                =
   |   60 +-
>  net/bridge/netfilter/ebt_stp.c                                      =
   |    6 +-
>  net/bridge/netfilter/ebtables.c                                     =
   |    2 +-
>  net/caif/caif_socket.c                                              =
   |    2 +-
>  net/can/af_can.c                                                    =
   |    8 +-
>  net/can/gw.c                                                        =
   |   68 +-
>  net/ceph/messenger.c                                                =
   |    4 +-
>  net/core/dev.c                                                      =
   |  220 ++-
>  net/core/ethtool.c                                                  =
   |   13 +-
>  net/core/filter.c                                                   =
   |  261 +++-
>  net/core/flow_dissector.c                                           =
   |  656 ++++++---
>  net/core/neighbour.c                                                =
   |   16 +
>  net/core/net-sysfs.c                                                =
   |   10 +-
>  net/core/net_namespace.c                                            =
   |  133 +-
>  net/core/netevent.c                                                 =
   |    5 +-
>  net/core/pktgen.c                                                   =
   |  110 +-
>  net/core/rtnetlink.c                                                =
   |   81 +-
>  net/core/secure_seq.c                                               =
   |    2 +-
>  net/core/skbuff.c                                                   =
   |  387 ++---
>  net/core/sock.c                                                     =
   |   55 +-
>  net/core/sock_diag.c                                                =
   |   85 ++
>  net/core/stream.c                                                   =
   |    6 +-
>  net/core/utils.c                                                    =
   |   12 +-
>  net/dccp/diag.c                                                     =
   |    1 +
>  net/decnet/af_decnet.c                                              =
   |    8 +-
>  net/dsa/slave.c                                                     =
   |   54 +-
>  net/ethernet/eth.c                                                  =
   |   15 +-
>  net/ieee802154/6lowpan/core.c                                       =
   |   28 -
>  net/ieee802154/6lowpan/tx.c                                         =
   |    5 +-
>  net/ieee802154/core.c                                               =
   |    2 -
>  net/ieee802154/nl-mac.c                                             =
   |   39 +-
>  net/ieee802154/nl-phy.c                                             =
   |   10 +-
>  net/ieee802154/nl802154.c                                           =
   |  316 ++++-
>  net/ieee802154/rdev-ops.h                                           =
   |   23 +
>  net/ieee802154/socket.c                                             =
   |   28 +-
>  net/ieee802154/trace.h                                              =
   |   38 +-
>  net/ipv4/Kconfig                                                    =
   |   24 +-
>  net/ipv4/Makefile                                                   =
   |    3 +-
>  net/ipv4/af_inet.c                                                  =
   |   13 +-
>  net/ipv4/devinet.c                                                  =
   |    2 +
>  net/ipv4/fib_frontend.c                                             =
   |   29 +-
>  net/ipv4/fib_rules.c                                                =
   |    5 +-
>  net/ipv4/fib_semantics.c                                            =
   |   97 +-
>  net/ipv4/fib_trie.c                                                 =
   |   75 +-
>  net/ipv4/{geneve.c =3D> geneve_core.c}                              =
     |   10 +-
>  net/ipv4/igmp.c                                                     =
   |  162 +++
>  net/ipv4/inet_connection_sock.c                                     =
   |   19 +-
>  net/ipv4/inet_diag.c                                                =
   |   60 +-
>  net/ipv4/inet_hashtables.c                                          =
   |   57 +-
>  net/ipv4/inet_timewait_sock.c                                       =
   |    2 +-
>  net/ipv4/ip_forward.c                                               =
   |   18 +-
>  net/ipv4/ip_fragment.c                                              =
   |   46 +-
>  net/ipv4/ip_output.c                                                =
   |   88 +-
>  net/ipv4/ip_sockglue.c                                              =
   |   18 +-
>  net/ipv4/ip_tunnel_core.c                                           =
   |   20 +-
>  net/ipv4/ipip.c                                                     =
   |    3 +-
>  net/ipv4/netfilter/Kconfig                                          =
   |    3 +-
>  net/ipv4/netfilter/arp_tables.c                                     =
   |   86 +-
>  net/ipv4/netfilter/ip_tables.c                                      =
   |   99 +-
>  net/ipv4/netfilter/ipt_CLUSTERIP.c                                  =
   |    5 +
>  net/ipv4/netfilter/ipt_SYNPROXY.c                                   =
   |    4 +-
>  net/ipv4/netfilter/ipt_rpfilter.c                                   =
   |    2 +-
>  net/ipv4/proc.c                                                     =
   |    2 +
>  net/ipv4/route.c                                                    =
   |   33 +-
>  net/ipv4/syncookies.c                                               =
   |   10 +-
>  net/ipv4/sysctl_net_ipv4.c                                          =
   |   25 +-
>  net/ipv4/tcp.c                                                      =
   |  100 +-
>  net/ipv4/tcp_cdg.c                                                  =
   |  433 ++++++
>  net/ipv4/tcp_dctcp.c                                                =
   |   26 +-
>  net/ipv4/tcp_diag.c                                                 =
   |    6 +-
>  net/ipv4/tcp_fastopen.c                                             =
   |    2 -
>  net/ipv4/tcp_input.c                                                =
   |  139 +-
>  net/ipv4/tcp_ipv4.c                                                 =
   |   15 +-
>  net/ipv4/tcp_minisocks.c                                            =
   |    4 +
>  net/ipv4/tcp_offload.c                                              =
   |    4 +-
>  net/ipv4/tcp_output.c                                               =
   |  106 +-
>  net/ipv4/tcp_timer.c                                                =
   |    4 +-
>  net/ipv4/udp_diag.c                                                 =
   |    2 +
>  net/ipv4/udp_tunnel.c                                               =
   |    8 +-
>  net/ipv6/Makefile                                                   =
   |    1 +
>  net/ipv6/addrconf.c                                                 =
   |    2 +
>  net/ipv6/af_inet6.c                                                 =
   |    6 +-
>  net/ipv6/datagram.c                                                 =
   |   12 +-
>  net/ipv6/icmp.c                                                     =
   |    6 +-
>  net/ipv6/inet6_hashtables.c                                         =
   |    8 +-
>  net/ipv6/ip6_fib.c                                                  =
   |   25 +-
>  net/ipv6/ip6_flowlabel.c                                            =
   |    4 +
>  net/ipv6/ip6_output.c                                               =
   |   60 +-
>  net/ipv6/ip6_tunnel.c                                               =
   |    2 +-
>  net/ipv6/ip6_udp_tunnel.c                                           =
   |    6 +-
>  net/ipv6/mcast_snoop.c                                              =
   |  213 +++
>  net/ipv6/ndisc.c                                                    =
   |    2 +-
>  net/ipv6/netfilter.c                                                =
   |    2 +
>  net/ipv6/netfilter/Kconfig                                          =
   |    3 +-
>  net/ipv6/netfilter/ip6_tables.c                                     =
   |  100 +-
>  net/ipv6/output_core.c                                              =
   |   14 +-
>  net/ipv6/raw.c                                                      =
   |   11 +-
>  net/ipv6/route.c                                                    =
   |  561 +++++---
>  net/ipv6/syncookies.c                                               =
   |   19 +-
>  net/ipv6/sysctl_net_ipv6.c                                          =
   |    8 +
>  net/ipv6/tcp_ipv6.c                                                 =
   |   16 +-
>  net/ipv6/xfrm6_policy.c                                             =
   |   20 +-
>  net/ipx/af_ipx.c                                                    =
   |    2 +-
>  net/irda/af_irda.c                                                  =
   |    2 +-
>  net/irda/timer.c                                                    =
   |    4 +-
>  net/iucv/af_iucv.c                                                  =
   |   10 +-
>  net/key/af_key.c                                                    =
   |    2 +-
>  net/l2tp/l2tp_core.c                                                =
   |   15 +-
>  net/l2tp/l2tp_ppp.c                                                 =
   |    4 +-
>  net/llc/af_llc.c                                                    =
   |    2 +-
>  net/llc/llc_conn.c                                                  =
   |    6 +-
>  net/mac80211/Kconfig                                                =
   |   16 +-
>  net/mac80211/agg-tx.c                                               =
   |    4 +-
>  net/mac80211/cfg.c                                                  =
   |  214 ++-
>  net/mac80211/chan.c                                                 =
   |   10 +
>  net/mac80211/debugfs.c                                              =
   |  177 ++-
>  net/mac80211/debugfs_key.c                                          =
   |   17 +-
>  net/mac80211/debugfs_sta.c                                          =
   |   85 --
>  net/mac80211/driver-ops.h                                           =
   |   13 +-
>  net/mac80211/ethtool.c                                              =
   |    3 +-
>  net/mac80211/ibss.c                                                 =
   |    6 +-
>  net/mac80211/ieee80211_i.h                                          =
   |   36 +-
>  net/mac80211/iface.c                                                =
   |   74 +-
>  net/mac80211/key.c                                                  =
   |  109 +-
>  net/mac80211/key.h                                                  =
   |    7 +-
>  net/mac80211/led.c                                                  =
   |  268 ++--
>  net/mac80211/led.h                                                  =
   |   44 +-
>  net/mac80211/main.c                                                 =
   |   34 +-
>  net/mac80211/mesh.c                                                 =
   |    1 +
>  net/mac80211/mesh_hwmp.c                                            =
   |   35 +-
>  net/mac80211/mesh_plink.c                                           =
   |   44 +-
>  net/mac80211/mlme.c                                                 =
   |  247 ++--
>  net/mac80211/offchannel.c                                           =
   |    2 +-
>  net/mac80211/pm.c                                                   =
   |    4 +-
>  net/mac80211/rate.c                                                 =
   |   14 +-
>  net/mac80211/rate.h                                                 =
   |   14 +-
>  net/mac80211/rc80211_minstrel_ht.c                                  =
   |    2 +-
>  net/mac80211/rx.c                                                   =
   |  227 ++-
>  net/mac80211/scan.c                                                 =
   |   18 +-
>  net/mac80211/sta_info.c                                             =
   |   24 +-
>  net/mac80211/sta_info.h                                             =
   |   44 +-
>  net/mac80211/status.c                                               =
   |  163 ++-
>  net/mac80211/tdls.c                                                 =
   |   52 +-
>  net/mac80211/trace.h                                                =
   |   42 +-
>  net/mac80211/tx.c                                                   =
   |  549 ++++++-
>  net/mac80211/util.c                                                 =
   |    6 +-
>  net/mac80211/wpa.c                                                  =
   |   10 +-
>  net/mac802154/Kconfig                                               =
   |    1 +
>  net/mac802154/Makefile                                              =
   |    4 +-
>  net/mac802154/cfg.c                                                 =
   |  101 +-
>  net/mac802154/driver-ops.h                                          =
   |   96 +-
>  net/mac802154/ieee802154_i.h                                        =
   |    9 -
>  net/mac802154/iface.c                                               =
   |  156 +-
>  net/mac802154/mac_cmd.c                                             =
   |   42 +-
>  net/mac802154/main.c                                                =
   |   32 +
>  net/mac802154/mib.c                                                 =
   |   63 +-
>  net/mac802154/rx.c                                                  =
   |   13 +-
>  net/mac802154/trace.c                                               =
   |    9 +
>  net/mac802154/trace.h                                               =
   |  272 ++++
>  net/mac802154/util.c                                                =
   |    5 +-
>  net/mpls/mpls_gso.c                                                 =
   |    2 +
>  net/netfilter/Kconfig                                               =
   |   31 +-
>  net/netfilter/Makefile                                              =
   |    1 +
>  net/netfilter/core.c                                                =
   |   38 +-
>  net/netfilter/ipset/ip_set_bitmap_gen.h                             =
   |   44 +-
>  net/netfilter/ipset/ip_set_bitmap_ip.c                              =
   |   44 +-
>  net/netfilter/ipset/ip_set_bitmap_ipmac.c                           =
   |   59 +-
>  net/netfilter/ipset/ip_set_bitmap_port.c                            =
   |   27 +-
>  net/netfilter/ipset/ip_set_core.c                                   =
   |  387 ++---
>  net/netfilter/ipset/ip_set_getport.c                                =
   |   19 +-
>  net/netfilter/ipset/ip_set_hash_gen.h                               =
   |  736 ++++++----
>  net/netfilter/ipset/ip_set_hash_ip.c                                =
   |   72 +-
>  net/netfilter/ipset/ip_set_hash_ipmark.c                            =
   |   87 +-
>  net/netfilter/ipset/ip_set_hash_ipport.c                            =
   |   98 +-
>  net/netfilter/ipset/ip_set_hash_ipportip.c                          =
   |   91 +-
>  net/netfilter/ipset/ip_set_hash_ipportnet.c                         =
   |   96 +-
>  net/netfilter/ipset/ip_set_hash_mac.c                               =
   |   30 +-
>  net/netfilter/ipset/ip_set_hash_net.c                               =
   |   73 +-
>  net/netfilter/ipset/ip_set_hash_netiface.c                          =
   |  250 +---
>  net/netfilter/ipset/ip_set_hash_netnet.c                            =
   |  146 +-
>  net/netfilter/ipset/ip_set_hash_netport.c                           =
   |   86 +-
>  net/netfilter/ipset/ip_set_hash_netportnet.c                        =
   |  176 ++-
>  net/netfilter/ipset/ip_set_list_set.c                               =
   |  422 +++---
>  net/netfilter/ipset/pfxlen.c                                        =
   |   16 +-
>  net/netfilter/ipvs/ip_vs_sync.c                                     =
   |   30 +-
>  net/netfilter/ipvs/ip_vs_xmit.c                                     =
   |   19 +-
>  net/netfilter/nf_conntrack_h323_main.c                              =
   |    4 +-
>  net/netfilter/nf_conntrack_proto_generic.c                          =
   |    8 +-
>  net/netfilter/nf_internals.h                                        =
   |    1 +
>  net/netfilter/nf_queue.c                                            =
   |   17 +
>  net/netfilter/nf_synproxy_core.c                                    =
   |    1 +
>  net/netfilter/nf_tables_api.c                                       =
   |  117 +-
>  net/netfilter/nf_tables_core.c                                      =
   |    7 +-
>  net/netfilter/nf_tables_netdev.c                                    =
   |  258 ++++
>  net/netfilter/nfnetlink_log.c                                       =
   |    2 -
>  net/netfilter/nfnetlink_queue_core.c                                =
   |   63 +-
>  net/netfilter/nft_compat.c                                          =
   |    2 +
>  net/netfilter/x_tables.c                                            =
   |   55 +-
>  net/netfilter/xt_TCPMSS.c                                           =
   |    6 +
>  net/netfilter/xt_TEE.c                                              =
   |    1 +
>  net/netfilter/xt_addrtype.c                                         =
   |    2 +-
>  net/netfilter/xt_mark.c                                             =
   |    1 +
>  net/netfilter/xt_set.c                                              =
   |   47 +-
>  net/netfilter/xt_socket.c                                           =
   |   59 +-
>  net/netlink/af_netlink.c                                            =
   |  170 ++-
>  net/netrom/af_netrom.c                                              =
   |    4 +-
>  net/netrom/nr_route.c                                               =
   |    1 -
>  net/nfc/af_nfc.c                                                    =
   |    2 +-
>  net/nfc/llcp.h                                                      =
   |    2 +-
>  net/nfc/llcp_core.c                                                 =
   |    2 +-
>  net/nfc/llcp_sock.c                                                 =
   |    8 +-
>  net/nfc/nci/Kconfig                                                 =
   |    7 +
>  net/nfc/nci/Makefile                                                =
   |    3 +
>  net/nfc/nci/core.c                                                  =
   |  105 +-
>  net/nfc/nci/hci.c                                                   =
   |   11 +-
>  net/nfc/nci/ntf.c                                                   =
   |   10 +
>  net/nfc/nci/rsp.c                                                   =
   |   10 +
>  net/nfc/nci/uart.c                                                  =
   |  494 +++++++
>  net/nfc/netlink.c                                                   =
   |   55 +
>  net/nfc/nfc.h                                                       =
   |    2 +-
>  net/nfc/rawsock.c                                                   =
   |    4 +-
>  net/openvswitch/Kconfig                                             =
   |    2 +-
>  net/openvswitch/actions.c                                           =
   |   23 +-
>  net/openvswitch/datapath.c                                          =
   |   20 +-
>  net/openvswitch/datapath.h                                          =
   |    2 +
>  net/openvswitch/flow.c                                              =
   |    4 +-
>  net/openvswitch/flow_netlink.c                                      =
   |    2 +-
>  net/openvswitch/vport-geneve.c                                      =
   |    5 -
>  net/packet/af_packet.c                                              =
   |  198 ++-
>  net/packet/internal.h                                               =
   |   13 +-
>  net/phonet/af_phonet.c                                              =
   |    2 +-
>  net/phonet/pep.c                                                    =
   |    2 +-
>  net/rds/af_rds.c                                                    =
   |   43 +-
>  net/rds/bind.c                                                      =
   |    4 +
>  net/rds/ib.h                                                        =
   |   22 +-
>  net/rds/rds.h                                                       =
   |    6 +-
>  net/rds/transport.c                                                 =
   |   21 +
>  net/rfkill/core.c                                                   =
   |   12 +-
>  net/rfkill/rfkill-gpio.c                                            =
   |   24 +-
>  net/rose/af_rose.c                                                  =
   |    7 +-
>  net/rose/rose_link.c                                                =
   |    1 -
>  net/rose/rose_route.c                                               =
   |    1 -
>  net/rxrpc/af_rxrpc.c                                                =
   |    2 +-
>  net/rxrpc/ar-local.c                                                =
   |    4 +-
>  net/sched/Kconfig                                                   =
   |   11 +
>  net/sched/Makefile                                                  =
   |    1 +
>  net/sched/act_api.c                                                 =
   |    5 -
>  net/sched/act_bpf.c                                                 =
   |    9 +-
>  net/sched/act_mirred.c                                              =
   |    2 +-
>  net/sched/act_pedit.c                                               =
   |    5 +-
>  net/sched/cls_bpf.c                                                 =
   |   16 +-
>  net/sched/cls_flow.c                                                =
   |   28 +-
>  net/sched/cls_flower.c                                              =
   |  691 +++++++++
>  net/sched/em_ipset.c                                                =
   |    4 +-
>  net/sched/sch_api.c                                                 =
   |   12 +-
>  net/sched/sch_choke.c                                               =
   |   20 +-
>  net/sched/sch_codel.c                                               =
   |   15 +-
>  net/sched/sch_fq_codel.c                                            =
   |   26 +-
>  net/sched/sch_gred.c                                                =
   |   28 +-
>  net/sched/sch_hhf.c                                                 =
   |   19 +-
>  net/sched/sch_ingress.c                                             =
   |   59 +-
>  net/sched/sch_netem.c                                               =
   |    4 +-
>  net/sched/sch_qfq.c                                                 =
   |    3 +-
>  net/sched/sch_sfb.c                                                 =
   |   24 +-
>  net/sched/sch_sfq.c                                                 =
   |   27 +-
>  net/sctp/ipv6.c                                                     =
   |    7 +-
>  net/sctp/protocol.c                                                 =
   |    2 +-
>  net/sctp/socket.c                                                   =
   |   43 +-
>  net/socket.c                                                        =
   |    7 +-
>  net/switchdev/switchdev.c                                           =
   |  951 +++++++++++--
>  net/tipc/addr.c                                                     =
   |    7 -
>  net/tipc/addr.h                                                     =
   |    8 +
>  net/tipc/bcast.c                                                    =
   |   41 +-
>  net/tipc/bcast.h                                                    =
   |    1 +
>  net/tipc/bearer.c                                                   =
   |   20 +-
>  net/tipc/bearer.h                                                   =
   |    2 +-
>  net/tipc/core.c                                                     =
   |    4 +-
>  net/tipc/core.h                                                     =
   |   37 +-
>  net/tipc/link.c                                                     =
   |  311 ++--
>  net/tipc/link.h                                                     =
   |   59 +-
>  net/tipc/msg.c                                                      =
   |   51 +-
>  net/tipc/msg.h                                                      =
   |   37 +-
>  net/tipc/name_table.c                                               =
   |   34 +-
>  net/tipc/net.c                                                      =
   |    1 +
>  net/tipc/netlink_compat.c                                           =
   |  137 +-
>  net/tipc/node.c                                                     =
   |    3 +-
>  net/tipc/node.h                                                     =
   |    2 -
>  net/tipc/server.c                                                   =
   |    6 +-
>  net/tipc/socket.c                                                   =
   |   10 +-
>  net/tipc/subscr.c                                                   =
   |  242 ++--
>  net/tipc/subscr.h                                                   =
   |   18 +-
>  net/unix/af_unix.c                                                  =
   |  267 +++-
>  net/vmw_vsock/af_vsock.c                                            =
   |    7 +-
>  net/vmw_vsock/vmci_transport.c                                      =
   |    2 +-
>  net/wireless/chan.c                                                 =
   |   65 +-
>  net/wireless/core.h                                                 =
   |    1 +
>  net/wireless/nl80211.c                                              =
   |    7 +-
>  net/wireless/reg.c                                                  =
   |    4 +-
>  net/wireless/sme.c                                                  =
   |    4 +-
>  net/wireless/sysfs.c                                                =
   |   14 +-
>  net/wireless/util.c                                                 =
   |    5 +-
>  net/x25/af_x25.c                                                    =
   |    8 +-
>  net/xfrm/xfrm_input.c                                               =
   |   12 +-
>  net/xfrm/xfrm_output.c                                              =
   |   12 +
>  net/xfrm/xfrm_policy.c                                              =
   |   42 +-
>  net/xfrm/xfrm_state.c                                               =
   |    4 +-
>  samples/bpf/Makefile                                                =
   |   14 +-
>  samples/bpf/bpf_helpers.h                                           =
   |   10 +
>  samples/bpf/bpf_load.c                                              =
   |   57 +-
>  samples/bpf/lathist_kern.c                                          =
   |   99 ++
>  samples/bpf/lathist_user.c                                          =
   |  103 ++
>  samples/bpf/sockex3_kern.c                                          =
   |  290 ++++
>  samples/bpf/sockex3_user.c                                          =
   |   66 +
>  samples/bpf/tcbpf1_kern.c                                           =
   |    8 +-
>  samples/bpf/test_verifier.c                                         =
   |   84 +-
>  samples/bpf/tracex2_kern.c                                          =
   |   24 +-
>  samples/bpf/tracex2_user.c                                          =
   |   67 +-
>  samples/bpf/tracex5_kern.c                                          =
   |   75 +
>  samples/bpf/tracex5_user.c                                          =
   |   46 +
>  samples/pktgen/README.rst                                           =
   |   43 +
>  samples/pktgen/functions.sh                                         =
   |  121 ++
>  samples/pktgen/parameters.sh                                        =
   |   97 ++
>  samples/pktgen/pktgen.conf-1-1                                      =
   |   59 -
>  samples/pktgen/pktgen.conf-2-1                                      =
   |   66 -
>  samples/pktgen/pktgen.conf-2-2                                      =
   |   73 -
>  samples/pktgen/pktgen_bench_xmit_mode_netif_receive.sh              =
   |   86 ++
>  samples/pktgen/pktgen_sample01_simple.sh                            =
   |   71 +
>  samples/pktgen/pktgen_sample02_multiqueue.sh                        =
   |   75 +
>  samples/pktgen/pktgen_sample03_burst_single_flow.sh                 =
   |   82 ++
>  security/selinux/xfrm.c                                             =
   |    3 -
>  tools/testing/selftests/net/psock_fanout.c                          =
   |    2 +-
>  1418 files changed, 109728 insertions(+), 27781 deletions(-)
>  create mode 100644 Documentation/ABI/testing/sysfs-bus-pci-drivers-j=
anz-cmodio
>  create mode 100644 Documentation/ABI/testing/sysfs-class-net-janz-ic=
an3
>  delete mode 100644 Documentation/devicetree/bindings/net/amd-xgbe-ph=
y.txt
>  create mode 100644 Documentation/devicetree/bindings/net/ezchip_enet=
=2Etxt
>  create mode 100644 Documentation/devicetree/bindings/net/ipq806x-dwm=
ac.txt
>  create mode 100644 Documentation/devicetree/bindings/net/nfc/nfcmrvl=
=2Etxt
>  rename Documentation/devicetree/bindings/net/nfc/{st21nfcb.txt =3D> =
st-nci.txt} (87%)
>  create mode 100644 Documentation/devicetree/bindings/net/nxp,lpc1850=
-dwmac.txt
>  create mode 100644 Documentation/devicetree/bindings/net/renesas,rav=
b.txt
>  create mode 100644 Documentation/devicetree/bindings/net/ti,dp83867.=
txt
>  create mode 100644 drivers/bluetooth/btrtl.c
>  create mode 100644 drivers/bluetooth/btrtl.h
>  create mode 100644 drivers/net/ethernet/apm/xgene/xgene_enet_ring2.c
>  create mode 100644 drivers/net/ethernet/apm/xgene/xgene_enet_ring2.h
>  create mode 100644 drivers/net/ethernet/cavium/Kconfig
>  create mode 100644 drivers/net/ethernet/cavium/Makefile
>  create mode 100644 drivers/net/ethernet/cavium/liquidio/Makefile
>  create mode 100644 drivers/net/ethernet/cavium/liquidio/cn66xx_devic=
e.c
>  create mode 100644 drivers/net/ethernet/cavium/liquidio/cn66xx_devic=
e.h
>  create mode 100644 drivers/net/ethernet/cavium/liquidio/cn66xx_regs.=
h
>  create mode 100644 drivers/net/ethernet/cavium/liquidio/cn68xx_devic=
e.c
>  create mode 100644 drivers/net/ethernet/cavium/liquidio/cn68xx_devic=
e.h
>  create mode 100644 drivers/net/ethernet/cavium/liquidio/cn68xx_regs.=
h
>  create mode 100644 drivers/net/ethernet/cavium/liquidio/lio_ethtool.=
c
>  create mode 100644 drivers/net/ethernet/cavium/liquidio/lio_main.c
>  create mode 100644 drivers/net/ethernet/cavium/liquidio/liquidio_com=
mon.h
>  create mode 100644 drivers/net/ethernet/cavium/liquidio/liquidio_ima=
ge.h
>  create mode 100644 drivers/net/ethernet/cavium/liquidio/octeon_confi=
g.h
>  create mode 100644 drivers/net/ethernet/cavium/liquidio/octeon_conso=
le.c
>  create mode 100644 drivers/net/ethernet/cavium/liquidio/octeon_devic=
e.c
>  create mode 100644 drivers/net/ethernet/cavium/liquidio/octeon_devic=
e.h
>  create mode 100644 drivers/net/ethernet/cavium/liquidio/octeon_droq.=
c
>  create mode 100644 drivers/net/ethernet/cavium/liquidio/octeon_droq.=
h
>  create mode 100644 drivers/net/ethernet/cavium/liquidio/octeon_iq.h
>  create mode 100644 drivers/net/ethernet/cavium/liquidio/octeon_main.=
h
>  create mode 100644 drivers/net/ethernet/cavium/liquidio/octeon_mem_o=
ps.c
>  create mode 100644 drivers/net/ethernet/cavium/liquidio/octeon_mem_o=
ps.h
>  create mode 100644 drivers/net/ethernet/cavium/liquidio/octeon_netwo=
rk.h
>  create mode 100644 drivers/net/ethernet/cavium/liquidio/octeon_nic.c
>  create mode 100644 drivers/net/ethernet/cavium/liquidio/octeon_nic.h
>  create mode 100644 drivers/net/ethernet/cavium/liquidio/request_mana=
ger.c
>  create mode 100644 drivers/net/ethernet/cavium/liquidio/response_man=
ager.c
>  create mode 100644 drivers/net/ethernet/cavium/liquidio/response_man=
ager.h
>  create mode 100644 drivers/net/ethernet/cavium/thunder/Makefile
>  create mode 100644 drivers/net/ethernet/cavium/thunder/nic.h
>  create mode 100644 drivers/net/ethernet/cavium/thunder/nic_main.c
>  create mode 100644 drivers/net/ethernet/cavium/thunder/nic_reg.h
>  create mode 100644 drivers/net/ethernet/cavium/thunder/nicvf_ethtool=
=2Ec
>  create mode 100644 drivers/net/ethernet/cavium/thunder/nicvf_main.c
>  create mode 100644 drivers/net/ethernet/cavium/thunder/nicvf_queues.=
c
>  create mode 100644 drivers/net/ethernet/cavium/thunder/nicvf_queues.=
h
>  create mode 100644 drivers/net/ethernet/cavium/thunder/q_struct.h
>  create mode 100644 drivers/net/ethernet/cavium/thunder/thunder_bgx.c
>  create mode 100644 drivers/net/ethernet/cavium/thunder/thunder_bgx.h
>  create mode 100644 drivers/net/ethernet/ezchip/Kconfig
>  create mode 100644 drivers/net/ethernet/ezchip/Makefile
>  create mode 100644 drivers/net/ethernet/ezchip/nps_enet.c
>  create mode 100644 drivers/net/ethernet/ezchip/nps_enet.h
>  create mode 100644 drivers/net/ethernet/mellanox/mlx5/core/en.h
>  create mode 100644 drivers/net/ethernet/mellanox/mlx5/core/en_ethtoo=
l.c
>  create mode 100644 drivers/net/ethernet/mellanox/mlx5/core/en_flow_t=
able.c
>  create mode 100644 drivers/net/ethernet/mellanox/mlx5/core/en_main.c
>  create mode 100644 drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
>  create mode 100644 drivers/net/ethernet/mellanox/mlx5/core/en_tx.c
>  create mode 100644 drivers/net/ethernet/mellanox/mlx5/core/en_txrx.c
>  create mode 100644 drivers/net/ethernet/mellanox/mlx5/core/flow_tabl=
e.c
>  create mode 100644 drivers/net/ethernet/mellanox/mlx5/core/transobj.=
c
>  create mode 100644 drivers/net/ethernet/mellanox/mlx5/core/transobj.=
h
>  create mode 100644 drivers/net/ethernet/mellanox/mlx5/core/vport.c
>  create mode 100644 drivers/net/ethernet/mellanox/mlx5/core/wq.c
>  create mode 100644 drivers/net/ethernet/mellanox/mlx5/core/wq.h
>  create mode 100644 drivers/net/ethernet/renesas/ravb.h
>  create mode 100644 drivers/net/ethernet/renesas/ravb_main.c
>  create mode 100644 drivers/net/ethernet/renesas/ravb_ptp.c
>  create mode 100644 drivers/net/ethernet/sfc/ef10_sriov.c
>  create mode 100644 drivers/net/ethernet/sfc/ef10_sriov.h
>  create mode 100644 drivers/net/ethernet/sfc/siena_sriov.h
>  create mode 100644 drivers/net/ethernet/sfc/sriov.c
>  create mode 100644 drivers/net/ethernet/sfc/sriov.h
>  create mode 100644 drivers/net/ethernet/stmicro/stmmac/dwmac-generic=
=2Ec
>  create mode 100644 drivers/net/ethernet/stmicro/stmmac/dwmac-ipq806x=
=2Ec
>  create mode 100644 drivers/net/ethernet/stmicro/stmmac/dwmac-lpc18xx=
=2Ec
>  create mode 100644 drivers/net/geneve.c
>  create mode 100644 drivers/net/ieee802154/at86rf230.h
>  create mode 100644 drivers/net/ieee802154/atusb.c
>  create mode 100644 drivers/net/ieee802154/atusb.h
>  delete mode 100644 drivers/net/phy/amd-xgbe-phy.c
>  create mode 100644 drivers/net/phy/dp83867.c
>  create mode 100644 drivers/net/wireless/ath/ath10k/p2p.c
>  create mode 100644 drivers/net/wireless/ath/ath10k/p2p.h
>  create mode 100644 drivers/net/wireless/ath/ath10k/wow.c
>  create mode 100644 drivers/net/wireless/ath/ath10k/wow.h
>  create mode 100644 drivers/net/wireless/ath/wil6210/pmc.c
>  create mode 100644 drivers/net/wireless/ath/wil6210/pmc.h
>  create mode 100644 drivers/net/wireless/iwlwifi/iwl-trans.c
>  create mode 100644 drivers/net/wireless/mediatek/Kconfig
>  create mode 100644 drivers/net/wireless/mediatek/Makefile
>  create mode 100644 drivers/net/wireless/mediatek/mt7601u/Kconfig
>  create mode 100644 drivers/net/wireless/mediatek/mt7601u/Makefile
>  create mode 100644 drivers/net/wireless/mediatek/mt7601u/core.c
>  create mode 100644 drivers/net/wireless/mediatek/mt7601u/debugfs.c
>  create mode 100644 drivers/net/wireless/mediatek/mt7601u/dma.c
>  create mode 100644 drivers/net/wireless/mediatek/mt7601u/dma.h
>  create mode 100644 drivers/net/wireless/mediatek/mt7601u/eeprom.c
>  create mode 100644 drivers/net/wireless/mediatek/mt7601u/eeprom.h
>  create mode 100644 drivers/net/wireless/mediatek/mt7601u/init.c
>  create mode 100644 drivers/net/wireless/mediatek/mt7601u/initvals.h
>  create mode 100644 drivers/net/wireless/mediatek/mt7601u/initvals_ph=
y.h
>  create mode 100644 drivers/net/wireless/mediatek/mt7601u/mac.c
>  create mode 100644 drivers/net/wireless/mediatek/mt7601u/mac.h
>  create mode 100644 drivers/net/wireless/mediatek/mt7601u/main.c
>  create mode 100644 drivers/net/wireless/mediatek/mt7601u/mcu.c
>  create mode 100644 drivers/net/wireless/mediatek/mt7601u/mcu.h
>  create mode 100644 drivers/net/wireless/mediatek/mt7601u/mt7601u.h
>  create mode 100644 drivers/net/wireless/mediatek/mt7601u/phy.c
>  create mode 100644 drivers/net/wireless/mediatek/mt7601u/regs.h
>  create mode 100644 drivers/net/wireless/mediatek/mt7601u/trace.c
>  create mode 100644 drivers/net/wireless/mediatek/mt7601u/trace.h
>  create mode 100644 drivers/net/wireless/mediatek/mt7601u/tx.c
>  create mode 100644 drivers/net/wireless/mediatek/mt7601u/usb.c
>  create mode 100644 drivers/net/wireless/mediatek/mt7601u/usb.h
>  create mode 100644 drivers/net/wireless/mediatek/mt7601u/util.c
>  create mode 100644 drivers/net/wireless/mediatek/mt7601u/util.h
>  create mode 100644 drivers/nfc/nfcmrvl/uart.c
>  create mode 100644 drivers/nfc/st-nci/Kconfig
>  create mode 100644 drivers/nfc/st-nci/Makefile
>  create mode 100644 drivers/nfc/st-nci/core.c
>  rename drivers/nfc/{st21nfcb =3D> st-nci}/i2c.c (64%)
>  rename drivers/nfc/{st21nfcb =3D> st-nci}/ndlc.c (94%)
>  rename drivers/nfc/{st21nfcb =3D> st-nci}/ndlc.h (92%)
>  rename drivers/nfc/{st21nfcb/st21nfcb.h =3D> st-nci/st-nci.h} (63%)
>  rename drivers/nfc/{st21nfcb/st21nfcb_se.c =3D> st-nci/st-nci_se.c} =
(54%)
>  create mode 100644 drivers/nfc/st-nci/st-nci_se.h
>  delete mode 100644 drivers/nfc/st21nfcb/Kconfig
>  delete mode 100644 drivers/nfc/st21nfcb/Makefile
>  delete mode 100644 drivers/nfc/st21nfcb/st21nfcb.c
>  delete mode 100644 drivers/nfc/st21nfcb/st21nfcb_se.h
>  create mode 100644 include/dt-bindings/net/ti-dp83867.h
>  create mode 100644 include/linux/mlx5/flow_table.h
>  create mode 100644 include/linux/mlx5/vport.h
>  create mode 100644 include/linux/netfilter_defs.h
>  create mode 100644 include/linux/netfilter_ingress.h
>  create mode 100644 include/linux/platform_data/nfcmrvl.h
>  rename include/linux/platform_data/{st21nfcb.h =3D> st-nci.h} (70%)
>  create mode 100644 include/linux/platform_data/st_nci.h
>  create mode 100644 include/net/flow_dissector.h
>  delete mode 100644 include/net/flow_keys.h
>  rename net/bridge/{br_netfilter.c =3D> br_netfilter_hooks.c} (82%)
>  create mode 100644 net/bridge/br_netfilter_ipv6.c
>  rename net/ipv4/{geneve.c =3D> geneve_core.c} (97%)
>  create mode 100644 net/ipv4/tcp_cdg.c
>  create mode 100644 net/ipv6/mcast_snoop.c
>  create mode 100644 net/mac802154/trace.c
>  create mode 100644 net/mac802154/trace.h
>  create mode 100644 net/netfilter/nf_tables_netdev.c
>  create mode 100644 net/nfc/nci/uart.c
>  create mode 100644 net/sched/cls_flower.c
>  create mode 100644 samples/bpf/lathist_kern.c
>  create mode 100644 samples/bpf/lathist_user.c
>  create mode 100644 samples/bpf/sockex3_kern.c
>  create mode 100644 samples/bpf/sockex3_user.c
>  create mode 100644 samples/bpf/tracex5_kern.c
>  create mode 100644 samples/bpf/tracex5_user.c
>  create mode 100644 samples/pktgen/README.rst
>  create mode 100644 samples/pktgen/functions.sh
>  create mode 100644 samples/pktgen/parameters.sh
>  delete mode 100755 samples/pktgen/pktgen.conf-1-1
>  delete mode 100755 samples/pktgen/pktgen.conf-2-1
>  delete mode 100755 samples/pktgen/pktgen.conf-2-2
>  create mode 100755 samples/pktgen/pktgen_bench_xmit_mode_netif_recei=
ve.sh
>  create mode 100755 samples/pktgen/pktgen_sample01_simple.sh
>  create mode 100755 samples/pktgen/pktgen_sample02_multiqueue.sh
>  create mode 100755 samples/pktgen/pktgen_sample03_burst_single_flow.=
sh
