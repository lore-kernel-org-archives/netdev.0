From: Smart Weblications GmbH - Florian Wiessner
	<f.wiessner@smart-weblications.de>
Subject: 3.12.33 - BUG xfrm_selector_match+0x25/0x2f6
Date: Wed, 03 Dec 2014 15:55:30 +0100
Message-ID: <547F2462.6040405@smart-weblications.de>
Reply-To: f.wiessner@smart-weblications.de
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>,
	stable@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.smart-weblications.de ([188.65.144.61]:55866 "EHLO
	mail.smart-weblications.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750963AbaLCOzM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Dec 2014 09:55:12 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi list,



[16623.095403] BUG: unable to handle kernel paging request at 000000000=
10600d0
[16623.095445] IP: [<ffffffff81547767>] xfrm_selector_match+0x25/0x2f6
[16623.095480] PGD aeaea067 PUD 85d95067 PMD 0
[16623.095513] Oops: 0000 [#1] SMP
[16623.095543] Modules linked in: netconsole xt_nat xt_multiport veth i=
p_vs_rr
nfsd lockd nfs_acl auth_rpcgss sunrpc oid_registry iptable_mangle xt_ma=
rk
nf_conntrack_netlink nfnetlink ipt_MASQUERADE iptable_nat nf_nat_ipv4
nf_conntrack_ipv4 nf_defrag_ipv4 ipt_REJECT xt_tcpudp iptable_filter ip=
_tables
cpufreq_ondemand cpufreq_powersave cpufreq_conservative cpufreq_userspa=
ce
ocfs2_stack_o2cb ocfs2_dlm bridge stp llc bonding fuse nf_conntrack_ftp=
 8021q
openvswitch gre vxlan xt_conntrack x_tables ocfs2_dlmfs dlm sctp ocfs2
ocfs2_nodemanager ocfs2_stackglue configfs rbd kvm_intel kvm coretemp i=
p_vs_ftp
ip_vs nf_nat nf_conntrack ctr twofish_generic twofish_x86_64 twofish_co=
mmon
camellia_generic serpent_generic blowfish_generic blowfish_common cast5=
_generic
cast_common xcbc sha512_generic crypto_null af_key xfrm_algo psmouse se=
rio_raw
i2c_i801 lpc_ich mfd_core evdev btrfs lzo_decompress lzo_compress
[16623.096062] CPU: 0 PID: 0 Comm: swapper/0 Not tainted 3.12.33 #1
[16623.096091] Hardware name: Supermicro X9SCI/X9SCA/X9SCI/X9SCA, BIOS =
1.1a
09/28/2011
[16623.096137] task: ffffffff81804450 ti: ffffffff817f4000 task.ti: fff=
fffff817f4000
[16623.096182] RIP: 0010:[<ffffffff81547767>]  [<ffffffff81547767>]
xfrm_selector_match+0x25/0x2f6
[16623.096233] RSP: 0018:ffff88083fc03900  EFLAGS: 00010246
[16623.096261] RAX: 0000000000000001 RBX: ffff88083fc03a20 RCX: ffff880=
787fb1200
[16623.096292] RDX: 0000000000000002 RSI: ffff88083fc03a20 RDI: 0000000=
0010600a6
[16623.096323] RBP: 00000000010600a6 R08: 0000000000000000 R09: ffff880=
83fc039a0
[16623.096353] R10: 0000000000000000 R11: 0000000000000001 R12: ffff880=
83fc03a20
[16623.096383] R13: 0000000000000001 R14: ffffffff818a9700 R15: fffffff=
fa01c73e0
[16623.096414] FS:  0000000000000000(0000) GS:ffff88083fc00000(0000)
knlGS:0000000000000000
[16623.096469] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[16623.096498] CR2: 00000000010600d0 CR3: 0000000085f0b000 CR4: 0000000=
0000407f0
[16623.096528] Stack:
[16623.096550]  0000000000000000 0000000001060002 ffff880787fb1200 ffff=
88083fc03a20
[16623.096602]  0000000000000001 ffffffff81547a7c 0000000000000000 ffff=
8800baad5480
[16623.096655]  ffffffff81804450 ffffffff818a9700 000000003c9041bc ffff=
ffff81547ef7
[16623.096721] Call Trace:
[16623.096744]  <IRQ>
[16623.096749]  [<ffffffff81547a7c>] ? xfrm_sk_policy_lookup+0x44/0x9b
[16623.096802]  [<ffffffff81547ef7>] ? xfrm_lookup+0x91/0x446
[16623.096832]  [<ffffffff81541316>] ? ip_route_me_harder+0x150/0x1b0
[16623.096865]  [<ffffffffa01b6457>] ? ip_vs_route_me_harder+0x86/0x91 =
[ip_vs]
[16623.096899]  [<ffffffffa01b797a>] ? ip_vs_out+0x2d3/0x5bc [ip_vs]
[16623.096930]  [<ffffffff81501420>] ? ip_rcv_finish+0x2b8/0x2b8
[16623.096959]  [<ffffffff814fc2d3>] ? nf_iterate+0x42/0x80
[16623.096989]  [<ffffffff814fc37a>] ? nf_hook_slow+0x69/0xff
[16623.097017]  [<ffffffff81501420>] ? ip_rcv_finish+0x2b8/0x2b8
[16623.097047]  [<ffffffff81501744>] ? ip_local_deliver+0x6f/0x7e
[16623.097078]  [<ffffffff814d82a6>] ? __netif_receive_skb_core+0x5f0/0=
x66c
[16623.097108]  [<ffffffff814d84b7>] ? process_backlog+0x13e/0x13e
[16623.097140]  [<ffffffffa04b4e09>] ? br_handle_frame_finish+0x382/0x3=
82 [bridge]
[16623.097187]  [<ffffffff814d8503>] ? netif_receive_skb+0x4c/0x7d
[16623.097218]  [<ffffffffa04b4d95>] ? br_handle_frame_finish+0x30e/0x3=
82 [bridge]
[16623.097265]  [<ffffffffa04b4fda>] ? br_handle_frame+0x1d1/0x217 [bri=
dge]
[16623.097297]  [<ffffffffa048e4aa>] ? bond_handle_frame+0x86/0x1bd [bo=
nding]
[16623.097328]  [<ffffffff814d8155>] ? __netif_receive_skb_core+0x49f/0=
x66c
[16623.097358]  [<ffffffff814d8503>] ? netif_receive_skb+0x4c/0x7d
[16623.097388]  [<ffffffff814d9091>] ? napi_gro_receive+0x35/0x76
[16623.097418]  [<ffffffff813eae17>] ? e1000_clean_rx_irq+0x26d/0x2f5
[16623.097448]  [<ffffffff813ef48e>] ? e1000e_poll+0x65/0x23d
[16623.097477]  [<ffffffff814d8709>] ? net_rx_action+0xa2/0x1c0
[16623.097507]  [<ffffffff8136895c>] ? credit_entropy_bits.part.7+0x127=
/0x168
[16623.097540]  [<ffffffff8103cd9c>] ? __do_softirq+0xe8/0x201
[16623.097569]  [<ffffffff815ae61c>] ? call_softirq+0x1c/0x30
[16623.097599]  [<ffffffff810042ad>] ? do_softirq+0x2c/0x5f
[16623.097627]  [<ffffffff8103cf7a>] ? irq_exit+0x3b/0x7f
[16623.097655]  [<ffffffff81003d90>] ? do_IRQ+0x91/0xa8
[16623.097684]  [<ffffffff815ac7ea>] ? common_interrupt+0x6a/0x6a
[16623.097713]  <EOI>
[16623.097718]  [<ffffffff8105549a>] ? enqueue_hrtimer+0x36/0x6d
[16623.097771]  [<ffffffff814a904d>] ? cpuidle_enter_state+0x43/0xa6
[16623.097801]  [<ffffffff814a9046>] ? cpuidle_enter_state+0x3c/0xa6
[16623.097831]  [<ffffffff814a91a2>] ? cpuidle_idle_call+0xf2/0x19e
[16623.097862]  [<ffffffff8100a2b8>] ? arch_cpu_idle+0x6/0x17
[16623.097892]  [<ffffffff81071715>] ? cpu_startup_entry+0x119/0x1a8
[16623.097921]  [<ffffffff818f6cf3>] ? start_kernel+0x3ca/0x3d5
[16623.097951]  [<ffffffff818f673f>] ? repair_env_string+0x57/0x57
[16623.097979] Code: 5d 41 5e 41 5f c3 41 55 66 83 fa 02 41 54 55 48 89=
 fd 53 48
89 f3 41 50 74 11 31 c0 66 83 fa 0a 0f 85 ce 02 00 00 e9 fd 00 00 00 <0=
f> b6 47
2a 8b 17 8b 76 18 84 c0 74 1a b9 20 00 00 00 31 f2 29
[16623.098244] RIP  [<ffffffff81547767>] xfrm_selector_match+0x25/0x2f6
[16623.098459]  RSP <ffff88083fc03900>
[16623.098484] CR2: 00000000010600d0
[16623.098903] ---[ end trace 36545dfc8f7672ee ]---
[16623.098996] Kernel panic - not syncing: Fatal exception in interrupt
[16623.099085] Rebooting in 10 seconds..
[16633.158496] ACPI MEMORY or I/O RESET_REG.


This happens again and again with 3.12.33


see also: http://www.spinics.net/lists/netdev/msg306283.html

is this already fixed somehow?


--=20

Mit freundlichen Gr=FC=DFen,

=46lorian Wiessner

Smart Weblications GmbH
Martinsberger Str. 1
D-95119 Naila

fon.: +49 9282 9638 200
fax.: +49 9282 9638 205
24/7: +49 900 144 000 00 - 0,99 EUR/Min*
http://www.smart-weblications.de

--
Sitz der Gesellschaft: Naila
Gesch=E4ftsf=FChrer: Florian Wiessner
HRB-Nr.: HRB 3840 Amtsgericht Hof
*aus dem dt. Festnetz, ggf. abweichende Preise aus dem Mobilfunknetz
