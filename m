From: carl@bookmanassociates.com
Subject: (Fwd) Linux kernel hanging with certain networking configurati
Date: Fri, 13 Jun 2003 16:12:38 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3EE9F7F6.27521.A125F7@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-description: Mail message body
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Should have included some debug messages (as recommended in REPORTING-
BUGS in /usr/src/linux).


carl@flanger:~ > cat /proc/version 
Linux version 2.4.4-4GB (root@Pentium.suse.de) (gcc version 2.95.3 20010315 
(SuSE)) #1 Fri May 18 14:11:12 GMT 2001



carl@flanger:~ > cat /proc/cpuinfo 
processor       : 0
vendor_id       : GenuineIntel
cpu family      : 15
model           : 2
model name      : Intel(R) Pentium(R) 4 CPU 2.40GHz
stepping        : 7
cpu MHz         : 2405.504
cache size      : 512 KB
fdiv_bug        : no
hlt_bug         : no
f00f_bug        : no
coma_bug        : no
fpu             : yes
fpu_exception   : yes
cpuid level     : 2
wp              : yes
flags           : fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca cmov pat 
pse36 clflush dts acpi mmx fxsr sse sse2 ss tm
bogomips        : 4797.23




carl@flanger:~ > cat /proc/modules
ipv6                  126272  -1 (autoclean)
printer                 4960   0 (unused)
mousedev                4032   0 (unused)
usb-uhci               21840   0 (unused)
8139too                11520   1 (autoclean)
reiserfs              156432   1
hid                    11760   0 (unused)
input                   3168   0 [mousedev hid]
usbcore                47120   1 [printer usb-uhci hid]


carl@flanger:~ > cat /proc/ioports /proc/iomem
0000-001f : dma1
0020-003f : pic1
0040-005f : timer
0060-006f : keyboard
0070-007f : rtc
0080-008f : dma page reg
00a0-00bf : pic2
00c0-00df : dma2
00f0-00ff : fpu
0170-0177 : ide1
01f0-01f7 : ide0
02f8-02ff : serial(auto)
0376-0376 : ide1
03c0-03df : vga+
03f6-03f6 : ide0
03f8-03ff : serial(auto)
0500-051f : PCI device 8086:24c3
0cf8-0cff : PCI conf1
c000-cfff : PCI Bus #01
  c000-c0ff : PCI device 10ec:8139
    c000-c0ff : 8139too
  c400-c47f : PCI device 1106:3044
d000-d01f : PCI device 8086:24c4
  d000-d01f : usb-uhci
d400-d41f : PCI device 8086:24c7
  d400-d41f : usb-uhci
d800-d81f : PCI device 8086:24c2
  d800-d81f : usb-uhci
e000-e0ff : PCI device 8086:24c5
e400-e43f : PCI device 8086:24c5
f000-f00f : PCI device 8086:24cb
  f000-f007 : ide0
  f008-f00f : ide1
00000000-0009fbff : System RAM
0009fc00-0009ffff : reserved
000a0000-000bffff : Video RAM area
000c0000-000c7fff : Video ROM
000f0000-000fffff : System ROM
00100000-0f7effff : System RAM
  00100000-002327d1 : Kernel code
  002327d2-0031bdcb : Kernel data
0f7f0000-0f7f2fff : ACPI Non-volatile Storage
0f7f3000-0f7fffff : ACPI Tables
10000000-100003ff : PCI device 8086:24cb
e0000000-e7ffffff : PCI device 8086:2562
e8000000-ebffffff : PCI device 8086:2560
ec000000-ec0fffff : PCI Bus #01
  ec000000-ec0000ff : PCI device 10ec:8139
    ec000000-ec0000ff : 8139too
  ec001000-ec0017ff : PCI device 1106:3044
ec100000-ec17ffff : PCI device 8086:2562
ec180000-ec1803ff : PCI device 8086:24cd
ec181000-ec1811ff : PCI device 8086:24c5
ec182000-ec1820ff : PCI device 8086:24c5
fec00000-ffffffff : reserved

carl@flanger:~ > cat /proc/scsi/scsi 
Attached devices: none

Attached devices: none
carl@flanger:~ > su
Password: 
USER, n.:
        The word computer professionals use when they mean "idiot."
                -- Dave Barry, "Claw Your Way to the Top"
