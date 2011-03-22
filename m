From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [slab poison overwritten] Re: [GIT] Networking
Date: Tue, 22 Mar 2011 10:07:39 +0100
Message-ID: <20110322090739.GA10696@elte.hu>
References: <20110320.195156.226769634.davem@davemloft.net>
 <20110321125320.GA23490@elte.hu>
 <1300714346.2884.284.camel@edumazet-laptop>
 <20110321161528.GA28580@elte.hu>
 <20110321164238.GA5303@elte.hu>
 <20110321173941.GB3892@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, torvalds@linux-foundation.org,
	akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Thomas Gleixner <tglx@linutronix.de>,
	Arnd Bergmann <arnd@arndb.de>,
	Pekka Enberg <penberg@cs.helsinki.fi>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20110321173941.GB3892@elte.hu>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


* Ingo Molnar <mingo@elte.hu> wrote:

> here's the same but with kallsyms enabled.

Sorry, wrong log - find below a kallsyms enabled one.

I'll test the patches in this thread.

Thanks,

	Ingo

--------------->
calling  dell_init+0x0/0xa @ 1
initcall dell_init+0x0/0xa returned -19 after 2 usecs
calling  dell_wmi_init+0x0/0xd4 @ 1
dell-wmi: No known WMI GUID found
initcall dell_wmi_init+0x0/0xd4 returned -19 after 2 usecs
calling  tc1100_init+0x0/0x78 @ 1
initcall tc1100_init+0x0/0x78 returned -19 after 2 usecs
calling  hdaps_init+0x0/0x2d @ 1
hdaps: supported laptop not found!
hdaps: driver init failed (ret=3D-19)!
initcall hdaps_init+0x0/0x2d returned -19 after 2 usecs
calling  fujitsu_init+0x0/0x21d @ 1
fujitsu-laptop: driver 0.6.0 successfully loaded.
initcall fujitsu_init+0x0/0x21d returned 0 after 393 usecs
calling  acpi_pcc_init+0x0/0x23 @ 1
initcall acpi_pcc_init+0x0/0x23 returned 0 after 59 usecs
calling  intel_menlow_module_init+0x0/0x8f @ 1
initcall intel_menlow_module_init+0x0/0x8f returned -19 after 13 usecs
calling  msi_wmi_init+0x0/0x15b @ 1
This machine doesn't have MSI-hotkeys through WMI
initcall msi_wmi_init+0x0/0x15b returned -19 after 3 usecs
calling  asus_acpi_init+0x0/0xdf @ 1
initcall asus_acpi_init+0x0/0xdf returned -19 after 98 usecs
calling  topstar_laptop_init+0x0/0x22 @ 1
Topstar Laptop ACPI extras driver loaded
initcall topstar_laptop_init+0x0/0x22 returned 0 after 50 usecs
calling  ibm_rtl_init+0x0/0x245 @ 1
initcall ibm_rtl_init+0x0/0x245 returned -19 after 2 usecs
calling  flow_cache_init_global+0x0/0x112 @ 1
initcall flow_cache_init_global+0x0/0x112 returned 0 after 179 usecs
calling  pg_init+0x0/0x2b0 @ 1
pktgen: Packet Generator for packet performance testing. Version: 2.74
usb usb2: rpm_suspend returns 0
usb usb1: rpm_suspend flags 0x9
usb usb1: rpm_suspend returns 0
initcall pg_init+0x0/0x2b0 returned 0 after 1543240 usecs
calling  llc_init+0x0/0x1b @ 1
initcall llc_init+0x0/0x1b returned 0 after 2 usecs
calling  snap_init+0x0/0x33 @ 1
initcall snap_init+0x0/0x33 returned 0 after 6 usecs
calling  blackhole_module_init+0x0/0xf @ 1
initcall blackhole_module_init+0x0/0xf returned 0 after 2 usecs
calling  police_init_module+0x0/0xf @ 1
initcall police_init_module+0x0/0xf returned 0 after 2 usecs
calling  ipt_init_module+0x0/0xf @ 1
initcall ipt_init_module+0x0/0xf returned 0 after 1 usecs
calling  skbedit_init_module+0x0/0xf @ 1
initcall skbedit_init_module+0x0/0xf returned 0 after 1 usecs
calling  red_module_init+0x0/0xf @ 1
initcall red_module_init+0x0/0xf returned 0 after 1 usecs
calling  gred_module_init+0x0/0xf @ 1
initcall gred_module_init+0x0/0xf returned 0 after 1 usecs
calling  ingress_module_init+0x0/0xf @ 1
initcall ingress_module_init+0x0/0xf returned 0 after 1 usecs
calling  dsmark_module_init+0x0/0xf @ 1
initcall dsmark_module_init+0x0/0xf returned 0 after 2 usecs
calling  sfb_module_init+0x0/0xf @ 1
initcall sfb_module_init+0x0/0xf returned 0 after 1 usecs
calling  sfq_module_init+0x0/0xf @ 1
initcall sfq_module_init+0x0/0xf returned 0 after 1 usecs
calling  prio_module_init+0x0/0xf @ 1
initcall prio_module_init+0x0/0xf returned 0 after 1 usecs
calling  multiq_module_init+0x0/0xf @ 1
initcall multiq_module_init+0x0/0xf returned 0 after 1 usecs
calling  atm_init+0x0/0xf @ 1
initcall atm_init+0x0/0xf returned 0 after 1 usecs
calling  netem_module_init+0x0/0x1c @ 1
netem: version 1.3
initcall netem_module_init+0x0/0x1c returned 0 after 1710 usecs
calling  mqprio_module_init+0x0/0xf @ 1
initcall mqprio_module_init+0x0/0xf returned 0 after 1 usecs
calling  choke_module_init+0x0/0xf @ 1
initcall choke_module_init+0x0/0xf returned 0 after 1 usecs
calling  init_fw+0x0/0xf @ 1
initcall init_fw+0x0/0xf returned 0 after 1 usecs
calling  init_rsvp+0x0/0xf @ 1
initcall init_rsvp+0x0/0xf returned 0 after 1 usecs
calling  init_basic+0x0/0xf @ 1
initcall init_basic+0x0/0xf returned 0 after 1 usecs
calling  cls_flow_init+0x0/0xf @ 1
initcall cls_flow_init+0x0/0xf returned 0 after 1 usecs
calling  init_em_cmp+0x0/0xf @ 1
initcall init_em_cmp+0x0/0xf returned 0 after 1 usecs
calling  init_em_meta+0x0/0xf @ 1
initcall init_em_meta+0x0/0xf returned 0 after 1 usecs
calling  nfnetlink_init+0x0/0x26 @ 1
Netfilter messages via NETLINK v0.30.
initcall nfnetlink_init+0x0/0x26 returned 0 after 3335 usecs
calling  nfnetlink_log_init+0x0/0xbe @ 1
initcall nfnetlink_log_init+0x0/0xbe returned 0 after 12 usecs
calling  nf_conntrack_standalone_init+0x0/0xf @ 1
nf_conntrack version 0.5.0 (16004 buckets, 64016 max)
initcall nf_conntrack_standalone_init+0x0/0xf returned 0 after 5043 use=
cs
calling  nf_conntrack_ftp_init+0x0/0x1ae @ 1
initcall nf_conntrack_ftp_init+0x0/0x1ae returned 0 after 3 usecs
calling  nf_conntrack_irc_init+0x0/0x15e @ 1
initcall nf_conntrack_irc_init+0x0/0x15e returned 0 after 2 usecs
calling  xt_init+0x0/0xc6 @ 1
initcall xt_init+0x0/0xc6 returned 0 after 4 usecs
calling  tcpudp_mt_init+0x0/0x14 @ 1
initcall tcpudp_mt_init+0x0/0x14 returned 0 after 2 usecs
calling  ip_vs_init+0x0/0xe9 @ 1
IPVS: Creating netns size=3D904 id=3D0
IPVS: __ip_vs_control_init(): alloc_percpu.
usb usb1: rpm_suspend flags 0xa
usb usb1: rpm_suspend returns 0
IPVS: cannot register namespace.
IPVS: can't setup control.
initcall ip_vs_init+0x0/0xe9 returned -12 after 27614 usecs
initcall ip_vs_init+0x0/0xe9 returned with error code -12=20
calling  ip_vs_rr_init+0x0/0xf @ 1
IPVS: [rr] scheduler registered.
initcall ip_vs_rr_init+0x0/0xf returned 0 after 2902 usecs
calling  ip_vs_wlc_init+0x0/0xf @ 1
IPVS: [wlc] scheduler registered.
initcall ip_vs_wlc_init+0x0/0xf returned 0 after 2978 usecs
calling  ip_vs_lblc_init+0x0/0x33 @ 1
IPVS: [lblc] scheduler registered.
initcall ip_vs_lblc_init+0x0/0x33 returned 0 after 3080 usecs
calling  ip_vs_sed_init+0x0/0xf @ 1
IPVS: [sed] scheduler registered.
initcall ip_vs_sed_init+0x0/0xf returned 0 after 2987 usecs
calling  ip_vs_nq_init+0x0/0xf @ 1
IPVS: [nq] scheduler registered.
initcall ip_vs_nq_init+0x0/0xf returned 0 after 2902 usecs
calling  sysctl_ipv4_init+0x0/0x71 @ 1
initcall sysctl_ipv4_init+0x0/0x71 returned 0 after 274 usecs
calling  init_syncookies+0x0/0x16 @ 1
initcall init_syncookies+0x0/0x16 returned 0 after 31 usecs
calling  ah4_init+0x0/0x63 @ 1
initcall ah4_init+0x0/0x63 returned 0 after 2 usecs
calling  esp4_init+0x0/0x63 @ 1
initcall esp4_init+0x0/0x63 returned 0 after 1 usecs
calling  tunnel4_init+0x0/0x63 @ 1
initcall tunnel4_init+0x0/0x63 returned 0 after 1 usecs
calling  ipv4_netfilter_init+0x0/0x10 @ 1
initcall ipv4_netfilter_init+0x0/0x10 returned 0 after 1 usecs
calling  ip_tables_init+0x0/0x8d @ 1
ip_tables: (C) 2000-2006 Netfilter Core Team
initcall ip_tables_init+0x0/0x8d returned 0 after 3935 usecs
calling  iptable_mangle_init+0x0/0x40 @ 1
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D
BUG kmalloc-1024: Poison overwritten
-----------------------------------------------------------------------=
------

