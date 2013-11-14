From: Milan Kocian <milon@wq.cz>
Subject: NETDEV WATCHDOG: eth0 (e1000e): transmit queue 0 timed out
Date: Thu, 14 Nov 2013 11:18:07 +0100
Message-ID: <20131114101806.GJ5513@ntm.wq.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jeffrey.t.kirsher@intel.com, jesse.brandeburg@intel.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from srw1.wq.cz ([80.92.240.241]:35300 "EHLO srw1.wq.cz"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752323Ab3KNLBN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 Nov 2013 06:01:13 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

hi,

its probably for intel's guys ... 

I see 'Detected Hardware Unit Hang' in log repeatedly until
transmit hangs forever (until reboot:-)). I tried old fixeep
script which I got from Jesse Brandeburg some years ago but
no success. Any ideas ? Many thanks for any answer.

kernel 3.10.18

Outputs & logs:

ethtool -i eth0
driver: e1000e
version: 2.3.2-k
firmware-version: 0.13-4
bus-info: 0000:00:19.0
supports-statistics: yes
supports-test: yes
supports-eeprom-access: yes
supports-register-dump: yes
supports-priv-flags: no


00:19.0 Ethernet controller: Intel Corporation 82579LM Gigabit Network Connection (rev 04)
	Subsystem: Intel Corporation Device 2036
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx+
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0
	Interrupt: pin A routed to IRQ 42
	Region 0: Memory at f7d00000 (32-bit, non-prefetchable) [size=128K]
	Region 1: Memory at f7d35000 (32-bit, non-prefetchable) [size=4K]
	Region 2: I/O ports at f080 [size=32]
	Capabilities: [c8] Power Management version 2
		Flags: PMEClk- DSI+ D1- D2- AuxCurrent=0mA PME(D0+,D1-,D2-,D3hot+,D3cold+)
		Status: D0 NoSoftRst- PME-Enable- DSel=0 DScale=1 PME-
	Capabilities: [d0] MSI: Enable+ Count=1/1 Maskable- 64bit+
		Address: 00000000fee0100c  Data: 4172
	Capabilities: [e0] PCI Advanced Features
		AFCap: TP+ FLR+
		AFCtrl: FLR-
		AFStatus: TP-
	Kernel driver in use: e1000e



e1000e 0000:00:19.0 eth0: Detected Hardware Unit Hang:
  TDH                  <a9>
  TDT                  <7>
  next_to_use          <7>
  next_to_clean        <a6>
buffer_info[next_to_clean]:
  time_stamp           <4af1c>
  next_to_watch        <a9>
  jiffies              <4b12e>
  next_to_watch.status <0>
MAC Status             <80083>
PHY Status             <796d>
PHY 1000BASE-T Status  <3c00>
PHY Extended Status    <3000>
PCI Status             <10>
e1000e 0000:00:19.0 eth0: Detected Hardware Unit Hang:
  TDH                  <a9>
  TDT                  <7>
  next_to_use          <7>
  next_to_clean        <a6>
buffer_info[next_to_clean]:
  time_stamp           <4af1c>
  next_to_watch        <a9>
  jiffies              <4b386>
  next_to_watch.status <0>
MAC Status             <80083>
PHY Status             <796d>
PHY 1000BASE-T Status  <3c00>
PHY Extended Status    <3000>
PCI Status             <10>
e1000e 0000:00:19.0 eth0: Detected Hardware Unit Hang:
  TDH                  <a9>
  TDT                  <7>
  next_to_use          <7>
  next_to_clean        <a6>
buffer_info[next_to_clean]:
  time_stamp           <4af1c>
  next_to_watch        <a9>
  jiffies              <4b5de>
  next_to_watch.status <0>
MAC Status             <80083>
PHY Status             <796d>
PHY 1000BASE-T Status  <3c00>
PHY Extended Status    <3000>
PCI Status             <10>
e1000e 0000:00:19.0 eth0: Detected Hardware Unit Hang:
  TDH                  <a9>
  TDT                  <7>
  next_to_use          <7>
  next_to_clean        <a6>
buffer_info[next_to_clean]:
  time_stamp           <4af1c>
  next_to_watch        <a9>
  jiffies              <4b836>
  next_to_watch.status <0>
