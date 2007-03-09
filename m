From: Simon Arlott <simon@fire.lp0.eu>
Subject: netconsole system freeze when cable unplugged
Date: Fri, 09 Mar 2007 19:35:25 +0000
Message-ID: <45F1B6FD.1060902@simon.arlott.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from proxima.lp0.eu ([85.158.45.36]:57708 "EHLO proxima.lp0.eu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752760AbXCITfb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 9 Mar 2007 14:35:31 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

When I unplug the cable the system just stops responding to anything, 
at all. No message is printed to the console when the cable is plugged 
back in.

[    0.000000] Linux version 2.6.21-rc3 (byte@redrum) (gcc version 3.4.6 (Gentoo 3.4.6-r1, ssp-3.4.5-1.0, pie-8.7.9)) #3 SMP Fri Mar 9 18:42:22 GMT 2007
[    0.000000] BIOS-provided physical RAM map:
[    0.000000] sanitize start
[    0.000000] sanitize bail 0
[    0.000000]  BIOS-e801: 0000000000000000 - 000000000009f000 (usable)
[    0.000000]  BIOS-e801: 0000000000100000 - 000000000c000000 (usable)
[    0.000000] 192MB LOWMEM available.
[    0.000000] found SMP MP-table at 000fea90
[    0.000000] Zone PFN ranges:
[    0.000000]   DMA             0 ->     4096
[    0.000000]   Normal       4096 ->    49152
[    0.000000] early_node_map[1] active PFN ranges
[    0.000000]     0:        0 ->    49152
[    0.000000] DMI not present or invalid.
[    0.000000] Intel MultiProcessor Specification v1.4
[    0.000000]     Virtual Wire compatibility mode.
[    0.000000] OEM ID: COMPAQ   Product ID: Workstation  APIC at: 0xFEE00000
[    0.000000] Processor #1 6:1 APIC version 16
[    0.000000] Processor #0 6:1 APIC version 16
[    0.000000] I/O APIC #8 Version 17 at 0xFEC00000.
[    0.000000] Enabling APIC mode:  Flat.  Using 1 I/O APICs
[    0.000000] Processors: 2
[    0.000000] Allocating PCI resources starting at 10000000 (gap: 0c000000:f4000000)
[    0.000000] Built 1 zonelists.  Total pages: 48768
[    0.000000] Kernel command line: netconsole=9@192.168.7.200/eth0,1649@192.168.7.255/ console=ttyS0,115200 ip=dhcp root=/dev/nfs init=/bin/bash panic=10
[    0.000000] Initializing CPU#0
[    0.000000] PID hash table entries: 1024 (order: 10, 4096 bytes)
[    0.000000] Detected 199.444 MHz processor.
[  485.111206] Console: colour dummy device 80x25
[  486.218671] Dentry cache hash table entries: 32768 (order: 5, 131072 bytes)
[  486.227388] Inode-cache hash table entries: 16384 (order: 4, 65536 bytes)
[  486.234789] Pentium Pro with Errata#50 detected. Taking evasive action.
[  486.346878] Memory: 189764k/196608k available (1268k kernel code, 6452k reserved, 492k data, 184k init, 0k highmem)
[  486.357430] virtual kernel memory layout:
[  486.357444]     fixmap  : 0xfffbc000 - 0xfffff000   ( 268 kB)
[  486.357461]     vmalloc : 0xcc800000 - 0xfffba000   ( 823 MB)
[  486.357478]     lowmem  : 0xc0000000 - 0xcc000000   ( 192 MB)
[  486.357494]       .init : 0xc02bf000 - 0xc02ed000   ( 184 kB)
[  486.357510]       .data : 0xc023d32b - 0xc02b85d0   ( 492 kB)
[  486.357527]       .text : 0xc0100000 - 0xc023d32b   (1268 kB)
[  486.396031] Checking if this processor honours the WP bit even in supervisor mode... Ok.
[  486.562667] Calibrating delay using timer specific routine.. 400.92 BogoMIPS (lpj=2004624)
[  486.575064] Mount-cache hash table entries: 512
[  486.587330] CPU: L1 I cache: 8K, L1 D cache: 8K
[  486.591916] CPU: L2 cache: 256K
[  486.595475] Checking 'hlt' instruction... OK.
[  486.633415] Freeing SMP alternatives: 9k freed
[  486.638843] CPU0: Intel Pentium Pro stepping 07
[  486.644597] lockdep: not fixing up alternatives.
[  486.649256] Booting processor 1/0 eip 2000
[  486.664153] Initializing CPU#1
[  486.812607] Calibrating delay using timer specific routine.. 398.91 BogoMIPS (lpj=1994559)
[  486.812755] CPU: L1 I cache: 8K, L1 D cache: 8K
[  486.812781] CPU: L2 cache: 256K
[  486.813992] CPU1: Intel Pentium Pro stepping 07
[  486.837731] Total of 2 processors activated (799.83 BogoMIPS).
[  486.844201] ExtINT not setup in hardware but reported by MP table
[  486.851035] ENABLING IO-APIC IRQs
[  486.855772] ..TIMER: vector=0x31 apic1=0 pin1=2 apic2=0 pin2=0
[  487.204372] checking TSC synchronization [CPU#0 -> CPU#1]: passed.
[  487.230906] Brought up 2 CPUs
[  487.888084] migration_cost=6769
[  487.904092] NET: Registered protocol family 16
[  487.927495] PCI: PCI BIOS revision 2.10 entry at 0xe07c4, last bus=1
[  487.933936] PCI: Using configuration type 1
[  487.938152] Setting up standard PCI resources
[  487.951810] PCI: Probing PCI hardware
[  487.959923] 0000:00:14.1: trying to change BAR0 from 0000 to 01F0
[  487.966107] 0000:00:14.1: trying to change BAR1 from 0000 to 03F4
[  487.972246] 0000:00:14.1: trying to change BAR2 from 0000 to 0170
[  487.978418] 0000:00:14.1: trying to change BAR3 from 0000 to 0374
[  487.993123] PCI->APIC IRQ transform: 0000:00:08.0[A] -> IRQ 19
[  487.999018] PCI->APIC IRQ transform: 0000:00:0b.0[A] -> IRQ 16
[  488.004987] PCI->APIC IRQ transform: 0000:01:0b.0[A] -> IRQ 20
[  488.010870] PCI->APIC IRQ transform: 0000:01:0c.0[A] -> IRQ 21
[  488.058792] PCI: Bridge: 0000:00:06.0
[  488.062512]   IO window: 1000-1fff
[  488.065964] Time: tsc clocksource has been installed.
[  488.071119]   MEM window: 50000000-501fffff
[  488.075398]   PREFETCH window: 10000000-100fffff
[  488.081935] NET: Registered protocol family 2
[  488.173953] IP route cache hash table entries: 2048 (order: 1, 8192 bytes)
[  488.184036] TCP established hash table entries: 8192 (order: 6, 294912 bytes)
[  488.204285] TCP bind hash table entries: 8192 (order: 6, 262144 bytes)
[  488.223278] TCP: Hash tables configured (established 8192 bind 8192)
[  488.229974] TCP reno registered
[  488.285511] Limiting direct PCI/PCI transfers.
[  488.334179] Real Time Clock Driver v1.12ac
[  488.338328] Hangcheck: starting hangcheck timer 0.9.0 (tick is 180 seconds, margin is 60 seconds).
[  488.347357] Hangcheck: Using get_cycles().
[  488.351515] Serial: 8250/16550 driver $Revision: 1.90 $ 4 ports, IRQ sharing disabled
[  488.360916] serial8250: ttyS0 at I/O 0x3f8 (irq = 4) is a 16550A
[  488.367954] serial8250: ttyS1 at I/O 0x2f8 (irq = 3) is a 16550A
[  488.381717] 8139too Fast Ethernet driver 0.9.28
[  488.389601] eth0: RealTek RTL8139 at 0x2400, 00:02:44:47:d3:ee, IRQ 19
[  488.396487] netconsole: device eth0 not up yet, forcing it
[  488.402923] eth0: link up, 100Mbps, full-duplex, lpa 0x45E1
[  488.423119] netconsole: carrier detect appears untrustworthy, waiting 100 ms
[  489.684118] netconsole: network logging started
[  489.688832] TCP cubic registered
[  489.694506] NET: Registered protocol family 10
[  489.711251] Starting balanced_irq
[  489.715459] Using IPI Shortcut mode
[  491.242277] Sending DHCP requests ., OK
[  491.292256] IP-Config: Got DHCP answer from 192.168.7.4, my address is 192.168.7.200
[  491.302672] IP-Config: Complete:
[  491.305876]       device=eth0, addr=192.168.7.200, mask=255.255.255.0, gw=192.168.7.4,
[  491.314553]      host=Compaq_PW5000, domain=lan, nis-domain=(none),
[  491.321130]      bootserver=192.168.7.4, rootserver=192.168.7.8, rootpath=/
[  491.331337] Looking up port of RPC 100003/2 on 192.168.7.8
[  491.344971] Looking up port of RPC 100005/1 on 192.168.7.8
[  491.444880] VFS: Mounted root (nfs filesystem) readonly.
[  491.453750] Freeing unused kernel memory: 184k freed
[  491.459420] Write protecting the kernel read-only data: 346k
[  565.518226] eth0: link down

-- 
Simon Arlott