INFO: 0xbd542464-0xbd54246f. First byte 0x0 instead of 0x6b
INFO: Allocated in ops_init.constprop.5+0x4a/0xe0 age=3D186 cpu=3D1 pid=
=3D1
INFO: Freed in ops_free+0x2a/0x30 age=3D168 cpu=3D1 pid=3D1
INFO: Slab 0xbf818800 objects=3D15 used=3D8 fp=3D0xbd542180 flags=3D0x3=
d0040c1
INFO: Object 0xbd542180 @offset=3D8576 fp=3D0xbd5425b0

Bytes b4 0xbd542170:  00 00 00 00 00 00 00 00 5a 5a 5a 5a 5a 5a 5a 5a .=
=2E......ZZZZZZZZ
  Object 0xbd542180:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b k=
kkkkkkkkkkkkkkk
  Object 0xbd542190:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b k=
kkkkkkkkkkkkkkk
  Object 0xbd5421a0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b k=
kkkkkkkkkkkkkkk
  Object 0xbd5421b0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b k=
kkkkkkkkkkkkkkk
  Object 0xbd5421c0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b k=
kkkkkkkkkkkkkkk
  Object 0xbd5421d0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b k=
kkkkkkkkkkkkkkk
  Object 0xbd5421e0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b k=
kkkkkkkkkkkkkkk
  Object 0xbd5421f0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b k=
