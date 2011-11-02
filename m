From: =?iso-8859-1?B?Q2FybG9zIFBl824gQ29zdGE=?= <carlospeon@hotmail.com>
Subject: bnx2x kerneloops
Date: Wed, 2 Nov 2011 12:04:07 +0100
Message-ID: <SNT113-W64251CF45774789989C835DBD40@phx.gbl>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from snt0-omc1-s33.snt0.hotmail.com ([65.55.90.44]:6633 "EHLO
	snt0-omc1-s33.snt0.hotmail.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752220Ab1KBLKQ convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Nov 2011 07:10:16 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Hello, can anybody help to debug this issue?
Thanks.
kernel 2.6.32-131.17.1.el6.x86_64 (RH 6.1)
ethtool -i eth0:driver: bnx2xversion: 1.62.00-6firmware-version: bc 5.2=
=2E7 phy baa0.105bus-info: 0000:02:00.0
Oct 31 10:40:34 apache1-pro kernel: NETDEV WATCHDOG: eth0 (bnx2x): tran=
smit queue 6 timed out
Oct 31 10:40:34 apache1-pro kernel: Modules linked in: autofs4 nfs lock=
d fscache nfs_acl auth_rpcgss sunrpc pcc_cpufreq bonding ipv6 xt_recent=
 ipt_LOG xt_limit nf_conntrack_ipv4 nf_defrag_ipv4 xt_state nf_conntrac=
k xt_hashlimit iptable_filter ip_tables dm_mirror dm_region_hash dm_log=
 power_meter ipmi_si ipmi_msghandler hpwdt hpilo sg bnx2x libcrc32c mdi=
o microcode serio_raw iTCO_wdt iTCO_vendor_support i7core_edac edac_cor=
e shpchp ext4 mbcache jbd2 sd_mod crc_t10dif hpsa qla2xxx scsi_transpor=
t_fc scsi_tgt radeon ttm drm_kms_helper drm hwmon i2c_algo_bit i2c_core=
 dm_mod [last unloaded: scsi_wait_scan]
Oct 31 10:40:34 apache1-pro kernel: Pid: 0, comm: swapper Not tainted 2=
=2E6.32-131.17.1.el6.x86_64 #1
Oct 31 10:40:34 apache1-pro kernel: Call Trace:
Oct 31 10:40:34 apache1-pro kernel:   [] ? warn_slowpath_common+0x87/0x=
c0
Oct 31 10:40:34 apache1-pro kernel: [] ? warn_slowpath_fmt+0x46/0x50
Oct 31 10:40:34 apache1-pro kernel: [] ? dev_watchdog+0x26d/0x280
Oct 31 10:40:34 apache1-pro kernel: [] ? rh_timer_func+0x0/0x10
Oct 31 10:40:34 apache1-pro kernel: [] ? usb_hcd_poll_rh_status+0x141/0=
x180
Oct 31 10:40:34 apache1-pro kernel: [] ? read_tsc+0x9/0x20
Oct 31 10:40:34 apache1-pro kernel: [] ? dev_watchdog+0x0/0x280
Oct 31 10:40:34 apache1-pro kernel: [] ? run_timer_softirq+0x197/0x340
Oct 31 10:40:34 apache1-pro kernel: [] ? __do_softirq+0xc1/0x1d0
Oct 31 10:40:34 apache1-pro kernel: [] ? handle_IRQ_event+0x60/0x170
Oct 31 10:40:34 apache1-pro kernel: [] ? call_softirq+0x1c/0x30
Oct 31 10:40:34 apache1-pro kernel: [] ? do_softirq+0x65/0xa0
Oct 31 10:40:34 apache1-pro kernel: [] ? irq_exit+0x85/0x90
Oct 31 10:40:34 apache1-pro kernel: [] ? do_IRQ+0x75/0xf0
Oct 31 10:40:34 apache1-pro kernel: [] ? ret_from_intr+0x0/0x11
Oct 31 10:40:34 apache1-pro kernel:   [] ? intel_idle+0xde/0x170
Oct 31 10:40:34 apache1-pro kernel: [] ? intel_idle+0xc1/0x170
Oct 31 10:40:34 apache1-pro kernel: [] ? cpuidle_idle_call+0xa7/0x140
Oct 31 10:40:34 apache1-pro kernel: [] ? cpu_idle+0xb6/0x110
Oct 31 10:40:34 apache1-pro kernel: [] ? rest_init+0x7a/0x80
Oct 31 10:40:34 apache1-pro kernel: [] ? start_kernel+0x41d/0x429
Oct 31 10:40:34 apache1-pro kernel: [] ? x86_64_start_reservations+0x12=
5/0x129
Oct 31 10:40:34 apache1-pro kernel: [] ? x86_64_start_kernel+0xfa/0x109
Oct 31 10:40:34 apache1-pro kernel: ---[ end trace 77e43a1d40d78daf ]--=
-
Oct 31 10:40:36 apache1-pro abrt: Kerneloops: Reported 1 kernel oopses =
to Abrt
Oct 31 10:40:36 apache1-pro abrtd: Directory 'kerneloops-1320054036-200=
0-1' creation detected
Oct 31 10:40:36 apache1-pro abrtd: Registered Database plugin 'SQLite3'
Oct 31 10:40:36 apache1-pro kernel: [bnx2x_chip_cleanup:7211(eth0)]time=
out waiting for queue[6]
Oct 31 10:40:36 apache1-pro abrtd: New crash /var/spool/abrt/kerneloops=
-1320054036-2000-1, processing
Oct 31 10:40:46 apache1-pro kernel: [bnx2x_wait_ramrod:6305(eth0)]timeo=
ut waiting for state c0000 on IDX [6]
Oct 31 10:40:46 apache1-pro kernel: bnx2x 0000:02:00.0: firmware: reque=
sting bnx2x/bnx2x-e1h-6.2.9.0.fw
Oct 31 10:40:46 apache1-pro kernel: bnx2x 0000:02:00.0: eth0: using MSI=
-X  IRQs: sp 53  fp[0] 55 ... fp[7] 62
Oct 31 10:40:47 apache1-pro kernel: bonding: bond0: link status definit=
ely down for interface eth0, disabling it
Oct 31 10:40:47 apache1-pro kernel: bonding: bond0: making interface et=
h1 the new active one.
Oct 31 10:40:47 apache1-pro kernel: [bnx2x_attn_int_deasserted3:3142(et=
h1)]MC assert!
Oct 31 10:40:47 apache1-pro kernel: [bnx2x_attn_int_deasserted3:3147(et=
h1)]driver assert
Oct 31 10:40:47 apache1-pro kernel: [bnx2x_panic_dump:894(eth1)]begin c=
rash dump -----------------
Oct 31 10:40:47 apache1-pro kernel: [bnx2x_panic_dump:901(eth1)]def_idx=
(0x726)  def_att_idx(0x8)  attn_state(0x1)  spq_prod_idx(0x2f)
Oct 31 10:40:47 apache1-pro kernel: [bnx2x_panic_dump:906(eth1)]DSB: at=
tn bits(0x0)  ack(0x1)  id(0x10)  idx(0x8)
Oct 31 10:40:47 apache1-pro kernel: [bnx2x_panic_dump:907(eth1)]     de=
f (0x0 0x0 0x0 0x0 0x0 0x0 0x0 0x72d 0x0 0x0 0x0 0x0 0x0 0x0 0x0 0x0)  =
igu_sb_id(0x10)  igu_seg_id (0x0) pf_id(0x1)  vnic_id(0x0)  vf_id(0xff)=
  vf_valid (0x0)
Oct 31 10:40:47 apache1-pro kernel: [bnx2x_panic_dump:951(eth1)]fp0: rx=
_bd_prod(0xbba)  rx_bd_cons(0x9f3)  rx_comp_prod(0xbc8)  rx_comp_cons(0=
xa00)  *rx_cons_sb(0x9ff)
Oct 31 10:40:47 apache1-pro kernel: [bnx2x_panic_dump:955(eth1)]     rx=
_sge_prod(0x400)  last_max_sge(0x0)  fp_hc_idx(0x9ec)
Oct 31 10:40:47 apache1-pro kernel: [bnx2x_panic_dump:962(eth1)]fp0: tx=
_pkt_prod(0x0)  tx_pkt_cons(0x0)  tx_bd_prod(0x0)  tx_bd_cons(0x0)  *tx=
_cons_sb(0x0)
Oct 31 10:40:47 apache1-pro kernel: [bnx2x_panic_dump:973(eth1)]     ru=
n indexes (0x9ec 0x0)
Oct 31 10:40:47 apache1-pro kernel: [bnx2x_panic_dump:979(eth1)]     in=
dexes (0x0 0x9ff 0x0 0x0 0x0 0x0 0x0 0x0)pf_id(0x1)  vf_id (0xff)  vf_v=
alid(0x0) vnic_id(0x0)  same_igu_sb_1b(0x1)
Oct 31 10:40:47 apache1-pro kernel: SM[0] __flags (0x0) igu_sb_id (0x1)=
  igu_seg_id(0x0) time_to_expire (0x6ca43fd0) timer_value(0xff)
Oct 31 10:40:47 apache1-pro kernel: SM[1] __flags (0x0) igu_sb_id (0x1)=
  igu_seg_id(0x0) time_to_expire (0xffffffff) timer_value(0xff)
Oct 31 10:40:47 apache1-pro kernel: INDEX[0] flags (0x0) timeout (0x0)
Oct 31 10:40:47 apache1-pro kernel: INDEX[1] flags (0x2) timeout (0x6)
Oct 31 10:40:47 apache1-pro kernel: INDEX[2] flags (0x0) timeout (0x0)
Oct 31 10:40:47 apache1-pro kernel: INDEX[3] flags (0x0) timeout (0x0)
Oct 31 10:40:47 apache1-pro kernel: INDEX[4] flags (0x0) timeout (0x0)
Oct 31 10:40:47 apache1-pro kernel: INDEX[5] flags (0x2) timeout (0xc)
Oct 31 10:40:47 apache1-pro kernel: INDEX[6] flags (0x0) timeout (0x0)
Oct 31 10:40:47 apache1-pro kernel: INDEX[7] flags (0x0) timeout (0x0)
Oct 31 10:40:47 apache1-pro kernel: [bnx2x_panic_dump:951(eth1)]fp1: rx=
_bd_prod(0x1c5)  rx_bd_cons(0x0)  rx_comp_prod(0x1c9)  rx_comp_cons(0x1=
)  *rx_cons_sb(0x1)
Oct 31 10:40:47 apache1-pro kernel: [bnx2x_panic_dump:955(eth1)]     rx=
_sge_prod(0x400)  last_max_sge(0x0)  fp_hc_idx(0x1)
Oct 31 10:40:47 apache1-pro kernel: [bnx2x_panic_dump:962(eth1)]fp1: tx=
_pkt_prod(0x1)  tx_pkt_cons(0x0)  tx_bd_prod(0x2)  tx_bd_cons(0x0)  *tx=
_cons_sb(0x0)
Oct 31 10:40:47 apache1-pro kernel: [bnx2x_panic_dump:973(eth1)]     ru=
n indexes (0x1 0x0)
Oct 31 10:40:47 apache1-pro kernel: [bnx2x_panic_dump:979(eth1)]     in=
dexes (0x0 0x1 0x0 0x0 0x0 0x0 0x0 0x0)pf_id(0x1)  vf_id (0xff)  vf_val=
id(0x0) vnic_id(0x0)  same_igu_sb_1b(0x1)
Oct 31 10:40:47 apache1-pro kernel: SM[0] __flags (0x0) igu_sb_id (0x2)=
  igu_seg_id(0x0) time_to_expire (0x216116) timer_value(0xff)
Oct 31 10:40:47 apache1-pro kernel: SM[1] __flags (0x0) igu_sb_id (0x2)=
  igu_seg_id(0x0) time_to_expire (0xffffffff) timer_value(0xff)
Oct 31 10:40:47 apache1-pro kernel: INDEX[0] flags (0x0) timeout (0x0)
Oct 31 10:40:47 apache1-pro kernel: INDEX[1] flags (0x2) timeout (0x6)
Oct 31 10:40:47 apache1-pro kernel: INDEX[2] flags (0x0) timeout (0x0)
Oct 31 10:40:47 apache1-pro kernel: INDEX[3] flags (0x0) timeout (0x0)
Oct 31 10:40:47 apache1-pro kernel: INDEX[4] flags (0x0) timeout (0x0)
Oct 31 10:40:47 apache1-pro kernel: INDEX[5] flags (0x2) timeout (0xc)
Oct 31 10:40:47 apache1-pro kernel: INDEX[6] flags (0x0) timeout (0x0)
Oct 31 10:40:47 apache1-pro kernel: INDEX[7] flags (0x0) timeout (0x0)

Oct 31 10:40:47 apache1-pro kernel: [bnx2x_panic_dump:951(eth1)]fp2: rx=
_bd_prod(0x1dc)  rx_bd_cons(0x17)  rx_comp_prod(0x1e0)  rx_comp_cons(0x=
18)  *rx_cons_sb(0x18)
Oct 31 10:40:47 apache1-pro kernel: [bnx2x_panic_dump:955(eth1)]     rx=
_sge_prod(0x400)  last_max_sge(0x0)  fp_hc_idx(0x18)
Oct 31 10:40:47 apache1-pro kernel: [bnx2x_panic_dump:962(eth1)]fp2: tx=
_pkt_prod(0x1)  tx_pkt_cons(0x0)  tx_bd_prod(0x2)  tx_bd_cons(0x0)  *tx=
_cons_sb(0x0)
Oct 31 10:40:47 apache1-pro kernel: [bnx2x_panic_dump:973(eth1)]     ru=
n indexes (0x18 0x0)
Oct 31 10:40:47 apache1-pro kernel: [bnx2x_panic_dump:979(eth1)]     in=
dexes (0x0 0x18 0x0 0x0 0x0 0x0 0x0 0x0)pf_id(0x1)  vf_id (0xff)  vf_va=
lid(0x0) vnic_id(0x0)  same_igu_sb_1b(0x1)
Oct 31 10:40:47 apache1-pro kernel: SM[0] __flags (0x0) igu_sb_id (0x3)=
  igu_seg_id(0x0) time_to_expire (0x6cab8f35) timer_value(0xff)
Oct 31 10:40:47 apache1-pro kernel: SM[1] __flags (0x0) igu_sb_id (0x3)=
  igu_seg_id(0x0) time_to_expire (0xffffffff) timer_value(0xff)
Oct 31 10:40:47 apache1-pro kernel: INDEX[0] flags (0x0) timeout (0x0)
Oct 31 10:40:47 apache1-pro kernel: INDEX[1] flags (0x2) timeout (0x6)
Oct 31 10:40:47 apache1-pro kernel: INDEX[2] flags (0x0) timeout (0x0)
Oct 31 10:40:47 apache1-pro kernel: INDEX[3] flags (0x0) timeout (0x0)
Oct 31 10:40:47 apache1-pro kernel: INDEX[4] flags (0x0) timeout (0x0)
Oct 31 10:40:47 apache1-pro kernel: INDEX[5] flags (0x2) timeout (0xc)
Oct 31 10:40:47 apache1-pro kernel: INDEX[6] flags (0x0) timeout (0x0)
Oct 31 10:40:47 apache1-pro kernel: INDEX[7] flags (0x0) timeout (0x0)
Oct 31 10:40:47 apache1-pro kernel: [bnx2x_panic_dump:951(eth1)]fp3: rx=
_bd_prod(0x1ce)  rx_bd_cons(0x9)  rx_comp_prod(0x1d2)  rx_comp_cons(0xa=
)  *rx_cons_sb(0xa)
Oct 31 10:40:47 apache1-pro kernel: [bnx2x_panic_dump:955(eth1)]     rx=
_sge_prod(0x400)  last_max_sge(0x0)  fp_hc_idx(0xa)
Oct 31 10:40:47 apache1-pro kernel: [bnx2x_panic_dump:962(eth1)]fp3: tx=
_pkt_prod(0x1)  tx_pkt_cons(0x0)  tx_bd_prod(0x2)  tx_bd_cons(0x0)  *tx=
_cons_sb(0x0)
Oct 31 10:40:47 apache1-pro kernel: [bnx2x_panic_dump:973(eth1)]     ru=
n indexes (0xa 0x0)
Oct 31 10:40:47 apache1-pro kernel: [bnx2x_panic_dump:979(eth1)]     in=
dexes (0x0 0xa 0x0 0x0 0x0 0x0 0x0 0x0)pf_id(0x1)  vf_id (0xff)  vf_val=
id(0x0) vnic_id(0x0)  same_igu_sb_1b(0x1)
Oct 31 10:40:47 apache1-pro kernel: SM[0] __flags (0x0) igu_sb_id (0x4)=
  igu_seg_id(0x0) time_to_expire (0x6b22e5c4) timer_value(0xff)
Oct 31 10:40:47 apache1-pro kernel: SM[1] __flags (0x0) igu_sb_id (0x4)=
  igu_seg_id(0x0) time_to_expire (0xffffffff) timer_value(0xff)
Oct 31 10:40:47 apache1-pro kernel: INDEX[0] flags (0x0) timeout (0x0)
Oct 31 10:40:47 apache1-pro kernel: INDEX[1] flags (0x2) timeout (0x6)
Oct 31 10:40:47 apache1-pro kernel: INDEX[2] flags (0x0) timeout (0x0)
Oct 31 10:40:47 apache1-pro kernel: INDEX[3] flags (0x0) timeout (0x0)
Oct 31 10:40:47 apache1-pro kernel: INDEX[4] flags (0x0) timeout (0x0)
Oct 31 10:40:47 apache1-pro kernel: INDEX[5] flags (0x2) timeout (0xc)
Oct 31 10:40:47 apache1-pro kernel: INDEX[6] flags (0x0) timeout (0x0)
Oct 31 10:40:47 apache1-pro kernel: INDEX[7] flags (0x0) timeout (0x0)
Oct 31 10:40:47 apache1-pro kernel: [bnx2x_panic_dump:951(eth1)]fp4: rx=
_bd_prod(0x1c5)  rx_bd_cons(0x0)  rx_comp_prod(0x1c9)  rx_comp_cons(0x1=
)  *rx_cons_sb(0x1)
Oct 31 10:40:47 apache1-pro kernel: [bnx2x_panic_dump:955(eth1)]     rx=
_sge_prod(0x400)  last_max_sge(0x0)  fp_hc_idx(0x1)
Oct 31 10:40:47 apache1-pro kernel: [bnx2x_panic_dump:962(eth1)]fp4: tx=
_pkt_prod(0x0)  tx_pkt_cons(0x0)  tx_bd_prod(0x0)  tx_bd_cons(0x0)  *tx=
_cons_sb(0x0)
Oct 31 10:40:47 apache1-pro kernel: [bnx2x_panic_dump:973(eth1)]     ru=
n indexes (0x1 0x0)
Oct 31 10:40:47 apache1-pro kernel: [bnx2x_panic_dump:979(eth1)]     in=
dexes (0x0 0x1 0x0 0x0 0x0 0x0 0x0 0x0)pf_id(0x1)  vf_id (0xff)  vf_val=
id(0x0) vnic_id(0x0)  same_igu_sb_1b(0x1)
Oct 31 10:40:47 apache1-pro kernel: SM[0] __flags (0x0) igu_sb_id (0x5)=
  igu_seg_id(0x0) time_to_expire (0x21787e) timer_value(0xff)
Oct 31 10:40:47 apache1-pro kernel: SM[1] __flags (0x0) igu_sb_id (0x5)=
  igu_seg_id(0x0) time_to_expire (0xffffffff) timer_value(0xff)
Oct 31 10:40:47 apache1-pro kernel: INDEX[0] flags (0x0) timeout (0x0)
Oct 31 10:40:47 apache1-pro kernel: INDEX[1] flags (0x2) timeout (0x6)
Oct 31 10:40:47 apache1-pro kernel: INDEX[2] flags (0x0) timeout (0x0)
Oct 31 10:40:47 apache1-pro kernel: INDEX[3] flags (0x0) timeout (0x0)
Oct 31 10:40:47 apache1-pro kernel: INDEX[4] flags (0x0) timeout (0x0)
Oct 31 10:40:47 apache1-pro kernel: INDEX[5] flags (0x2) timeout (0xc)
Oct 31 10:40:47 apache1-pro kernel: INDEX[6] flags (0x0) timeout (0x0)
Oct 31 10:40:47 apache1-pro kernel: INDEX[7] flags (0x0) timeout (0x0)
Oct 31 10:40:47 apache1-pro kernel: [bnx2x_panic_dump:951(eth1)]fp5: rx=
_bd_prod(0x1c5)  rx_bd_cons(0x0)  rx_comp_prod(0x1c9)  rx_comp_cons(0x1=
)  *rx_cons_sb(0x1)
Oct 31 10:40:47 apache1-pro kernel: [bnx2x_panic_dump:955(eth1)]     rx=
_sge_prod(0x400)  last_max_sge(0x0)  fp_hc_idx(0x1)
Oct 31 10:40:47 apache1-pro kernel: [bnx2x_panic_dump:962(eth1)]fp5: tx=
_pkt_prod(0x0)  tx_pkt_cons(0x0)  tx_bd_prod(0x0)  tx_bd_cons(0x0)  *tx=
_cons_sb(0x0)
Oct 31 10:40:47 apache1-pro kernel: [bnx2x_panic_dump:973(eth1)]     ru=
n indexes (0x1 0x0)
Oct 31 10:40:47 apache1-pro kernel: [bnx2x_panic_dump:979(eth1)]     in=
dexes (0x0 0x1 0x0 0x0 0x0 0x0 0x0 0x0)pf_id(0x1)  vf_id (0xff)  vf_val=
id(0x0) vnic_id(0x0)  same_igu_sb_1b(0x1)

Oct 31 10:40:47 apache1-pro kernel: SM[0] __flags (0x0) igu_sb_id (0x7)=
  igu_seg_id(0x0) time_to_expire (0x218814) timer_value(0xff)
Oct 31 10:40:47 apache1-pro kernel: SM[1] __flags (0x0) igu_sb_id (0x7)=
  igu_seg_id(0x0) time_to_expire (0xffffffff) timer_value(0xff)
Oct 31 10:40:47 apache1-pro kernel: INDEX[0] flags (0x0) timeout (0x0)
Oct 31 10:40:47 apache1-pro kernel: INDEX[1] flags (0x2) timeout (0x6)
Oct 31 10:40:47 apache1-pro kernel: INDEX[2] flags (0x0) timeout (0x0)
Oct 31 10:40:47 apache1-pro kernel: INDEX[3] flags (0x0) timeout (0x0)
Oct 31 10:40:47 apache1-pro kernel: INDEX[4] flags (0x0) timeout (0x0)
Oct 31 10:40:47 apache1-pro kernel: INDEX[5] flags (0x2) timeout (0xc)
Oct 31 10:40:47 apache1-pro kernel: INDEX[6] flags (0x0) timeout (0x0)
Oct 31 10:40:47 apache1-pro kernel: INDEX[7] flags (0x0) timeout (0x0)
Oct 31 10:40:47 apache1-pro kernel: [bnx2x_panic_dump:951(eth1)]fp7: rx=
_bd_prod(0x1d7)  rx_bd_cons(0x12)  rx_comp_prod(0x1db)  rx_comp_cons(0x=
13)  *rx_cons_sb(0x13)
Oct 31 10:40:47 apache1-pro kernel: [bnx2x_panic_dump:955(eth1)]     rx=
_sge_prod(0x400)  last_max_sge(0x0)  fp_hc_idx(0x13)
Oct 31 10:40:47 apache1-pro kernel: [bnx2x_panic_dump:962(eth1)]fp7: tx=
_pkt_prod(0x0)  tx_pkt_cons(0x0)  tx_bd_prod(0x0)  tx_bd_cons(0x0)  *tx=
_cons_sb(0x0)
Oct 31 10:40:47 apache1-pro kernel: [bnx2x_panic_dump:973(eth1)]     ru=
n indexes (0x13 0x0)
Oct 31 10:40:47 apache1-pro kernel: [bnx2x_panic_dump:979(eth1)]     in=
dexes (0x0 0x13 0x0 0x0 0x0 0x0 0x0 0x0)pf_id(0x1)  vf_id (0xff)  vf_va=
lid(0x0) vnic_id(0x0)  same_igu_sb_1b(0x1)
Oct 31 10:40:47 apache1-pro kernel: SM[0] __flags (0x0) igu_sb_id (0x8)=
  igu_seg_id(0x0) time_to_expire (0x664cc527) timer_value(0xff)
Oct 31 10:40:47 apache1-pro kernel: SM[1] __flags (0x0) igu_sb_id (0x8)=
  igu_seg_id(0x0) time_to_expire (0xffffffff) timer_value(0xff)
Oct 31 10:40:47 apache1-pro kernel: INDEX[0] flags (0x0) timeout (0x0)
Oct 31 10:40:47 apache1-pro kernel: INDEX[1] flags (0x2) timeout (0x6)
Oct 31 10:40:47 apache1-pro kernel: INDEX[2] flags (0x0) timeout (0x0)
Oct 31 10:40:47 apache1-pro kernel: INDEX[3] flags (0x0) timeout (0x0)
Oct 31 10:40:47 apache1-pro kernel: INDEX[4] flags (0x0) timeout (0x0)
Oct 31 10:40:47 apache1-pro kernel: INDEX[5] flags (0x2) timeout (0xc)
Oct 31 10:40:47 apache1-pro kernel: INDEX[6] flags (0x0) timeout (0x0)
Oct 31 10:40:47 apache1-pro kernel: INDEX[7] flags (0x0) timeout (0x0)
Oct 31 10:40:47 apache1-pro kernel: begin fw dump (mark 0xaf8e4)
Oct 31 10:40:47 apache1-pro kernel: nt[1] 0x200->0x0
Oct 31 10:40:47 apache1-pro kernel: evnt[1] 0x0Ap^A=C8->0x200
Oct 31 10:40:47 apache1-pro kernel: vpd[1]: a 0x18:n 0x558=3D>0x6669746=
c
Oct 31 10:40:47 apache1-pro kernel: vpd[1]: a 0x1c:n 0x55c=3D>0x74636e7=
5
Oct 31 10:40:47 apache1-pro kernel: evnt[1] 0x200->0x0
Oct 31 10:40:47 apache1-pro kernel: evnt[1] 0x0->0x200
Oct 31 10:40:47 apache1-pro kernel: vpd[1]: a 0x20:n 0x560=3D>0x5f6e6f6=
9
Oct 31 10:40:47 apache1-pro kernel: vpd[1]: a 0x24:n 0x564=3D>0x632d4c4=
2
Oct 31 10:40:47 apache1-pro kernel: evnt[1] 0x200->0x0
Oct 31 10:40:47 apache1-pro kernel: evnt[1] 0x0->0x200
Oct 31 10:40:47 apache1-pro kernel: vpd[1]: a 0x28:n 0x568=3D>0x6164415=
f
Oct 31 10:40:47 apache1-pro kernel: vpd[1]: a 0x2c:n 0x56c=3D>0x7265747=
0
Oct 31 10:40:47 apache1-pro kernel: evnt[1] 0x200->0x0
Oct 31 10:40:47 apache1-pro kernel: evnt[1] 0x0->0x200
Oct 31 10:40:47 apache1-pro kernel: vpd[1]: a 0x30:n 0x570=3D>0x4b9000
Oct 31 10:40:47 apache1-pro kernel: evnt[1] 0x200->0x0
Oct 31 10:40:47 apache1-pro kernel: evnt[1] 0x0->0x200
Oct 31 10:40:47 apache1-pro kernel: vpd[1]: a 0x34:n 0x574=3D>0x4e034e5=
0
Oct 31 10:40:47 apache1-pro kernel: evnt[1] 0x200->0x0
Oct 31 10:40:47 apache1-pro kernel: evnt[1] 0x0->0x200
Oct 31 10:40:47 apache1-pro kernel: vpd[1]: a 0x38:n 0x578=3D>0x4345412=
f
Oct 31 10:40:47 apache1-pro kernel: evnt[1] 0x200->0x0
Oct 31 10:40:47 apache1-pro kernel: evnt[1] 0x0->0x200
Oct 31 10:40:47 apache1-pro kernel: vpd[1]: a 0x3c:n 0x57c=3D>0x412f4e0=
3
Oct 31 10:40:47 apache1-pro kernel: vpd[1]: a 0x40:n 0x580=3D>0x300a4e5=
3
Oct 31 10:40:47 apache1-pro kernel: evnt[1] 0x200->0x0
Oct 31 10:40:47 apache1-pro kernel: evnt[1] 0x0->0x200
Oct 31 10:40:47 apache1-pro kernel: vpd[1]: a 0x44:n 0x584=3D>0x3433323=
1
Oct 31 10:40:47 apache1-pro kernel: vpd[1]: a 0x48:n 0x588=3D>0x3837363=
5
Oct 31 10:40:47 apache1-pro kernel: evnt[1] 0x200->0x0
Oct 31 10:40:47 apache1-pro kernel: evnt[1] 0x0->0x200

Oct 31 10:40:47 apache1-pro kernel: vpd[1]: a 0x38:n 0x578=3D>0x4345412=
f
Oct 31 10:40:47 apache1-pro kernel: evnt[1] 0x200->0x0
Oct 31 10:40:47 apache1-pro kernel: evnt[1] 0x0->0x200
Oct 31 10:40:47 apache1-pro kernel: vpd[1]: a 0x3c:n 0x57c=3D>0x412f4e0=
3
Oct 31 10:40:47 apache1-pro kernel: vpd[1]: a 0x40:n 0x580=3D>0x300a4e5=
3
Oct 31 10:40:47 apache1-pro kernel: evnt[1] 0x200->0x0
Oct 31 10:40:47 apache1-pro kernel: evnt[1] 0x0->0x200
Oct 31 10:40:47 apache1-pro kernel: vpd[1]: a 0x44:n 0x584=3D>0x3433323=
1
Oct 31 10:40:47 apache1-pro kernel: vpd[1]: a 0x48:n 0x588=3D>0x3837363=
5
Oct 31 10:40:47 apache1-pro kernel: evnt[1] 0x200->0x0
Oct 31 10:40:47 apache1-pro kernel: evnt[1] 0x0->0x200
Oct 31 10:40:47 apache1-pro kernel: vpd[1]: a 0x4c:n 0x58c=3D>0x44e4d39
Oct 31 10:40:47 apache1-pro kernel: vpd[1]: a 0x50:n 0x590=3D>0x3465343=
1
Oct 31 10:40:47 apache1-pro kernel: evnt[1] 0x200->0x0
Oct 31 10:40:47 apache1-pro kernel: evnt[1] 0x0->0x200
Oct 31 10:40:47 apache1-pro kernel: vpd[1]: a 0x54:n 0x594=3D>0xf285652
Oct 31 10:40:47 apache1-pro kernel: vpd[1]: a 0x58:n 0x598=3D>0x0
Oct 31 10:40:47 apache1-pro kernel: evnt[1] 0x200->0x0
Oct 31 10:40:47 apache1-pro kernel: evnt[1] 0x0->0x200
Oct 31 10:40:47 apache1-pro kernel: vpd[1]: a 0x5c:n 0x59c=3D>0x0
Oct 31 10:40:47 apache1-pro kernel: evnt[1] 0x200->0x0
Oct 31 10:40:47 apache1-pro kernel: evnt[1] 0x0->0x200
Oct 31 10:40:47 apache1-pro kernel: vpd[1]: a 0x60:n 0x5a0=3D>0x0
Oct 31 10:40:47 apache1-pro kernel: evnt[1] 0x200->0x0
Oct 31 10:40:47 apache1-pro kernel: evnt[1] 0x0->0x200
Oct 31 10:40:47 apache1-pro kernel: vpd[1]: a 0x64:n 0x5a4=3D>0x0
Oct 31 10:40:47 apache1-pro kernel: evnt[1] 0x200->0x0
Oct 31 10:40:47 apache1-pro kernel: evnt[1] 0x0->0x200
Oct 31 10:40:47 apache1-pro kernel: vpd[1]: a 0x68:n 0x5a8=3D>0x0
Oct 31 10:40:47 apache1-pro kernel: evnt[1] 0x200->0x0
Oct 31 10:40:47 apache1-pro kernel: evnt[1] 0x0->0x200
Oct 31 10:40:47 apache1-pro kernel: vpd[1]: a 0x6c:n 0x5ac=3D>0x0
Oct 31 10:40:47 apache1-pro kernel: evnt[1] 0x200->0x0
Oct 31 10:40:47 apache1-pro kernel: evnt[1] 0x0->0x200
Oct 31 10:40:47 apache1-pro kernel: vpd[1]: a 0x70:n 0x5b0=3D>0x0
Oct 31 10:40:47 apache1-pro kernel: evnt[1] 0x200->0x0
Oct 31 10:40:47 apache1-pro kernel: evnt[1] 0x0->0x200
Oct 31 10:40:47 apache1-pro kernel: vpd[1]: a 0x74:n 0x5b4=3D>0x0
Oct 31 10:40:47 apache1-pro kernel: evnt[1] 0x200->0x0
Oct 31 10:40:47 apache1-pro kernel: evnt[1] 0x0->0x200
Oct 31 10:40:47 apache1-pro kernel: vpd[1]: a 0x78:n 0x5b8=3D>0x0
Oct 31 10:40:47 apache1-pro kernel: evnt[1] 0x200->0x0
Oct 31 10:40:47 apache1-pro kernel: evnt[1] 0x0->0x200
Oct 31 10:40:47 apache1-pro kernel: vpd[1]: a 0x7c:n 0x5bc=3D>0x7800000=
0
Oct 31 10:40:47 apache1-pro kernel: evnt[1] 0x200->0x0
Oct 31 10:40:47 apache1-pro kernel: f0: LOAD_REQ
Oct 31 10:40:47 apache1-pro kernel: p0: PMF->f0
Oct 31 10:40:47 apache1-pro kernel: f0: LOAD_DONE
Oct 31 10:40:47 apache1-pro kernel: evnt[0] 0x0->0x1000
Oct 31 10:40:47 apache1-pro kernel: evnt[0] 0x1000->0x0
Oct 31 10:40:47 apache1-pro kernel: f1: LOAD_REQ
Oct 31 10:40:47 apache1-pro kernel: p1: PMF->f1
Oct 31 10:40:47 apache1-pro kernel: f1: LOAD_DONE
Oct 31 10:40:47 apache1-pro kernel: evnt[0] 0x0->0x1000
Oct 31 10:40:47 apache1-pro kernel: evnt[0] 0x1000->0x0
Oct 31 10:40:47 apache1-pro kernel: evnt[0] 0x0->0x1000
Oct 31 10:40:47 apache1-pro kernel: evnt[0] 0x1000->0x0
Oct 31 10:40:47 apache1-pro kernel: evnt[1] 0x0->0x1000
Oct 31 10:40:47 apache1-pro kernel: evnt[1] 0x1000->0x0
Oct 31 10:40:47 apache1-pro kernel: evnt[1] 0x0->0x1000
Oct 31 10:40:47 apache1-pro kernel: evnt[1] 0x1000->0x0
Oct 31 10:40:47 apache1-pro kernel: evnt[1] 0x0->0x1000
Oct 31 10:40:47 apache1-pro kernel: evnt[1] 0x1000->0x0
Oct 31 10:40:47 apache1-pro kernel: f0: UNLOAD_REQ_WOL_DIS
Oct 31 10:40:47 apache1-pro kernel: f0: UNLOAD_DONE
Oct 31 10:40:47 apache1-pro kernel: f0: LOAD_REQ
Oct 31 10:40:47 apache1-pro kernel: p0: PMF->f0
Oct 31 10:40:47 apache1-pro kernel: f0: LOAD_DONE
Oct 31 10:40:47 apache1-pro kernel: evnt[0] 0x0->0x1000
Oct 31 10:40:47 apache1-pro kernel: evnt[0] 0x1000->0x0
Oct 31 10:40:47 apache1-pro kernel: evnt[0] 0x0->0x1000
Oct 31 10:40:47 apache1-pro kernel: end of fw dump
Oct 31 10:40:47 apache1-pro kernel: [bnx2x_mc_assert:732(eth1)]XSTORM_A=
SSERT_LIST_INDEX 0x2
Oct 31 10:40:47 apache1-pro kernel: [bnx2x_mc_assert:749(eth1)]XSTORM_A=
SSERT_INDEX 0x0 =3D 0x00000000 0x00000000 0x00000000 0x00010014
Oct 31 10:40:47 apache1-pro kernel: [bnx2x_panic_dump:1099(eth1)]end cr=
ash dump ----------------- 		 	   		  