DANGER!! THIS IS FLANGER!!:/home/carl # lspci -vvv
00:00.0 Host bridge: Intel Corporation: Unknown device 2560 (rev 03)
        Subsystem: Holco Enterprise Co, Ltd/Shuttle Computer: Unknown device fb50
        Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- 
Stepping- SERR- FastB2B-
        Status: Cap+ 66Mhz- UDF- FastB2B+ ParErr- DEVSEL=fast >TAbort- <TAbort- 
<MAbort+ >SERR- <PERR-
        Latency: 0
        Region 0: Memory at e8000000 (32-bit, prefetchable) [size=64M]
        Capabilities: [e4] #09 [4105]

00:02.0 VGA compatible controller: Intel Corporation: Unknown device 2562 (rev 03) 
(prog-if 00 [VGA])
        Subsystem: Holco Enterprise Co, Ltd/Shuttle Computer: Unknown device fb50
        Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- 
Stepping- SERR- FastB2B-
        Status: Cap+ 66Mhz- UDF- FastB2B+ ParErr- DEVSEL=fast >TAbort- <TAbort- 
<MAbort- >SERR- <PERR-
        Latency: 0
        Interrupt: pin A routed to IRQ 16
        Region 0: Memory at e0000000 (32-bit, prefetchable) [size=128M]
        Region 1: Memory at ec100000 (32-bit, non-prefetchable) [size=512K]
        Capabilities: [d0] Power Management version 1
                Flags: PMEClk- DSI+ D1- D2- AuxCurrent=0mA PME(D0-,D1-,D2-,D3hot-
,D3cold-)
                Status: D0 PME-Enable- DSel=0 DScale=0 PME-

00:1d.0 USB Controller: Intel Corporation: Unknown device 24c2 (rev 02) (prog-if 00 
[UHCI])
        Subsystem: Holco Enterprise Co, Ltd/Shuttle Computer: Unknown device fb50
        Control: I/O+ Mem- BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- 
Stepping- SERR- FastB2B-
        Status: Cap- 66Mhz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- 
<TAbort- <MAbort- >SERR- <PERR-
        Latency: 0
        Interrupt: pin A routed to IRQ 16
        Region 4: I/O ports at d800 [size=32]

00:1d.1 USB Controller: Intel Corporation: Unknown device 24c4 (rev 02) (prog-if 00 
[UHCI])
        Subsystem: Holco Enterprise Co, Ltd/Shuttle Computer: Unknown device fb50
        Control: I/O+ Mem- BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- 
Stepping- SERR- FastB2B-
        Status: Cap- 66Mhz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- 
<TAbort- <MAbort- >SERR- <PERR-
        Latency: 0
        Interrupt: pin B routed to IRQ 19
        Region 4: I/O ports at d000 [size=32]

00:1d.2 USB Controller: Intel Corporation: Unknown device 24c7 (rev 02) (prog-if 00 
[UHCI])
        Subsystem: Holco Enterprise Co, Ltd/Shuttle Computer: Unknown device fb50
        Control: I/O+ Mem- BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- 
Stepping- SERR- FastB2B-
        Status: Cap- 66Mhz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- 
<TAbort- <MAbort- >SERR- <PERR-
        Latency: 0
        Interrupt: pin C routed to IRQ 18
        Region 4: I/O ports at d400 [size=32]

00:1d.7 USB Controller: Intel Corporation: Unknown device 24cd (rev 02) (prog-if 20)
        Subsystem: Holco Enterprise Co, Ltd/Shuttle Computer: Unknown device fb50
        Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- 
Stepping- SERR- FastB2B-
        Status: Cap+ 66Mhz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- 
<TAbort- <MAbort- >SERR- <PERR-
        Latency: 0
        Interrupt: pin D routed to IRQ 23
        Region 0: Memory at ec180000 (32-bit, non-prefetchable) [size=1K]
        Capabilities: [50] Power Management version 2
                Flags: PMEClk- DSI- D1- D2- AuxCurrent=375mA PME(D0+,D1-,D2-
,D3hot+,D3cold+)
                Status: D0 PME-Enable- DSel=0 DScale=0 PME-