kkkkkkkkkkkkkkk
  Object 0xbd542200:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b k=
kkkkkkkkkkkkkkk
  Object 0xbd542210:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b k=
kkkkkkkkkkkkkkk
  Object 0xbd542220:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b k=
kkkkkkkkkkkkkkk
  Object 0xbd542230:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b k=
kkkkkkkkkkkkkkk
  Object 0xbd542240:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b k=
kkkkkkkkkkkkkkk
  Object 0xbd542250:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b k=
kkkkkkkkkkkkkkk
  Object 0xbd542260:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b k=
kkkkkkkkkkkkkkk
  Object 0xbd542270:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b k=
kkkkkkkkkkkkkkk
  Object 0xbd542280:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b k=
kkkkkkkkkkkkkkk
  Object 0xbd542290:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b k=
kkkkkkkkkkkkkkk
  Object 0xbd5422a0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b k=
kkkkkkkkkkkkkkk
  Object 0xbd5422b0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b k=
kkkkkkkkkkkkkkk
  Object 0xbd5422c0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b k=
kkkkkkkkkkkkkkk
  Object 0xbd5422d0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b k=
kkkkkkkkkkkkkkk
  Object 0xbd5422e0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b k=
kkkkkkkkkkkkkkk
  Object 0xbd5422f0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b k=
kkkkkkkkkkkkkkk
  Object 0xbd542300:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b k=
kkkkkkkkkkkkkkk
  Object 0xbd542310:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b k=
