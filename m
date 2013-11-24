From: Atif Faheem <afaheem@btisystems.com>
Subject: BCM5720 'no firmware running'
Date: Sun, 24 Nov 2013 04:39:26 -0500
Message-ID: <4CB236AC-8330-4270-A218-A5697E965203@btisystems.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=Windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx4.gridway.net ([72.1.205.246]:54763 "EHLO mx4.gridway.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751120Ab3KXJj2 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 24 Nov 2013 04:39:28 -0500
Received: from mail.btisystems.com (mail.btisystems.com [72.1.205.190])
	by mx4.gridway.net (8.14.3/8.14.3/Debian-9.4) with ESMTP id rAO9dRhM000409
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Sun, 24 Nov 2013 04:39:27 -0500
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi. I am observing a strange problem with the 5720.  Sometimes during t=
he boot up of the 5720, after both interfaces have been added to a bond=
, tg3 throws the error =91no firmware running=92 and all registers are =
-1. This happens on both interfaces.  A power cycle is needed in order =
to recover the device. We are using kernel 3.4.34 - I haven=92t tried t=
o build the driver from the latest kernel (I will have to back-port). A=
ny input will be great.

Thanks - Atif

---

Offload parameters for eth0:
rx-checksumming: on
tx-checksumming: on
scatter-gather: on
tcp-segmentation-offload: on
udp-fragmentation-offload: off
generic-segmentation-offload: on
generic-receive-offload: on
large-receive-offload: off
rx-vlan-offload: on
tx-vlan-offload: on
ntuple-filters: off
receive-hashing: off

----

2013-11-20T02:06:02.659773-05:00 pld0112 kernel: bonding: bond0: enslav=
ing eth0 as an active interface with a down link.
2013-11-20T02:06:02.659806-05:00 pld0112 kernel: bonding: bond0: enslav=
ing eth1 as an active interface with a down link.
2013-11-20T02:06:02.659809-05:00 pld0112 kernel: tg3 0000:03:00.0: eth0=
: Link is up at 1000 Mbps, full duplex
2013-11-20T02:06:02.659812-05:00 pld0112 kernel: tg3 0000:03:00.0: eth0=
: Flow control is off for TX and off for RX
2013-11-20T02:06:02.659815-05:00 pld0112 kernel: tg3 0000:03:00.0: eth0=
: EEE is disabled
2013-11-20T02:06:02.659818-05:00 pld0112 kernel: bonding: bond0: link s=
tatus definitely up for interface eth0, 1000 Mbps full duplex.
2013-11-20T02:06:02.659821-05:00 pld0112 kernel: ADDRCONF(NETDEV_CHANGE=
): bond0: link becomes ready
2013-11-20T02:06:02.659832-05:00 pld0112 kernel: tg3 0000:03:00.1: eth1=
: Link is up at 1000 Mbps, full duplex
2013-11-20T02:06:02.659837-05:00 pld0112 kernel: tg3 0000:03:00.1: eth1=
: Flow control is off for TX and off for RX
2013-11-20T02:06:02.659840-05:00 pld0112 kernel: tg3 0000:03:00.1: eth1=
: EEE is disabled
2013-11-20T02:06:02.659843-05:00 pld0112 kernel: bonding: bond0: link s=
tatus definitely up for interface eth1, 1000 Mbps full duplex.
2013-11-20T02:06:22.465353-05:00 pld0112 kernel: nfs: server 100.100.0.=
6 not responding, still trying
2013-11-20T02:06:25.937609-05:00 pld0112 kernel: ------------[ cut here=
 ]------------
2013-11-20T02:06:25.937642-05:00 pld0112 kernel: WARNING: at /home/jenk=
ins/jobs/r102-os/workspace/opt/os/wrlinux/builds/atom64/bitbake_build/t=
mp/work/intel_atom_64-wrs-linux/linux-windriver-3.4-r0/linux/net/sched/=
sch_generic.c:256 dev_watchdog+0x277/0x280()
2013-11-20T02:06:25.937649-05:00 pld0112 kernel: Hardware name: To be f=
illed by O.E.M.
2013-11-20T02:06:25.937653-05:00 pld0112 kernel: NETDEV WATCHDOG: eth1 =
(tg3): transmit queue 1 timed out
2013-11-20T02:06:25.937657-05:00 pld0112 kernel: Modules linked in: fir=
mware_class hwmon libphy tg3 x_tables ip_tables iptable_filter exportfs=
 coretemp minix ipmi_devintf bonding nfsd ipmi_msghandler ipmi_si [last=
 unloaded: bonding]
2013-11-20T02:06:25.937662-05:00 pld0112 kernel: Pid: 0, comm: swapper/=
0 Not tainted 3.4.34-WR5.0.1.3_standard #1
2013-11-20T02:06:25.937668-05:00 pld0112 kernel: Call Trace:
2013-11-20T02:06:25.937728-05:00 pld0112 kernel: <IRQ>  [<ffffffff81030=
c84>] warn_slowpath_common+0x84/0xc0
2013-11-20T02:06:25.937734-05:00 pld0112 kernel: [<ffffffff81030d77>] w=
arn_slowpath_fmt+0x47/0x50
2013-11-20T02:06:25.937739-05:00 pld0112 kernel: [<ffffffff816799f7>] d=
ev_watchdog+0x277/0x280
2013-11-20T02:06:25.937744-05:00 pld0112 kernel: [<ffffffff81040784>] r=
un_timer_softirq+0x134/0x420
2013-11-20T02:06:25.937747-05:00 pld0112 kernel: [<ffffffff8134f5ee>] ?=
 timerqueue_add+0x6e/0xc0
2013-11-20T02:06:25.937751-05:00 pld0112 kernel: [<ffffffff81679780>] ?=
 qdisc_reset+0x50/0x50
2013-11-20T02:06:25.937756-05:00 pld0112 kernel: [<ffffffff8103811d>] _=
_do_softirq+0xbd/0x280
2013-11-20T02:06:25.937760-05:00 pld0112 kernel: [<ffffffff81079375>] ?=
 clockevents_program_event+0x75/0xf0
2013-11-20T02:06:25.937765-05:00 pld0112 kernel: [<ffffffff8107a7b4>] ?=
 tick_program_event+0x24/0x30
2013-11-20T02:06:25.937769-05:00 pld0112 kernel: [<ffffffff81777b8c>] c=
all_softirq+0x1c/0x30
2013-11-20T02:06:25.937773-05:00 pld0112 kernel: [<ffffffff810037b5>] d=
o_softirq+0x55/0x90
2013-11-20T02:06:25.937778-05:00 pld0112 kernel: [<ffffffff810385ee>] i=
rq_exit+0x8e/0xb0
2013-11-20T02:06:25.937783-05:00 pld0112 kernel: [<ffffffff817781e9>] s=
mp_apic_timer_interrupt+0x99/0x1cd
2013-11-20T02:06:25.937788-05:00 pld0112 kernel: [<ffffffff817773c7>] a=
pic_timer_interrupt+0x67/0x70
2013-11-20T02:06:25.937791-05:00 pld0112 kernel: <EOI>  [<ffffffff813c2=
689>] ? acpi_idle_enter_bm+0x240/0x281
2013-11-20T02:06:25.937796-05:00 pld0112 kernel: [<ffffffff813c2684>] ?=
 acpi_idle_enter_bm+0x23b/0x281
2013-11-20T02:06:25.937800-05:00 pld0112 kernel: [<ffffffff815cc58f>] ?=
 menu_select+0xff/0x3c0
2013-11-20T02:06:25.937804-05:00 pld0112 kernel: [<ffffffff815ca8d8>] c=
puidle_enter+0x18/0x20
2013-11-20T02:06:25.937808-05:00 pld0112 kernel: [<ffffffff815caf59>] c=
puidle_idle_call+0xc9/0x3b0
2013-11-20T02:06:25.937813-05:00 pld0112 kernel: [<ffffffff8100b59f>] c=
pu_idle+0x7f/0xd0
2013-11-20T02:06:25.937817-05:00 pld0112 kernel: [<ffffffff8174b3a7>] r=
est_init+0x7b/0x84
2013-11-20T02:06:25.937821-05:00 pld0112 kernel: [<ffffffff81cd3b76>] s=
tart_kernel+0x35b/0x369
2013-11-20T02:06:25.937826-05:00 pld0112 kernel: [<ffffffff81cd3616>] ?=
 repair_env_string+0x5a/0x5a
2013-11-20T02:06:25.937830-05:00 pld0112 kernel: [<ffffffff81cd3321>] x=
86_64_start_reservations+0x131/0x135
2013-11-20T02:06:25.937834-05:00 pld0112 kernel: [<ffffffff81cd3416>] x=
86_64_start_kernel+0xf1/0xf9
2013-11-20T02:06:25.937839-05:00 pld0112 kernel: ---[ end trace e28305a=
78a341f61 ]---
2013-11-20T02:06:25.937843-05:00 pld0112 kernel: tg3 0000:03:00.1: eth1=
: transmit timed out, resetting
2013-11-20T02:06:25.960660-05:00 pld0112 kernel: tg3 0000:03:00.1: eth1=
: 0x00000000: 0xffffffff, 0xffffffff, 0xffffffff, 0xffffffff
2013-11-20T02:06:25.960689-05:00 pld0112 kernel: tg3 0000:03:00.1: eth1=
: 0x00000010: 0xffffffff, 0xffffffff, 0xffffffff, 0xffffffff
2013-11-20T02:06:25.960698-05:00 pld0112 kernel: tg3 0000:03:00.1: eth1=
: 0x00000020: 0xffffffff, 0xffffffff, 0xffffffff, 0xffffffff
2013-11-20T02:06:25.960703-05:00 pld0112 kernel: tg3 0000:03:00.1: eth1=
: 0x00000030: 0xffffffff, 0xffffffff, 0xffffffff, 0xffffffff
2013-11-20T02:06:25.960707-05:00 pld0112 kernel: tg3 0000:03:00.1: eth1=
: 0x00000040: 0xffffffff, 0xffffffff, 0xffffffff, 0xffffffff
2013-11-20T02:06:25.960712-05:00 pld0112 kernel: tg3 0000:03:00.1: eth1=
: 0x00000050: 0xffffffff, 0xffffffff, 0xffffffff, 0xffffffff
=85.
=85.
2013-11-20T02:06:26.081578-05:00 pld0112 kernel: tg3 0000:03:00.1: eth1=
: 0: Host status block [00000005:00000003:(0000:0000:0000):(0000:0000)]
2013-11-20T02:06:26.081583-05:00 pld0112 kernel: tg3 0000:03:00.1: eth1=
: 0: NAPI info [00000003:00000003:(0000:0000:01ff):0000:(0402:0000:0000=
:0000)]
2013-11-20T02:06:26.081588-05:00 pld0112 kernel: tg3 0000:03:00.1: eth1=
: 1: Host status block [00000001:00000097:(0000:0000:0000):(01f9:0007)]
2013-11-20T02:06:26.081606-05:00 pld0112 kernel: tg3 0000:03:00.1: eth1=
: 1: NAPI info [00000097:00000097:(0007:0007:01ff):01f9:(01f9:01f9:0000=
:0000)]
2013-11-20T02:06:26.081613-05:00 pld0112 kernel: tg3 0000:03:00.1: eth1=
: 2: Host status block [00000001:000000e2:(0028:0000:0000):(0000:00f5)]
2013-11-20T02:06:26.081618-05:00 pld0112 kernel: tg3 0000:03:00.1: eth1=
: 2: NAPI info [000000e2:000000e2:(0101:00f5:01ff):0028:(0028:0028:0000=
:0000)]
2013-11-20T02:06:26.081623-05:00 pld0112 kernel: tg3 0000:03:00.1: eth1=
: 3: Host status block [00000001:000000f0:(0000:0000:0000):(0000:0066)]
2013-11-20T02:06:26.081627-05:00 pld0112 kernel: tg3 0000:03:00.1: eth1=
: 3: NAPI info [000000f0:000000f0:(0069:0066:01ff):08b6:(00b6:00b6:0000=
:0000)]
2013-11-20T02:06:26.081632-05:00 pld0112 kernel: tg3 0000:03:00.1: eth1=
: 4: Host status block [00000001:0000004b:(0000:0000:0063):(0000:0002)]
2013-11-20T02:06:26.081638-05:00 pld0112 kernel: tg3 0000:03:00.1: eth1=
: 4: NAPI info [0000004b:0000004b:(0002:0002:01ff):0063:(0063:0063:0000=
:0000)]
2013-11-20T02:06:26.095286-05:00 pld0112 kernel: tg3 0000:03:00.1: tg3_=
stop_block timed out, ofs=3D2c00 enable_bit=3D2
2013-11-20T02:06:26.197287-05:00 pld0112 kernel: tg3 0000:03:00.1: tg3_=
stop_block timed out, ofs=3D2000 enable_bit=3D2
2013-11-20T02:06:26.300286-05:00 pld0112 kernel: tg3 0000:03:00.1: tg3_=
stop_block timed out, ofs=3D2400 enable_bit=3D2
2013-11-20T02:06:26.402277-05:00 pld0112 kernel: tg3 0000:03:00.1: tg3_=
stop_block timed out, ofs=3D2800 enable_bit=3D2
2013-11-20T02:06:26.504264-05:00 pld0112 kernel: tg3 0000:03:00.1: tg3_=
stop_block timed out, ofs=3D3000 enable_bit=3D2
2013-11-20T02:06:26.606267-05:00 pld0112 kernel: tg3 0000:03:00.1: tg3_=
stop_block timed out, ofs=3D1400 enable_bit=3D2
2013-11-20T02:06:26.708264-05:00 pld0112 kernel: tg3 0000:03:00.1: tg3_=
stop_block timed out, ofs=3D1800 enable_bit=3D2
2013-11-20T02:06:26.810264-05:00 pld0112 kernel: tg3 0000:03:00.1: tg3_=
stop_block timed out, ofs=3Dc00 enable_bit=3D2
2013-11-20T02:06:26.912259-05:00 pld0112 kernel: tg3 0000:03:00.1: tg3_=
stop_block timed out, ofs=3D4800 enable_bit=3D2
2013-11-20T02:06:27.014273-05:00 pld0112 kernel: tg3 0000:03:00.1: tg3_=
stop_block timed out, ofs=3D1000 enable_bit=3D2
2013-11-20T02:06:27.116264-05:00 pld0112 kernel: tg3 0000:03:00.1: tg3_=
stop_block timed out, ofs=3D1c00 enable_bit=3D2
2013-11-20T02:06:27.218282-05:00 pld0112 kernel: tg3 0000:03:00.1: tg3_=
abort_hw timed out, TX_MODE_ENABLE will not clear MAC_TX_MODE=3Dfffffff=
f
2013-11-20T02:06:27.320264-05:00 pld0112 kernel: tg3 0000:03:00.1: tg3_=
stop_block timed out, ofs=3D3c00 enable_bit=3D2
2013-11-20T02:06:27.422240-05:00 pld0112 kernel: tg3 0000:03:00.1: tg3_=
stop_block timed out, ofs=3D4c00 enable_bit=3D2
2013-11-20T02:06:28.964261-05:00 pld0112 kernel: tg3 0000:03:00.1: eth1=
: No firmware running
2013-11-20T02:06:30.188256-05:00 pld0112 kernel: tg3 0000:03:00.1: tg3_=
abort_hw timed out, TX_MODE_ENABLE will not clear MAC_TX_MODE=3Dfffffff=
f
2013-11-20T02:06:44.447246-05:00 pld0112 kernel: tg3 0000:03:00.1: eth1=
: Link is down
2013-11-20T02:06:44.458245-05:00 pld0112 kernel: bonding: bond0: link s=
tatus definitely down for interface eth1, disabling it
2013-11-20T02:06:44.507338-05:00 pld0112 kernel: tg3 0000:03:00.0: eth0=
: transmit timed out, resetting
2013-11-20T02:06:44.507375-05:00 pld0112 kernel: nfs: server 100.100.0.=
6 not responding, still trying