00:1e.0 PCI bridge: Intel Corporation 82820 820 (Camino 2) Chipset PCI (rev 82) 
(prog-if 00 [Normal decode])
        Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- 
Stepping- SERR+ FastB2B-
        Status: Cap- 66Mhz- UDF- FastB2B+ ParErr- DEVSEL=fast >TAbort- <TAbort- 
<MAbort- >SERR- <PERR+
        Latency: 0
        Bus: primary=00, secondary=01, subordinate=01, sec-latency=32
        I/O behind bridge: 0000c000-0000cfff
        Memory behind bridge: ec000000-ec0fffff
        Prefetchable memory behind bridge: fff00000-000fffff
        BridgeCtl: Parity- SERR+ NoISA+ VGA- MAbort- >Reset- FastB2B-

00:1f.0 ISA bridge: Intel Corporation: Unknown device 24c0 (rev 02)
        Control: I/O+ Mem+ BusMaster+ SpecCycle+ MemWINV- VGASnoop- ParErr- 
Stepping- SERR- FastB2B-
        Status: Cap- 66Mhz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- 
<TAbort- <MAbort- >SERR- <PERR-
        Latency: 0

00:1f.1 IDE interface: Intel Corporation: Unknown device 24cb (rev 02) (prog-if 8a 
[Master SecP PriP])
        Subsystem: Holco Enterprise Co, Ltd/Shuttle Computer: Unknown device fb50
        Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- 
Stepping- SERR- FastB2B-
        Status: Cap- 66Mhz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- 
<TAbort- <MAbort- >SERR- <PERR-
        Latency: 0
        Interrupt: pin A routed to IRQ 16
        Region 0: I/O ports at <unassigned> [size=8]
        Region 1: I/O ports at <unassigned> [size=4]
        Region 2: I/O ports at <unassigned> [size=8]
        Region 3: I/O ports at <unassigned> [size=4]
        Region 4: I/O ports at f000 [size=16]
        Region 5: Memory at 10000000 (32-bit, non-prefetchable) [size=1K]

00:1f.3 SMBus: Intel Corporation: Unknown device 24c3 (rev 02)
        Subsystem: Holco Enterprise Co, Ltd/Shuttle Computer: Unknown device fb50
        Control: I/O+ Mem- BusMaster- SpecCycle- MemWINV- VGASnoop- ParErr- 
Stepping- SERR- FastB2B-
        Status: Cap- 66Mhz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- 
<TAbort- <MAbort- >SERR- <PERR-
        Interrupt: pin B routed to IRQ 17
        Region 4: I/O ports at 0500 [size=32]

00:1f.5 Multimedia audio controller: Intel Corporation: Unknown device 24c5 (rev 02)
        Subsystem: Holco Enterprise Co, Ltd/Shuttle Computer: Unknown device c140
        Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- 
Stepping- SERR- FastB2B-
        Status: Cap+ 66Mhz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- 
<TAbort- <MAbort- >SERR- <PERR-
        Latency: 0
        Interrupt: pin B routed to IRQ 17
        Region 0: I/O ports at e000 [size=256]
        Region 1: I/O ports at e400 [size=64]
        Region 2: Memory at ec181000 (32-bit, non-prefetchable) [size=512]
        Region 3: Memory at ec182000 (32-bit, non-prefetchable) [size=256]
        Capabilities: [50] Power Management version 2
                Flags: PMEClk- DSI- D1- D2- AuxCurrent=375mA PME(D0+,D1-,D2-
,D3hot+,D3cold+)
                Status: D0 PME-Enable- DSel=0 DScale=0 PME-

01:06.0 Ethernet controller: Realtek Semiconductor Co., Ltd. RTL-8139 (rev 10)
        Subsystem: Realtek Semiconductor Co., Ltd. RT8139
        Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- 
Stepping- SERR- FastB2B-
        Status: Cap+ 66Mhz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- 
<TAbort- <MAbort- >SERR- <PERR-
        Latency: 32 (8000ns min, 16000ns max)
        Interrupt: pin A routed to IRQ 18
        Region 0: I/O ports at c000 [size=256]
        Region 1: Memory at ec000000 (32-bit, non-prefetchable) [size=256]
        Capabilities: [50] Power Management version 2
                Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=375mA PME(D0-
,D1+,D2+,D3hot+,D3cold+)
                Status: D0 PME-Enable- DSel=0 DScale=0 PME-