kkkkkkkkkkkkkkk
  Object 0xbd542320:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b k=
kkkkkkkkkkkkkkk
  Object 0xbd542330:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b k=
kkkkkkkkkkkkkkk
  Object 0xbd542340:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b k=
kkkkkkkkkkkkkkk
  Object 0xbd542350:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b k=
kkkkkkkkkkkkkkk
  Object 0xbd542360:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b k=
kkkkkkkkkkkkkkk
  Object 0xbd542370:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b k=
kkkkkkkkkkkkkkk
  Object 0xbd542380:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b k=
kkkkkkkkkkkkkkk
  Object 0xbd542390:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b k=
kkkkkkkkkkkkkkk
  Object 0xbd5423a0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b k=
kkkkkkkkkkkkkkk
  Object 0xbd5423b0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b k=
kkkkkkkkkkkkkkk
  Object 0xbd5423c0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b k=
kkkkkkkkkkkkkkk
  Object 0xbd5423d0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b k=
kkkkkkkkkkkkkkk
  Object 0xbd5423e0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b k=
kkkkkkkkkkkkkkk
  Object 0xbd5423f0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b k=
kkkkkkkkkkkkkkk
  Object 0xbd542400:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b k=
kkkkkkkkkkkkkkk
  Object 0xbd542410:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b k=
kkkkkkkkkkkkkkk
  Object 0xbd542420:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b k=
kkkkkkkkkkkkkkk
  Object 0xbd542430:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b k=
kkkkkkkkkkkkkkk
  Object 0xbd542440:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b k=
kkkkkkkkkkkkkkk
  Object 0xbd542450:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b k=
kkkkkkkkkkkkkkk
  Object 0xbd542460:  6b 6b 6b 6b 00 5c 26 05 e0 75 54 bd 80 14 c1 81 k=
kkk.\&.=EF=BF=BDuT=EF=BF=BD..=EF=BF=BD.
  Object 0xbd542470:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b k=
kkkkkkkkkkkkkkk
  Object 0xbd542480:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b k=
kkkkkkkkkkkkkkk
  Object 0xbd542490:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b k=
kkkkkkkkkkkkkkk
  Object 0xbd5424a0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b k=
kkkkkkkkkkkkkkk
  Object 0xbd5424b0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b k=
kkkkkkkkkkkkkkk
  Object 0xbd5424c0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b k=
kkkkkkkkkkkkkkk
  Object 0xbd5424d0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b k=
kkkkkkkkkkkkkkk
  Object 0xbd5424e0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b k=
kkkkkkkkkkkkkkk
  Object 0xbd5424f0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b k=
kkkkkkkkkkkkkkk
  Object 0xbd542500:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b k=
kkkkkkkkkkkkkkk
  Object 0xbd542510:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b k=
kkkkkkkkkkkkkkk
  Object 0xbd542520:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b k=
kkkkkkkkkkkkkkk
  Object 0xbd542530:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b k=
kkkkkkkkkkkkkkk
  Object 0xbd542540:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b k=
kkkkkkkkkkkkkkk
  Object 0xbd542550:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b k=
kkkkkkkkkkkkkkk
  Object 0xbd542560:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b k=
kkkkkkkkkkkkkkk
  Object 0xbd542570:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b a5 k=
kkkkkkkkkkkkkk=EF=BF=BD
 Redzone 0xbd542580:  bb bb bb bb                                     =EF=
=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD           =20
 Padding 0xbd5425a8:  5a 5a 5a 5a 5a 5a 5a 5a                         Z=
