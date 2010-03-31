From: =?ISO-8859-2?Q?Pawe=B3_Staszewski?= <pstaszewski@itcare.pl>
Subject: Re: eth1: Detected Hardware Unit Hang
Date: Wed, 31 Mar 2010 09:47:15 +0200
Message-ID: <4BB2FE03.4090608@itcare.pl>
References: <4BB0C853.2080607@itcare.pl> <8DD2590731AB5D4C9DBF71A877482A9061BB3254@orsmsx509.amr.corp.intel.com> <4BB0E394.2060908@itcare.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux Network Development list <netdev@vger.kernel.org>,
	"e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>
To: "Allan, Bruce W" <bruce.w.allan@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.iq.pl ([86.111.241.19]:52771 "EHLO smtp.iq.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756139Ab0CaHrW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 31 Mar 2010 03:47:22 -0400
In-Reply-To: <4BB0E394.2060908@itcare.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello

I reproduce this problem on other machine with the same hardware and=20
here is dmesg output: (kernel 2.6.33)

Mar 27 18:19:16 TM_01_C1 [1817894.769395] 0000:04:00.0: eth0: Detected=20
Hardware Unit Hang:
Mar 27 18:19:16 TM_01_C1 [1817894.769396]   TDH <2e>
Mar 27 18:19:16 TM_01_C1 [1817894.769397]   TDT <1a>
Mar 27 18:19:16 TM_01_C1 [1817894.769397]   next_to_use <1a>
Mar 27 18:19:16 TM_01_C1 [1817894.769398]   next_to_clean <2d>
Mar 27 18:19:16 TM_01_C1 [1817894.769398] buffer_info[next_to_clean]:
Mar 27 18:19:16 TM_01_C1 [1817894.769399]   time_stamp <11b1591e9>
Mar 27 18:19:16 TM_01_C1 [1817894.769399]   next_to_watch <2f>
Mar 27 18:19:16 TM_01_C1 [1817894.769400]   jiffies <11b1592e4>
Mar 27 18:19:16 TM_01_C1 [1817894.769401]   next_to_watch.status <0>
Mar 27 18:19:16 TM_01_C1 [1817894.769401] MAC Status <80080783>
Mar 27 18:19:16 TM_01_C1 [1817894.769402] PHY Status <796d>
Mar 27 18:19:16 TM_01_C1 [1817894.769402] PHY 1000BASE-T Status <3800>
Mar 27 18:19:16 TM_01_C1 [1817894.769403] PHY Extended Status <3000>
Mar 27 18:19:16 TM_01_C1 [1817894.769404] PCI Status <10>
Mar 27 18:19:18 TM_01_C1 [1817896.773365] 0000:04:00.0: eth0: Detected=20
Hardware Unit Hang:
Mar 27 18:19:18 TM_01_C1 [1817896.773367]   TDH <2e>
Mar 27 18:19:18 TM_01_C1 [1817896.773368]   TDT <1a>
Mar 27 18:19:18 TM_01_C1 [1817896.773368]   next_to_use <1a>
Mar 27 18:19:18 TM_01_C1 [1817896.773369]   next_to_clean <2d>
Mar 27 18:19:18 TM_01_C1 [1817896.773369] buffer_info[next_to_clean]:
Mar 27 18:19:18 TM_01_C1 [1817896.773370]   time_stamp <11b1591e9>
Mar 27 18:19:18 TM_01_C1 [1817896.773370]   next_to_watch <2f>
Mar 27 18:19:18 TM_01_C1 [1817896.773371]   jiffies <11b1594d8>
Mar 27 18:19:18 TM_01_C1 [1817896.773372]   next_to_watch.status <0>
Mar 27 18:19:18 TM_01_C1 [1817896.773372] MAC Status <80080783>
Mar 27 18:19:18 TM_01_C1 [1817896.773373] PHY Status <796d>
Mar 27 18:19:18 TM_01_C1 [1817896.773373] PHY 1000BASE-T Status <3800>
Mar 27 18:19:18 TM_01_C1 [1817896.773374] PHY Extended Status <3000>
Mar 27 18:19:18 TM_01_C1 [1817896.773375] PCI Status <10>
Mar 27 18:19:20 TM_01_C1 [1817898.769353] 0000:04:00.0: eth0: Detected=20
Hardware Unit Hang:
Mar 27 18:19:20 TM_01_C1 [1817898.769355]   TDH <2e>
Mar 27 18:19:20 TM_01_C1 [1817898.769355]   TDT <1a>
Mar 27 18:19:20 TM_01_C1 [1817898.769356]   next_to_use <1a>
Mar 27 18:19:20 TM_01_C1 [1817898.769356]   next_to_clean <2d>
Mar 27 18:19:20 TM_01_C1 [1817898.769357] buffer_info[next_to_clean]:
Mar 27 18:19:20 TM_01_C1 [1817898.769358]   time_stamp <11b1591e9>
Mar 27 18:19:20 TM_01_C1 [1817898.769358]   next_to_watch <2f>
Mar 27 18:19:20 TM_01_C1 [1817898.769359]   jiffies <11b1596cc>
Mar 27 18:19:20 TM_01_C1 [1817898.769359]   next_to_watch.status <0>
Mar 27 18:19:20 TM_01_C1 [1817898.769360] MAC Status <80080783>
Mar 27 18:19:20 TM_01_C1 [1817898.769361] PHY Status <796d>
Mar 27 18:19:20 TM_01_C1 [1817898.769361] PHY 1000BASE-T Status <3800>
Mar 27 18:19:20 TM_01_C1 [1817898.769362] PHY Extended Status <3000>
Mar 27 18:19:20 TM_01_C1 [1817898.769362] PCI Status <18>
Mar 27 18:19:21 TM_01_C1 [1817899.773012] ------------[ cut here=20
]------------
Mar 27 18:19:21 TM_01_C1 [1817899.773023] WARNING: at=20
net/sched/sch_generic.c:255 dev_watchdog+0x130/0x1d3()
Mar 27 18:19:21 TM_01_C1 [1817899.773026] Hardware name: X7DCT
Mar 27 18:19:21 TM_01_C1 [1817899.773028] NETDEV WATCHDOG: eth0=20
(e1000e): transmit queue 0 timed out
Mar 27 18:19:21 TM_01_C1 [1817899.773030] Modules linked in: coretemp=20
hwmon_vid hwmon [last unloaded: w83627hf]
Mar 27 18:19:21 TM_01_C1 [1817899.773038] Pid: 0, comm: swapper Not=20
tainted 2.6.33 #2
Mar 27 18:19:21 TM_01_C1 [1817899.773040] Call Trace:
Mar 27 18:19:21 TM_01_C1 [1817899.773042] <IRQ>  [<ffffffff813003b3>] ?=
=20
dev_watchdog+0x130/0x1d3
Mar 27 18:19:21 TM_01_C1 [1817899.773050]  [<ffffffff813003b3>] ?=20
dev_watchdog+0x130/0x1d3
Mar 27 18:19:21 TM_01_C1 [1817899.773055]  [<ffffffff81032d1a>] ?=20
warn_slowpath_common+0x77/0xa3
Mar 27 18:19:21 TM_01_C1 [1817899.773059]  [<ffffffff81032da2>] ?=20
warn_slowpath_fmt+0x51/0x59
Mar 27 18:19:21 TM_01_C1 [1817899.773064]  [<ffffffff8102910c>] ?=20
enqueue_task_fair+0x3e/0xa1
Mar 27 18:19:21 TM_01_C1 [1817899.773068]  [<ffffffff8102f0c2>] ?=20
try_to_wake_up+0x368/0x379
Mar 27 18:19:21 TM_01_C1 [1817899.773072]  [<ffffffff812ee612>] ?=20
netdev_drivername+0x3b/0x40
Mar 27 18:19:21 TM_01_C1 [1817899.773075]  [<ffffffff813003b3>] ?=20
dev_watchdog+0x130/0x1d3
Mar 27 18:19:21 TM_01_C1 [1817899.773079]  [<ffffffff81026d60>] ?=20
__wake_up+0x30/0x44
Mar 27 18:19:21 TM_01_C1 [1817899.773082]  [<ffffffff81300283>] ?=20
dev_watchdog+0x0/0x1d3
Mar 27 18:19:21 TM_01_C1 [1817899.773087]  [<ffffffff8103f5d1>] ?=20
run_timer_softirq+0x200/0x29e
Mar 27 18:19:21 TM_01_C1 [1817899.773091]  [<ffffffff810386f6>] ?=20
__do_softirq+0xd7/0x195
Mar 27 18:19:21 TM_01_C1 [1817899.773099]  [<ffffffff810152b3>] ?=20
lapic_next_event+0x18/0x1d
Mar 27 18:19:21 TM_01_C1 [1817899.773104]  [<ffffffff81002e0c>] ?=20
call_softirq+0x1c/0x28
Mar 27 18:19:21 TM_01_C1 [1817899.773107]  [<ffffffff81004811>] ?=20
do_softirq+0x31/0x63
Mar 27 18:19:21 TM_01_C1 [1817899.773110]  [<ffffffff810384eb>] ?=20
irq_exit+0x36/0x78
Mar 27 18:19:21 TM_01_C1 [1817899.773113]  [<ffffffff81015d0b>] ?=20
smp_apic_timer_interrupt+0x87/0x95
Mar 27 18:19:21 TM_01_C1 [1817899.773117]  [<ffffffff810028d3>] ?=20
apic_timer_interrupt+0x13/0x20
Mar 27 18:19:21 TM_01_C1 [1817899.773119] <EOI>  [<ffffffff81008bdd>] ?=
=20
mwait_idle+0x9b/0xa0
Mar 27 18:19:21 TM_01_C1 [1817899.773126]  [<ffffffff81001385>] ?=20
cpu_idle+0x53/0x8b
Mar 27 18:19:21 TM_01_C1 [1817899.773128] ---[ end trace=20
4ac842842c6f54b3 ]---

ethtool -i eth0
driver: e1000e
version: 1.0.2-k2
firmware-version: 0.15-5
bus-info: 0000:04:00.0

NIC statistics:
      rx_packets: 8202754725
      tx_packets: 7398272195
      rx_bytes: 4373145698252
      tx_bytes: 5234354904619
      rx_broadcast: 59775
      tx_broadcast: 405
      rx_multicast: 0
      tx_multicast: 0
      rx_errors: 0
      tx_errors: 0
      tx_dropped: 0
      multicast: 0
      collisions: 0
      rx_length_errors: 0
      rx_over_errors: 0
      rx_crc_errors: 0
      rx_frame_errors: 0
      rx_no_buffer_count: 1185
      rx_missed_errors: 1466
      tx_aborted_errors: 0
      tx_carrier_errors: 0
      tx_fifo_errors: 0
      tx_heartbeat_errors: 0
      tx_window_errors: 0
      tx_abort_late_coll: 0
      tx_deferred_ok: 0
      tx_single_coll_ok: 0
      tx_multi_coll_ok: 0
      tx_timeout_count: 0
      tx_restart_queue: 12
      rx_long_length_errors: 0
      rx_short_length_errors: 0
      rx_align_errors: 0
      tx_tcp_seg_good: 0
      tx_tcp_seg_failed: 0
      rx_flow_control_xon: 0
      rx_flow_control_xoff: 0
      tx_flow_control_xon: 0
      tx_flow_control_xoff: 0
      rx_long_byte_count: 4373145698252
      rx_csum_offload_good: 8084424290
      rx_csum_offload_errors: 5690
      rx_header_split: 0
      alloc_rx_buff_failed: 0
      tx_smbus: 0
      rx_smbus: 48588
      dropped_smbus: 0
      rx_dma_failed: 0
      tx_dma_failed: 0


Wnen this occured traffic was about -  RX: 360Mbit/s  and  TX: 340Mbit =
-=20
for eth0 interface.



W dniu 2010-03-29 19:29, Pawe=B3 Staszewski pisze:
> lspci -vvv + ethtool -S in attached files.
>
> Network traffic when i get this info:
> eth1:    RX:    157.22 Mb/s    TX:    379.27 Mb/s
>
> ethtool -i eth1
> driver: e1000e
> version: 1.0.2-k2
> firmware-version: 0.5-7
> bus-info: 0000:05:00.0
> This is: Intel Corporation 82573L Gigabit Ethernet Controller
>
>
> But in this server i have another gigabit interface:
> Intel Corporation 82573E Gigabit Ethernet Controller
> this interface has two times more traffic than eth0 (82573L)
> ethtool -i eth0
> driver: e1000e
> version: 1.0.2-k2
> firmware-version: 0.15-5
> bus-info: 0000:04:00.0
>
> And also this server was working 4months without problems on 2.6.29.1=
=20
> kernel
>
> Drivers that I use for e1000e are from kernel (standard kernel=20
> build-in e1000e driver).
> I don't tried other drivers.
>
> This is production server so I can't make too much tests.
>
>
> W dniu 2010-03-29 18:41, Allan, Bruce W pisze:
>> [adding e1000-devel]
>>
>> Please provide more information:
>> * what NIC/LOM is this on (preferably send full output from lspci -v=
vv)
>> * what type of networking workload is running at the time the hang=20
>> occurred
>> * a dump of the NIC/LOM statistics might also help (ethtool -S eth1)
>>
>> Have you tried the latest standalone e1000e driver on e1000.sf.net? =
=20
>> Does it reproduce the issue?
>>
>> If we cannot reproduce the hang in-house, would you be able/willing=20
>> to run a debug driver to gather more information?
>>
>> Thanks,
>> Bruce.
>>
>> -----Original Message-----
>> From: netdev-owner@vger.kernel.org=20
>> [mailto:netdev-owner@vger.kernel.org] On Behalf Of Pawel Staszewski
>> Sent: Monday, March 29, 2010 8:34 AM
>> To: Linux Network Development list
>> Subject: eth1: Detected Hardware Unit Hang
>>
>> After update to kernel from 2.6.29.1 to 2.6.33.1 i have this info in=
=20
>> dmesg:
>>
>> 0000:05:00.0: eth1: Detected Hardware Unit Hang:
>>     TDH<1e>
>>     TDT<a>
>>     next_to_use<a>
>>     next_to_clean<1d>
>> buffer_info[next_to_clean]:
>>     time_stamp<33bae15>
>>     next_to_watch<20>
>>     jiffies<33bafaf>
>>     next_to_watch.status<0>
>> MAC Status<80080783>
>> PHY Status<796d>
>> PHY 1000BASE-T Status<3800>
>> PHY Extended Status<3000>
>> PCI Status<10>
>> 0000:05:00.0: eth1: Detected Hardware Unit Hang:
>>     TDH<1e>
>>     TDT<a>
>>     next_to_use<a>
>>     next_to_clean<1d>
>> buffer_info[next_to_clean]:
>>     time_stamp<33bae15>
>>     next_to_watch<20>
>>     jiffies<33bb1a3>
>>     next_to_watch.status<0>
>> MAC Status<80080783>
>> PHY Status<796d>
>> PHY 1000BASE-T Status<3800>
>> PHY Extended Status<3000>
>> PCI Status<10>
>> 0000:05:00.0: eth1: Detected Hardware Unit Hang:
>>     TDH<1e>
>>     TDT<a>
>>     next_to_use<a>
>>     next_to_clean<1d>
>> buffer_info[next_to_clean]:
>>     time_stamp<33bae15>
>>     next_to_watch<20>
>>     jiffies<33bb397>
>>     next_to_watch.status<0>
>> MAC Status<80080783>
>> PHY Status<796d>
>> PHY 1000BASE-T Status<3800>
>> PHY Extended Status<3000>
>> PCI Status<10>
>> ------------[ cut here ]------------
>> WARNING: at net/sched/sch_generic.c:255 dev_watchdog+0x118/0x19c()
>> Hardware name: X7DCT
>> NETDEV WATCHDOG: eth1 (e1000e): transmit queue 0 timed out
>> Modules linked in:
>> Pid: 0, comm: swapper Not tainted 2.6.33.1 #2
>> Call Trace:
>>    [<c1024e3d>] ? warn_slowpath_common+0x52/0x71
>>    [<c1024e49>] ? warn_slowpath_common+0x5e/0x71
>>    [<c1024e8e>] ? warn_slowpath_fmt+0x26/0x2a
>>    [<c1261f54>] ? dev_watchdog+0x118/0x19c
>>    [<c102135c>] ? __wake_up+0x29/0x39
>>    [<c10320c6>] ? insert_work+0x40/0x44
>>    [<c1261e3c>] ? dev_watchdog+0x0/0x19c
>>    [<c102cc15>] ? run_timer_softirq+0x11a/0x173
>>    [<c1028e5b>] ? __do_softirq+0x74/0xdf
>>    [<c1028ee9>] ? do_softirq+0x23/0x27
>>    [<c10290be>] ? irq_exit+0x26/0x58
>>    [<c10102d7>] ? smp_apic_timer_interrupt+0x6c/0x76
>>    [<c12c5f9a>] ? apic_timer_interrupt+0x2a/0x30
>>    [<c1007e06>] ? mwait_idle+0x49/0x4e
>>    [<c10017e8>] ? cpu_idle+0x41/0x5a
>> ---[ end trace bcca9926a046332c ]---
>>
>>
>> With kernel 2.6.29.1 all was ok.
>> --=20
>> To unsubscribe from this list: send the line "unsubscribe netdev" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>
>>
>

