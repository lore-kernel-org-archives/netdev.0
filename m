From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Kernel Crash - 300+ Rule Creation
Date: Wed, 25 Aug 2010 23:47:21 +0200
Message-ID: <1282772841.2681.238.camel@edumazet-laptop>
References: <AANLkTimMDJ7J8Dk5t=1HkbxGiikL8r1F_TdbWvjiKpnj@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netfilter-devel@vger.kernel.org, netdev <netdev@vger.kernel.org>
To: Anand Raj Manickam <anandrm@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <AANLkTimMDJ7J8Dk5t=1HkbxGiikL8r1F_TdbWvjiKpnj@mail.gmail.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le mercredi 25 ao=C3=BBt 2010 =C3=A0 12:04 +0530, Anand Raj Manickam a =
=C3=A9crit :
> I m trying to create 300+ rules using a script without delay .
>=20
> I m NOT passing any traffic through the device , just rule creation .
>=20
> I m using  SMP 2.6.34 kernel , Xeon 5570 Quad core processor + 12 GB
>=20
> do let me know if any more information is need.
>=20
> Any help is appreciated.
>=20
> Thanks,
> Anand
>=20

nothing comes to mind here

COuld you please another kernel, maybe latest linux-2.6 tree ?

>=20
> Aug 24 18:28:34 debian kernel: ------------[ cut here ]------------
> Aug 24 18:28:34 debian kernel: kernel BUG at mm/vmalloc.c:304!
> Aug 24 18:28:34 debian kernel: invalid opcode: 0000 [#1] SMP
> Aug 24 18:28:34 debian kernel: last sysfs file: /sys/class/net/lo/ope=
rstate
> Aug 24 18:28:34 debian kernel: Modules linked in: xt_state
> nf_conntrack_ipv4 nf_defrag_ipv4 xt_physdev sch_htb  xt_IMQ imq
> nfnetlink nf_conntrack_sip nf_conntrack_ftp nf_conntrack
> iptable_mangle iptable_filter ip_tables x_tables bridge stp llc loop
> serio_raw ext3 jbd mbcache
> Aug 24 18:28:34 debian kernel:
> Aug 24 18:28:34 debian kernel: Pid: 22143, comm: iptables Not tainted
> 2.6.34-12-rcudbg-nohpet #1 Greencity/Thurley
> Aug 24 18:28:34 debian kernel: EIP: 0060:[<c108b1cd>] EFLAGS: 0001020=
7 CPU: 1
> Aug 24 18:28:34 debian kernel: EIP is at __insert_vmap_area+0x26/0x96
> Aug 24 18:28:34 debian kernel: EAX: 00000000 EBX: ffbbd000 ECX:
> 00000000 EDX: f66fcb4c
> Aug 24 18:28:34 debian kernel: ESI: f6086400 EDI: f6086400 EBP:
> 00443000 ESP: f6379d74
> Aug 24 18:28:34 debian kernel: DS: 007b ES: 007b FS: 00d8 GS: 0033 SS=
: 0068
> Aug 24 18:28:34 debian kernel: Process iptables (pid: 22143,
> ti=3Df6378000 task=3Df7534790 task.ti=3Df6378000)
> Aug 24 18:28:34 debian kernel: Stack:
> Aug 24 18:28:34 debian kernel: ffbbd000 f83fe000 c108ba08 00000000
> f6d02e00 ffffffff 00000000 00442fff
> Aug 24 18:28:34 debian kernel: <0> f83fe000 00000001 000000d0 f884100=
0
> f6086400 00000000 c7e82d48 c102cf4e
> Aug 24 18:28:34 debian kernel: <0> f6774ea0 f6774ea0 000080d0 0000000=
1
> c108bb09 ffbfe000 00000000 000000d2
> Aug 24 18:28:34 debian kernel: Call Trace:
> Aug 24 18:28:34 debian kernel: [<c108ba08>] ? alloc_vmap_area+0x207/0=
x219
> Aug 24 18:28:34 debian kernel: [<c102cf4e>] ? irq_exit+0x36/0x58
> Aug 24 18:28:34 debian kernel: [<c108bb09>] ? __get_vm_area_node+0xef=
/0x16c
> Aug 24 18:28:34 debian kernel: [<f8576f01>] ?
> xt_alloc_table_info+0x5e/0x97 [x_tables]
> Aug 24 18:28:34 debian kernel: [<c108c110>] ? __vmalloc_node+0x6c/0x9=
e
> Aug 24 18:28:34 debian kernel: [<f8576f01>] ?
> xt_alloc_table_info+0x5e/0x97 [x_tables]
> Aug 24 18:28:34 debian kernel: [<c108c1e7>] ? vmalloc_node+0x1d/0x21
> Aug 24 18:28:34 debian kernel: [<f8576f01>] ?
> xt_alloc_table_info+0x5e/0x97 [x_tables]
> Aug 24 18:28:34 debian kernel: [<f8576f01>] ?
> xt_alloc_table_info+0x5e/0x97 [x_tables]
> Aug 24 18:28:34 debian kernel: [<f85a2c85>] ?
> do_ipt_set_ctl+0x74/0x3f4 [ip_tables]
> Aug 24 18:28:34 debian kernel: [<c10760a1>] ? __alloc_pages_nodemask+=
0xe2/0x4de
> Aug 24 18:28:34 debian kernel: [<c121515e>] ? nf_sockopt+0x102/0x117
> Aug 24 18:28:34 debian kernel: [<c121519d>] ? nf_setsockopt+0x14/0x19
> Aug 24 18:28:34 debian kernel: [<c121f2fa>] ? ip_setsockopt+0x59/0x72
> Aug 24 18:28:34 debian kernel: [<c11f3a77>] ? sock_common_setsockopt+=
0x12/0x16
> Aug 24 18:28:34 debian kernel: [<c11f21aa>] ? sys_setsockopt+0x5e/0x7=
d
> Aug 24 18:28:34 debian kernel: [<c11f3776>] ? sys_socketcall+0x14d/0x=
1c3
> Aug 24 18:28:34 debian kernel: [<c10025cc>] ? sysenter_do_call+0x12/0=
x22
> Aug 24 18:28:34 debian kernel: Code: 01 5b 5e 5f c3 56 31 c9 89 c6 b8
> 94 36 45 c1 53 eb 1f 8b 06 3b 42 f8 73 05 8d 42 08 eb 11 8b 46 04 3b
> 42 f4 76 05 8d 42 04 eb 04 <0f> 0b eb fe 89 d1 8b 10 85 d2 75 db 8d 5=
e
> 0c ba 94 36 45 c1 89
> Aug 24 18:28:34 debian kernel: EIP: [<c108b1cd>]
> __insert_vmap_area+0x26/0x96 SS:ESP 0068:f6379d74
> Aug 24 18:28:34 debian kernel: ---[ end trace 0ee1ce01b56bccc5 ]---
> Aug 24 18:28:41 debian kernel: INFO: RCU detected CPU 0 stall (t=3D30=
00 jiffies)
> Aug 24 18:28:41 debian kernel: sending NMI to all CPUs:
> Aug 24 18:28:41 debian kernel: NMI backtrace for cpu 2
> Aug 24 18:28:41 debian kernel: Modules linked in: xt_state
> nf_conntrack_ipv4 nf_defrag_ipv4 xt_physdev sch_htb  xt_IMQ imq
> nfnetlink nf_conntrack_sip nf_conntrack_ftp nf_conntrack
> iptable_mangle iptable_filter ip_tables x_tables bridge stp llc loop
> serio_raw ext3 jbd mbcache
> Aug 24 18:28:41 debian kernel: Pid: 22145, comm: iptables Tainted: G
>    D    2.6.34-12-rcudbg-nohpet #1 Greencity/Thurley
> Aug 24 18:28:41 debian kernel: EIP: 0060:[<c1268b66>] EFLAGS: 0000029=
3 CPU: 2
> Aug 24 18:28:41 debian kernel: EIP is at _raw_spin_lock+0x10/0x15
> Aug 24 18:28:41 debian kernel: EAX: c1453684 EBX: f83fe000 ECX:
> 00000000 EDX: 00005351
> Aug 24 18:28:41 debian kernel: ESI: f83fe000 EDI: f6f88d40 EBP:
> 00443000 ESP: f556bd7c
> Aug 24 18:28:41 debian kernel: DS: 007b ES: 007b FS: 00d8 GS: 0033 SS=
: 0068
> Aug 24 18:28:41 debian kernel: Process iptables (pid: 22145,
> ti=3Df556a000 task=3Df6eb0790 task.ti=3Df556a000)
> Aug 24 18:28:41 debian kernel: Stack:
> Aug 24 18:28:41 debian kernel: c108b8c0 003fffff ffffffff ffffffff
> 00000000 00000002 f83fe000 00000001
> Aug 24 18:28:41 debian kernel: <0> 000000d0 00000010 f6f88d40 0000000=
0
> 00000002 00000000 f6c9c500 f6c9c500
> Aug 24 18:28:41 debian kernel: <0> 000080d0 00000001 c108bb09 ffbfe00=
0
> 00000000 000000d2 00000002 00000020
> Aug 24 18:28:41 debian kernel: Call Trace:
> Aug 24 18:28:41 debian kernel: [<c108b8c0>] ? alloc_vmap_area+0xbf/0x=
219
> Aug 24 18:28:41 debian kernel: [<c108bb09>] ? __get_vm_area_node+0xef=
/0x16c
> Aug 24 18:28:41 debian kernel: [<f8576f01>] ?
> xt_alloc_table_info+0x5e/0x97 [x_tables]
> Aug 24 18:28:41 debian kernel: [<c108c110>] ? __vmalloc_node+0x6c/0x9=
e
> Aug 24 18:28:41 debian kernel: [<f8576f01>] ?
> xt_alloc_table_info+0x5e/0x97 [x_tables]
> Aug 24 18:28:41 debian kernel: [<c108c1e7>] ? vmalloc_node+0x1d/0x21
> Aug 24 18:28:41 debian kernel: [<f8576f01>] ?
> xt_alloc_table_info+0x5e/0x97 [x_tables]
> Aug 24 18:28:41 debian kernel: [<f8576f01>] ?
> xt_alloc_table_info+0x5e/0x97 [x_tables]
> Aug 24 18:28:41 debian kernel: [<f85a2c85>] ?
> do_ipt_set_ctl+0x74/0x3f4 [ip_tables]
> Aug 24 18:28:41 debian kernel: [<c10760a1>] ? __alloc_pages_nodemask+=
0xe2/0x4de
> Aug 24 18:28:41 debian kernel: [<c102cf4e>] ? irq_exit+0x36/0x58
> Aug 24 18:28:41 debian kernel: [<c121515e>] ? nf_sockopt+0x102/0x117
> Aug 24 18:28:41 debian kernel: [<c121519d>] ? nf_setsockopt+0x14/0x19
> Aug 24 18:28:41 debian kernel: [<c121f2fa>] ? ip_setsockopt+0x59/0x72
> Aug 24 18:28:41 debian kernel: [<c11f3a77>] ? sock_common_setsockopt+=
0x12/0x16
> Aug 24 18:28:41 debian kernel: [<c11f21aa>] ? sys_setsockopt+0x5e/0x7=
d
> Aug 24 18:28:41 debian kernel: [<c11f3776>] ? sys_socketcall+0x14d/0x=
1c3
> Aug 24 18:28:41 debian kernel: [<c10025cc>] ? sysenter_do_call+0x12/0=
x22
> Aug 24 18:28:41 debian kernel: Code: 01 00 00 75 05 f0 66 0f b1 0b 0f
> 94 c1 0f b6 c1 89 c2 31 c0 85 d2 0f 95 c0 5b c3 ba 00 01 00 00 f0 66
> 0f c1 10 38 f2 74 06 f3 90 <8a> 10 eb f6 c3 9c 5a fa b9 00 01 00 00 f=
0
> 66 0f c1 08 38 e9 74
> Aug 24 18:28:41 debian kernel: Call Trace:
> Aug 24 18:28:41 debian kernel: [<c108b8c0>] ? alloc_vmap_area+0xbf/0x=
219
> Aug 24 18:28:41 debian kernel: [<c108bb09>] ? __get_vm_area_node+0xef=
/0x16c
> Aug 24 18:28:41 debian kernel: [<f8576f01>] ?
> xt_alloc_table_info+0x5e/0x97 [x_tables]
> Aug 24 18:28:41 debian kernel: [<c108c110>] ? __vmalloc_node+0x6c/0x9=
e
> Aug 24 18:28:41 debian kernel: [<f8576f01>] ?
> xt_alloc_table_info+0x5e/0x97 [x_tables]
> Aug 24 18:28:41 debian kernel: [<c108c1e7>] ? vmalloc_node+0x1d/0x21
> Aug 24 18:28:41 debian kernel: [<f8576f01>] ?
> xt_alloc_table_info+0x5e/0x97 [x_tables]
> Aug 24 18:28:41 debian kernel: [<f8576f01>] ?
> xt_alloc_table_info+0x5e/0x97 [x_tables]
> Aug 24 18:28:41 debian kernel: [<f85a2c85>] ?
> do_ipt_set_ctl+0x74/0x3f4 [ip_tables]
> Aug 24 18:28:41 debian kernel: [<c10760a1>] ? __alloc_pages_nodemask+=
0xe2/0x4de
> Aug 24 18:28:41 debian kernel: [<c102cf4e>] ? irq_exit+0x36/0x58
> Aug 24 18:28:41 debian kernel: [<c121515e>] ? nf_sockopt+0x102/0x117
> Aug 24 18:28:41 debian kernel: [<c121519d>] ? nf_setsockopt+0x14/0x19
> Aug 24 18:28:41 debian kernel: [<c121f2fa>] ? ip_setsockopt+0x59/0x72
> Aug 24 18:28:41 debian kernel: [<c11f3a77>] ? sock_common_setsockopt+=
0x12/0x16
> Aug 24 18:28:41 debian kernel: [<c11f21aa>] ? sys_setsockopt+0x5e/0x7=
d
> Aug 24 18:28:41 debian kernel: [<c11f3776>] ? sys_socketcall+0x14d/0x=
1c3
> Aug 24 18:28:41 debian kernel: [<c10025cc>] ? sysenter_do_call+0x12/0=
x22
> Aug 24 18:28:41 debian kernel: Pid: 22145, comm: iptables Tainted: G
>    D    2.6.34-12-rcudbg-nohpet #1
> Aug 24 18:28:41 debian kernel: Call Trace:
> Aug 24 18:28:41 debian kernel: [<c1012548>] ? nmi_watchdog_tick+0x9b/=
0x155
> Aug 24 18:28:41 debian kernel: [<c100353e>] ? do_nmi+0x8c/0x262
> Aug 24 18:28:41 debian kernel: [<c1269535>] ? nmi_stack_correct+0x28/=
0x2d
> Aug 24 18:28:41 debian kernel: [<c1268b66>] ? _raw_spin_lock+0x10/0x1=
5
> Aug 24 18:28:41 debian kernel: [<c108b8c0>] ? alloc_vmap_area+0xbf/0x=
219
> Aug 24 18:28:41 debian kernel: [<c108bb09>] ? __get_vm_area_node+0xef=
/0x16c
> Aug 24 18:28:41 debian kernel: [<f8576f01>] ?
> xt_alloc_table_info+0x5e/0x97 [x_tables]
> Aug 24 18:28:41 debian kernel: [<c108c110>] ? __vmalloc_node+0x6c/0x9=
e
> Aug 24 18:28:41 debian kernel: [<f8576f01>] ?
> xt_alloc_table_info+0x5e/0x97 [x_tables]
> Aug 24 18:28:41 debian kernel: [<c108c1e7>] ? vmalloc_node+0x1d/0x21
> Aug 24 18:28:41 debian kernel: [<f8576f01>] ?
> xt_alloc_table_info+0x5e/0x97 [x_tables]
> Aug 24 18:28:41 debian kernel: [<f8576f01>] ?
> xt_alloc_table_info+0x5e/0x97 [x_tables]
> Aug 24 18:28:41 debian kernel: [<f85a2c85>] ?
> do_ipt_set_ctl+0x74/0x3f4 [ip_tables]
> Aug 24 18:28:41 debian kernel: [<c10760a1>] ? __alloc_pages_nodemask+=
0xe2/0x4de
> Aug 24 18:28:41 debian kernel: [<c102cf4e>] ? irq_exit+0x36/0x58
> Aug 24 18:28:41 debian kernel: [<c121515e>] ? nf_sockopt+0x102/0x117
> Aug 24 18:28:41 debian kernel: [<c121519d>] ? nf_setsockopt+0x14/0x19
> Aug 24 18:28:41 debian kernel: [<c121f2fa>] ? ip_setsockopt+0x59/0x72
> Aug 24 18:28:41 debian kernel: [<c11f3a77>] ? sock_common_setsockopt+=
0x12/0x16
> Aug 24 18:28:41 debian kernel: [<c11f21aa>] ? sys_setsockopt+0x5e/0x7=
d
> Aug 24 18:28:41 debian kernel: [<c11f3776>] ? sys_socketcall+0x14d/0x=
1c3
> Aug 24 18:28:41 debian kernel: [<c10025cc>] ? sysenter_do_call+0x12/0=
x22
> Aug 24 18:28:41 debian kernel: NMI backtrace for cpu 3
> Aug 24 18:28:41 debian kernel: Modules linked in: xt_state
> nf_conntrack_ipv4 nf_defrag_ipv4 xt_physdev sch_htb  xt_IMQ imq
> nfnetlink nf_conntrack_sip nf_conntrack_ftp nf_conntrack
> iptable_mangle iptable_filter ip_tables x_tables bridge stp llc loop
> serio_raw ext3 jbd mbcache
> Aug 24 18:28:41 debian kernel:
> Aug 24 18:28:41 debian kernel: Pid: 0, comm: swapper Tainted: G      =
D
>    2.6.34-12-rcudbg-nohpet #1 Greencity/Thurley
> Aug 24 18:28:41 debian kernel: EIP: 0060:[<c1006d53>] EFLAGS: 0000024=
6 CPU: 3
> Aug 24 18:28:41 debian kernel: EIP is at mwait_idle+0x7a/0x7f
> Aug 24 18:28:41 debian kernel: EAX: 00000000 EBX: f7496000 ECX:
> 00000000 EDX: 00000000
> Aug 24 18:28:41 debian kernel: ESI: c13a5b28 EDI: 00000000 EBP:
> 00000000 ESP: f7497fa4
> Aug 24 18:28:41 debian kernel: DS: 007b ES: 007b FS: 00d8 GS: 0000 SS=
: 0068
> Aug 24 18:28:41 debian kernel: Process swapper (pid: 0, ti=3Df7496000
> task=3Df7476b40 task.ti=3Df7496000)
> Aug 24 18:28:41 debian kernel: Stack:
> Aug 24 18:28:41 debian kernel: 00000003 c1001924 06100800 00000000
> 00000000 00000000 00000000 00000000
> Aug 24 18:28:41 debian kernel: <0> 00000000 00000000 00000000 0000000=
0
> 00000000 000000d8 00000000 00000000
> Aug 24 18:28:41 debian kernel: <0> 00000000 00000000 00000000 0000000=
0
> 00000000 00000000 00000000
> Aug 24 18:28:41 debian kernel: Call Trace:
> Aug 24 18:28:41 debian kernel: [<c1001924>] ? cpu_idle+0x41/0x5d
> Aug 24 18:28:41 debian kernel: Code: ff 8d 42 08 0f ae 7a 08 89 e3 31
> c9 81 e3 00 e0 ff ff 89 ca 8d 43 08 0f 01 c8 0f ae f0 89 f6 f6 43 08
> 08 75 08 89 c8 fb 0f 01 c9 <eb> 01 fb 5b c3 83 3d 24 2d 3a c1 00 53 7=
4
> 1b 8b 1d 30 2d 3a c1
> Aug 24 18:28:41 debian kernel: Call Trace:
> Aug 24 18:28:41 debian kernel: [<c1001924>] ? cpu_idle+0x41/0x5d
> Aug 24 18:28:41 debian kernel: Pid: 0, comm: swapper Tainted: G      =
D
>    2.6.34-12-rcudbg-nohpet #1
> Aug 24 18:28:41 debian kernel: Call Trace:
> Aug 24 18:28:41 debian kernel: [<c1012548>] ? nmi_watchdog_tick+0x9b/=
0x155
> Aug 24 18:28:41 debian kernel: [<c100353e>] ? do_nmi+0x8c/0x262
> Aug 24 18:28:41 debian kernel: [<c1269535>] ? nmi_stack_correct+0x28/=
0x2d
> --
> To unsubscribe from this list: send the line "unsubscribe netfilter-d=
evel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html


--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
