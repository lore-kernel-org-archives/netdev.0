From: Andrew Morton <akpm@osdl.org>
Subject: Fw: [Bugme-new] [Bug 4249] New: KERNEL: assertion
 (!atomic_read(&sk->sk_rmem_alloc)) failed at net/netlink/af_netlink.c (122)
Date: Thu, 24 Feb 2005 16:38:56 -0800
Message-ID: <20050224163856.21b82abf.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: olel@ans.pl
To: netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



Begin forwarded message:

Date: Thu, 24 Feb 2005 16:15:32 -0800
From: bugme-daemon@osdl.org
To: bugme-new@lists.osdl.org
Subject: [Bugme-new] [Bug 4249] New: KERNEL: assertion (!atomic_read(&sk->sk_rmem_alloc)) failed at net/netlink/af_netlink.c (122)


http://bugme.osdl.org/show_bug.cgi?id=4249

           Summary: KERNEL: assertion (!atomic_read(&sk->sk_rmem_alloc))
                    failed at net/netlink/af_netlink.c (122)
    Kernel Version: 2.6.11-rc4
            Status: NEW
          Severity: high
             Owner: acme@conectiva.com.br
         Submitter: olel@ans.pl


Distribution: Slackware 10
Hardware Environment:
# cat /proc/cpuinfo
processor       : 0
vendor_id       : GenuineIntel
cpu family      : 15
model           : 3
model name      : Intel(R) Pentium(R) 4 CPU 2.80GHz
stepping        : 4
cpu MHz         : 2793.832
cache size      : 1024 KB
physical id     : 0
siblings        : 2
fdiv_bug        : no
hlt_bug         : no
f00f_bug        : no
coma_bug        : no
fpu             : yes
fpu_exception   : yes
cpuid level     : 5
wp              : yes
flags           : fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca cmov
pat pse36 clflush dts acpi mmx fxsr sse sse2 ss ht tm pbe pni monitor ds_cpl cid
xtpr
bogomips        : 5505.02

processor       : 1
vendor_id       : GenuineIntel
cpu family      : 15
model           : 3
model name      : Intel(R) Pentium(R) 4 CPU 2.80GHz
stepping        : 4
cpu MHz         : 2793.832
cache size      : 1024 KB
physical id     : 0
siblings        : 2
fdiv_bug        : no
hlt_bug         : no
f00f_bug        : no
coma_bug        : no
fpu             : yes
fpu_exception   : yes
cpuid level     : 5
wp              : yes
flags           : fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca cmov
pat pse36 clflush dts acpi mmx fxsr sse sse2 ss ht tm pbe pni monitor ds_cpl cid
xtpr
bogomips        : 5570.56

# lspci
00:00.0 Host bridge: Intel Corp. E7220/E7221 Memory Controller Hub (rev 05)
00:01.0 PCI bridge: Intel Corp. E7220/E7221 PCI Express Root Port (rev 05)
00:02.0 VGA compatible controller: Intel Corp. E7221 Integrated Graphics
Controller (rev 05)
00:1c.0 PCI bridge: Intel Corp. 82801FB/FBM/FR/FW/FRW (ICH6 Family) PCI Express
Port 1 (rev 03)
00:1c.2 PCI bridge: Intel Corp. 82801FB/FBM/FR/FW/FRW (ICH6 Family) PCI Express
Port 3 (rev 03)
00:1c.3 PCI bridge: Intel Corp. 82801FB/FBM/FR/FW/FRW (ICH6 Family) PCI Express
Port 4 (rev 03)
00:1d.0 USB Controller: Intel Corp. 82801FB/FBM/FR/FW/FRW (ICH6 Family) USB UHCI
#1 (rev 03)
00:1d.1 USB Controller: Intel Corp. 82801FB/FBM/FR/FW/FRW (ICH6 Family) USB UHCI
#2 (rev 03)
00:1d.2 USB Controller: Intel Corp. 82801FB/FBM/FR/FW/FRW (ICH6 Family) USB UHCI
#3 (rev 03)
00:1d.3 USB Controller: Intel Corp. 82801FB/FBM/FR/FW/FRW (ICH6 Family) USB UHCI
#4 (rev 03)
00:1d.7 USB Controller: Intel Corp. 82801FB/FBM/FR/FW/FRW (ICH6 Family) USB2
EHCI Controller (rev 03)
00:1e.0 PCI bridge: Intel Corp. 82801 PCI Bridge (rev d3)
00:1f.0 ISA bridge: Intel Corp. 82801FB/FR (ICH6/ICH6R) LPC Interface Bridge
(rev 03)
00:1f.1 IDE interface: Intel Corp. 82801FB/FBM/FR/FW/FRW (ICH6 Family) IDE
Controller (rev 03)
00:1f.2 Class 0106: Intel Corp. 82801FR/FRW (ICH6R/ICH6RW) SATA Controller (rev 03)
00:1f.3 SMBus: Intel Corp. 82801FB/FBM/FR/FW/FRW (ICH6 Family) SMBus Controller
(rev 03)
01:00.0 PCI bridge: Intel Corp. 6702PXH PCI Express-to-PCI Bridge A (rev 09)
01:00.1 PIC: Intel Corp. 6700/6702PXH I/OxAPIC Interrupt Controller A (rev 09)
04:00.0 Ethernet controller: Broadcom Corporation NetXtreme BCM5721 Gigabit
Ethernet PCI Express (rev 11)
05:00.0 Ethernet controller: Broadcom Corporation NetXtreme BCM5721 Gigabit
Ethernet PCI Express (rev 11)