ZZZZZZZ       =20
Pid: 1, comm: swapper Not tainted 2.6.38-tip-08708-g9ad1933-dirty #1095=
48
Call Trace:
 [<8109919b>] print_trailer+0xab/0x110
 [<8109932c>] check_bytes_and_report+0xdc/0x120
 [<8109a04b>] check_object+0x1db/0x230
 [<81098dbb>] ? check_valid_pointer+0x2b/0x60
 [<818bb338>] alloc_debug_processing+0x74/0xf2
 [<8102f834>] ? __call_console_drivers+0x64/0x80
 [<818bb878>] __slab_alloc.constprop.18+0x1a3/0x1fd
 [<81792dc1>] ? ipt_alloc_initial_table+0x31/0x1b0
 [<81792dc1>] ? ipt_alloc_initial_table+0x31/0x1b0
 [<8109b11a>] __kmalloc+0xca/0x100
 [<81792dc1>] ipt_alloc_initial_table+0x31/0x1b0
 [<81c74fa5>] iptable_mangle_net_init+0x11/0x4c
 [<816f89ef>] ops_init.constprop.5+0x2f/0xe0
 [<8173e5ea>] ? xt_register_match+0x4a/0x60
 [<816f8ae3>] register_pernet_operations+0x43/0x80
 [<816f8b8c>] register_pernet_subsys+0x1c/0x30
 [<81c74fee>] iptable_mangle_init+0xe/0x40
 [<81c3881e>] do_one_initcall+0x51/0x134
 [<81c74fe0>] ? iptable_mangle_init+0x0/0x40
 [<81c74fe0>] ? iptable_mangle_init+0x0/0x40
 [<81c38a2a>] kernel_init+0x129/0x1b5
 [<81c38901>] ? kernel_init+0x0/0x1b5
 [<818c907e>] kernel_thread_helper+0x6/0xd
=46IX kmalloc-1024: Restoring 0xbd542464-0xbd54246f=3D0x6b

=46IX kmalloc-1024: Marking all objects used
usb usb2: rpm_suspend flags 0x9
usb usb2: rpm_suspend returns 0
initcall iptable_mangle_init+0x0/0x40 returned 0 after 674576 usecs
calling  ulog_tg_init+0x0/0xe2 @ 1
initcall ulog_tg_init+0x0/0xe2 returned 0 after 9 usecs
calling  cubictcp_register+0x0/0x73 @ 1
TCP cubic registered
initcall cubictcp_register+0x0/0x73 returned 0 after 1879 usecs
calling  xfrm_user_init+0x0/0x41 @ 1
Initializing XFRM netlink socket
initcall xfrm_user_init+0x0/0x41 returned 0 after 2914 usecs
calling  inet6_init+0x0/0x27f @ 1
NET: Registered protocol family 10
initcall inet6_init+0x0/0x27f returned 0 after 6231 usecs
calling  ah6_init+0x0/0x63 @ 1
initcall ah6_init+0x0/0x63 returned 0 after 1 usecs
calling  esp6_init+0x0/0x63 @ 1
initcall esp6_init+0x0/0x63 returned 0 after 2 usecs
calling  ipcomp6_init+0x0/0x63 @ 1
initcall ipcomp6_init+0x0/0x63 returned 0 after 1 usecs
calling  xfrm6_tunnel_init+0x0/0xc5 @ 1
initcall xfrm6_tunnel_init+0x0/0xc5 returned 0 after 141 usecs
calling  tunnel6_init+0x0/0x63 @ 1
initcall tunnel6_init+0x0/0x63 returned 0 after 1 usecs
calling  xfrm6_transport_init+0x0/0x14 @ 1
initcall xfrm6_transport_init+0x0/0x14 returned 0 after 2 usecs
calling  xfrm6_mode_tunnel_init+0x0/0x14 @ 1
initcall xfrm6_mode_tunnel_init+0x0/0x14 returned 0 after 1 usecs
calling  xfrm6_ro_init+0x0/0x14 @ 1
initcall xfrm6_ro_init+0x0/0x14 returned 0 after 1 usecs
calling  mip6_init+0x0/0xb4 @ 1
Mobile IPv6
initcall mip6_init+0x0/0xb4 returned 0 after 1116 usecs
calling  ip6_tables_init+0x0/0x8d @ 1
ip6_tables: (C) 2000-2006 Netfilter Core Team
initcall ip6_tables_init+0x0/0x8d returned 0 after 4010 usecs
calling  nf_conntrack_l3proto_ipv6_init+0x0/0xd9 @ 1
initcall nf_conntrack_l3proto_ipv6_init+0x0/0xd9 returned 0 after 93 us=
ecs
calling  nf_defrag_init+0x0/0x4a @ 1
initcall nf_defrag_init+0x0/0x4a returned 0 after 23 usecs
calling  log_tg6_init+0x0/0x24 @ 1
initcall log_tg6_init+0x0/0x24 returned 0 after 1 usecs
calling  sit_init+0x0/0x52 @ 1
IPv6 over IPv4 tunneling driver
initcall sit_init+0x0/0x52 returned 0 after 3741 usecs
calling  packet_init+0x0/0x39 @ 1
NET: Registered protocol family 17
initcall packet_init+0x0/0x39 returned 0 after 3078 usecs
calling  ipsec_pfkey_init+0x0/0x69 @ 1
NET: Registered protocol family 15