01:07.0 FireWire (IEEE 1394): VIA Technologies, Inc. OHCI Compliant IEEE 1394 
Host Controller (rev 46) (prog-if 10 [OHCI])
        Subsystem: Unknown device 9712:25f0
        Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- 
Stepping- SERR- FastB2B-
        Status: Cap+ 66Mhz- UDF- FastB2B- ParErr- DEVSEL=medium >TAbort- 
<TAbort- <MAbort- >SERR- <PERR-
        Latency: 32 (8000ns max), cache line size 08
        Interrupt: pin A routed to IRQ 19
        Region 0: Memory at ec001000 (32-bit, non-prefetchable) [size=2K]
        Region 1: I/O ports at c400 [size=128]
        Capabilities: [50] Power Management version 2
                Flags: PMEClk- DSI- D1- D2+ AuxCurrent=0mA PME(D0-,D1-
,D2+,D3hot+,D3cold+)
                Status: D0 PME-Enable- DSel=0 DScale=0 PME-




Boxes are called "flanger" (our box) which is not running a firewall but has 
/proc/sys/net/ipv4/rp_forward = 1 and "desdemona" (their box) which has a packet 
filtering firewall running that should have no filtering for device ppp0 because that 
device is marked as "internal" (box also has 2 ethernet NICs, eth0 which is "external" 
and connects to the medical school's network then on via firewall to the internet and 
eth1 which is "internal" and connects to the LAN with the Win 2k client PCs on it).



Regards,
Carl

------- Forwarded message follows -------
X-cs: R
From: Self <carl@bookmanassociates.com>
X-RS-ID: <Default>
X-RS-Flags: 1,0,1,1,0,0,0
X-RS-Sigset: 0
To: netdev@oss.sgi.com
Subject: Linux kernel hanging with certain networking configuration - uncertain of relevant maintainer
Comments: Confirmation of reading was requested.
MIME-Version: 1.0
Content-type: text/plain; charset=ISO-8859-1
Content-transfer-encoding: 8BIT
Date: Fri, 13 Jun 2003 15:59:01 +0100

Hello,

Sorry to bother you if you're the wrong person to contact, I got your
name from the MAINTAINERS list in /usr/src/linux on my distribution
(kernel 2.4.4).  If you are the wrong person could you tell me where I
should go please?

We have successfully used a linux server in our small office for a
year now and it has been almost entirely stable.  Recently I
configured a VPN to connect to one of our client sites.  I installed a
linux server at that site also, because they are behind a firewall
over which I have no control (being on a medical school's network) I
used the method described in the Firewall Piercing mini-howto.  Namely
I configured pppd to run ssh to connect from that machine to ours here
and run pppd on this end, once the tunnel is set up both ends add
routes through it to each other's subnets in the ip-up scripts on
either end (neither end is using PPP for any other connections, both
are connected to the "outside world" via ethernet NICs).

This tunnel is largely stable and satisfactory but if intensive load
is placed on it (the reliable, reproducible load I use is a remote
control software package called PC Duo) then the server machine at our
end hangs and has to be rebooted using the reset button on the front
or a power off/on cycle.  The machine becomes completely unresponsive
to pinging from other machines on our LAN, the keyboard becomes
unresponsive and the screen freezes.

I understand that this is called a "kernel panic" but, unlike other
reports I have seen on the internet, there is no "oops" dump thing
that comes up on the screen - the screen simply freezes.

To add to the mystery I have found this problem with both the OpenSSH
package and the non-commercial SSH package (v3.2.3) from ftp.ssh.com
PLUS I have also seen something similar where I ran an SSH client on a
Windows PC here that connected to the SSH daemon on their firewall
with the relevant port for PCDuo control forwarded and then ran an ssh
client on that firewall machine through to an SSH daemon on the linux
box I support in our client's office, again forwarding the port.  This
configuration doesn't use ppp at any point yet when I ran PCDuo
control over that connection it worked briefly then hung their server,
which again had to be rebooted!

Can you help at all?  Is there some way of getting this "oops" output
from linux if that would help?

Yours with regards,
Carl Peto
------- End of forwarded message -------