Software Environment:
Linux version 2.6.11-rc4 (root@gw1) (gcc version 3.3.4) #1 SMP Mon Feb 14
06:47:58 CET 2005

# /usr/src/linux-2.6.11-rc4/scripts/ver_linux

Linux gw1 2.6.11-rc4 #1 SMP Mon Feb 14 06:47:58 CET 2005 i686 unknown unknown
GNU/Linux

Gnu C                  3.3.4
Gnu make               3.80
binutils               2.15.92.0.2
util-linux             2.12p
mount                  2.12p
module-init-tools      3.1
e2fsprogs              1.35
reiserfsprogs          line
reiser4progs           line
quota-tools            3.12.
PPP                    2.4.2
Linux C Library        2.3.3
Dynamic linker (ldd)   2.3.3
Linux C++ Library      5.0.6
Procps                 3.2.3
Net-tools              1.60
Kbd                    1.12
Sh-utils               5.2.1
/usr/src/linux-2.6.11-rc4/scripts/ver_linux: line 90: udevinfo: command not found
Modules Loaded         bonding

# cat /proc/net/bonding/bond0
Ethernet Channel Bonding Driver: v2.6.1 (October 29, 2004)

Bonding Mode: fault-tolerance (active-backup)
Primary Slave: None
Currently Active Slave: eth1
MII Status: up
MII Polling Interval (ms): 100
Up Delay (ms): 0
Down Delay (ms): 0

Slave Interface: eth0
MII Status: up
Link Failure Count: 3
Permanent HW addr: 00:30:48:XX:XX:XX

Slave Interface: eth1
MII Status: up
Link Failure Count: 0
Permanent HW addr: 00:30:48:XX:XX:XX

# cat /proc/net/vlan/config
VLAN Dev name    | VLAN ID
Name-Type: VLAN_NAME_TYPE_PLUS_VID_NO_PAD
vlan1          | 1  | bond0
vlan2          | 2  | bond0
vlan6          | 6  | bond0
vlan33         | 33  | bond0
vlan5          | 5  | bond0

Problem Description:
I use keepalived for vrrpd. Sometimes, when I restart (kill & start) keepalived
daemon kernel logs:

KERNEL: assertion (!atomic_read(&sk->sk_rmem_alloc)) failed at
net/netlink/af_netlink.c (122)
vlan1: del 01:00:5e:00:00:12 mcast address from master interface

The vlan1 device is used for vrrpd communication between two routers. It is
created over the bound0 interface (eth0+eth1 in active-backup mode).

Anyway, everything seems to work but this message is not very nice.

Steps to reproduce:
# killall keepalived

------- You are receiving this mail because: -------
You are on the CC list for the bug, or are watching someone who is.