MAC Status             <80083>
PHY Status             <796d>
PHY 1000BASE-T Status  <3c00>
PHY Extended Status    <3000>
PCI Status             <10>
------------[ cut here ]------------
WARNING: at net/sched/sch_generic.c:255 dev_watchdog+0x1cc/0x1e0()
NETDEV WATCHDOG: eth0 (e1000e): transmit queue 0 timed out
Modules linked in: tun ipv6 xt_nat xt_conntrack xt_tcpudp xt_LOG xt_limit iptable_nat nf_nat_ipv4 nf_nat iptable_filter ip_tables x_tables nf_conntrack_ipv4 nf_defrag_ipv4 nf_conntrack ehci_pci ehci_hcd e1000e coretemp xhci_hcd hwmon usbcore crc32_pclmul iTCO_wdt iTCO_vendor_support lpc_ich crc32c_intel mfd_core ptp pps_core usb_common i2c_i801 i2c_core microcode
CPU: 0 PID: 0 Comm: swapper/0 Not tainted 3.10.18-core2-router18 #3
Hardware name:                  /DQ77KB, BIOS KBQ7710H.86A.0049.2013.0130.1732 01/30/2013
 c12ad3ea c102836e c135ece0 f540bf58 000000ff c123b38c c123b38c 00000000
 f4d98000 000005dc 0004b964 c10283c3 00000009 f540bf40 c135ece0 f540bf58
 c123b38c c135bdec 000000ff c135ece0 f4d98000 f8184740 00000000 00000100
Call Trace:
 [<c12ad3ea>] ? dump_stack+0xa/0x13
 [<c102836e>] ? warn_slowpath_common+0x5e/0x80
 [<c123b38c>] ? dev_watchdog+0x1cc/0x1e0
 [<c123b38c>] ? dev_watchdog+0x1cc/0x1e0
 [<c10283c3>] ? warn_slowpath_fmt+0x33/0x40
 [<c123b38c>] ? dev_watchdog+0x1cc/0x1e0
 [<c123b1c0>] ? dev_graft_qdisc+0x60/0x60
 [<c1033636>] ? call_timer_fn.isra.35+0x16/0x70
 [<c1045168>] ? hrtimer_run_pending+0x28/0xe0
 [<c10337a9>] ? run_timer_softirq+0x119/0x1a0
 [<c102e9e3>] ? __do_softirq+0xa3/0x160
 [<c102e940>] ? remote_softirq_receive+0x40/0x40
 <IRQ>  [<c102eb85>] ? irq_exit+0x45/0x50
 [<c101a912>] ? smp_apic_timer_interrupt+0x52/0x90
 [<c12b02a5>] ? apic_timer_interrupt+0x2d/0x34
 [<c1008002>] ? default_idle+0x2/0x10
 [<c10085a6>] ? arch_cpu_idle+0x6/0x10
 [<c1052767>] ? cpu_startup_entry+0xa7/0xf0
 [<c13be926>] ? start_kernel+0x285/0x28a
 [<c13be4ed>] ? repair_env_string+0x4d/0x4d
---[ end trace a052b68b72311803 ]---
e1000e 0000:00:19.0 eth0: Reset adapter unexpectedly
e1000e: eth0 NIC Link is Up 1000 Mbps Full Duplex, Flow Control: Rx/Tx
e1000e 0000:00:19.0 eth0: Detected Hardware Unit Hang:
  TDH                  <92>
  TDT                  <b6>
  next_to_use          <b6>
  next_to_clean        <92>
buffer_info[next_to_clean]:
  time_stamp           <526ff>
  next_to_watch        <92>
  jiffies              <529e2>
  next_to_watch.status <0>
MAC Status             <80083>
PHY Status             <796d>
PHY 1000BASE-T Status  <3c00>
PHY Extended Status    <3000>
PCI Status             <10>
e1000e 0000:00:19.0 eth0: Detected Hardware Unit Hang:
  TDH                  <92>
  TDT                  <b6>
  next_to_use          <b6>
  next_to_clean        <92>
buffer_info[next_to_clean]:
  time_stamp           <526ff>
  next_to_watch        <92>
  jiffies              <52c3a>
  next_to_watch.status <0>
MAC Status             <80083>
PHY Status             <796d>
PHY 1000BASE-T Status  <3c00>
PHY Extended Status    <3000>
PCI Status             <10>
e1000e 0000:00:19.0 eth0: Reset adapter unexpectedly
e1000e: eth0 NIC Link is Up 1000 Mbps Full Duplex, Flow Control: Rx/Tx


-- 
Milan Kocian
