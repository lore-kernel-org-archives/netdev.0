From: Joerg Esser <Jackfritt@boh.de>
Subject: forcedeth 0.15: 08 Nov 2003 for kernel 2.4 just ping and DHCP traffic
 works on ASUS A7N8X-VM
Date: Fri, 14 Nov 2003 20:56:37 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3FB53375.4050705@boh.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: quoted-printable
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi,

I=B4ve tried the above version on my ASUS A7N8X-VM Board because with the=
=20
nvnet driver I just could ping other Computers and the other just could=20
refresh their IP over DHCP(I=B4ve installed it on the Computer with the=20
ASUS Board).
Everything else like Webbrowsing ,FTP, etc didn=B4t work.

Now I tried your driver and I get the same results but with a lot more=20
of debug output.
What am I doing wrong ? Can you help ?
Maybe I can help you with some information ? How do I catch the screen=20
output from the driver
maybe this can help you too ? Looks like network traffic from and to the=20
NIC.

Thx for this nice work.

Motherboard:
ASUS A7N8X-VM with BIOS Version 1009
lspci output:
00:00.0 Host bridge: nVidia Corporation nForce2 AGP (different version?)=20
(rev a2)
00:00.1 RAM memory: nVidia Corporation nForce2 Memory Controller 1 (rev a=
2)
00:00.2 RAM memory: nVidia Corporation nForce2 Memory Controller 4 (rev a=
2)
00:00.3 RAM memory: nVidia Corporation nForce2 Memory Controller 3 (rev a=
2)
00:00.4 RAM memory: nVidia Corporation nForce2 Memory Controller 2 (rev a=
2)
00:00.5 RAM memory: nVidia Corporation nForce2 Memory Controller 5 (rev a=
2)
00:01.0 ISA bridge: nVidia Corporation nForce2 ISA Bridge (rev a4)
00:01.1 SMBus: nVidia Corporation nForce2 SMBus (MCP) (rev a2)
00:02.0 USB Controller: nVidia Corporation nForce2 USB Controller (rev a4=
)
00:02.1 USB Controller: nVidia Corporation nForce2 USB Controller (rev a4=
)
00:02.2 USB Controller: nVidia Corporation nForce2 USB Controller (rev a4=
)
00:04.0 Ethernet controller: nVidia Corporation nForce2 Ethernet=20
Controller (rev a1)
00:06.0 Multimedia audio controller: nVidia Corporation nForce2 AC97=20
Audio Controler (MCP) (rev a1)
00:08.0 PCI bridge: nVidia Corporation nForce2 External PCI Bridge (rev a=
3)
00:09.0 IDE interface: nVidia Corporation nForce2 IDE (rev a2)
00:1e.0 PCI bridge: nVidia Corporation nForce2 AGP (rev a2)
01:00.0 VGA compatible controller: nVidia Corporation NV18 [GeForce4 MX=20
- nForce GPU] (rev a3)
02:06.0 Multimedia controller: Philips Semiconductors SAA7146 (rev 01)
02:07.0 Ethernet controller: Realtek Semiconductor Co., Ltd.=20
RTL-8139/8139C/8139C+ (rev 10)
02:08.0 Multimedia controller: Philips Semiconductors: Unknown device=20
5402 (rev 82)
libc:
/lib/libc.so.6
GNU C Library stable release version 2.3.2, by Roland McGrath et al.
Copyright (C) 2003 Free Software Foundation, Inc.
This is free software; see the source for copying conditions.
There is NO warranty; not even for MERCHANTABILITY or FITNESS FOR A
PARTICULAR PURPOSE.
Compiled by GNU CC version 3.3.1.
Compiled on a Linux 2.4.22 system on 2003-10-06.
Available extensions:
        GNU libio by Per Bothner
        crypt add-on version 2.1 by Michael Glad and others
        linuxthreads-0.10 by Xavier Leroy
        BIND-8.2.3-T5B
        libthread_db work sponsored by Alpha Processor Inc
        NIS(YP)/NIS+ NSS modules 0.19 by Thorsten Kukuk
Report bugs using the `glibcbug' script to <bugs@gnu.org>.
driver insmod output:
Nov 14 19:43:43 chaplin kernel: forcedeth.c: Reverse Engineered nForce=20
ethernet
driver. Version 0.15.
Nov 14 19:43:43 chaplin kernel: PCI: Setting latency timer of device=20
00:04.0 to
64
Nov 14 19:43:43 chaplin kernel: forcedeth: resource 0 start fe800000 len=20
4096 fl
ags 0x00000200.
Nov 14 19:43:43 chaplin kernel: eth1: forcedeth.c: subsystem: 01043:80a7
Nov 14 19:43:43 chaplin kernel: eth1: MAC Address 01:23:45:67:89:ab
Nov 14 19:44:10 chaplin kernel: forcedeth: open
Nov 14 19:44:10 chaplin kernel: eth1: txrx_reset
Nov 14 19:44:10 chaplin kernel: eth1: alloc_rx: Packet  0 marked as=20
Available
.........
Nov 14 19:44:10 chaplin kernel: eth1: alloc_rx: Packet  127 marked as=20
Available
Nov 14 19:44:10 chaplin kernel: eth1: mii_rw read from reg 2 at PHY 1: 0x=
0.
Nov 14 19:44:10 chaplin kernel: eth1: mii_rw read from reg 3 at PHY 1:=20
0x8201.
Nov 14 19:44:10 chaplin kernel: eth1: open: Found PHY 0000:8201 at=20
address 1.
Nov 14 19:44:10 chaplin kernel: eth1: mii_rw read from reg 4 at PHY 1:=20
0x1e1.
Nov 14 19:44:10 chaplin kernel: eth1: mii_rw read from reg 5 at PHY 1: 0x=
0.
Nov 14 19:44:10 chaplin kernel: eth1: update_linkspeed: PHY advertises=20
0x01e1, l
pa 0x0000.
Nov 14 19:44:10 chaplin kernel: eth1: bad ability 0000 - falling back to=20
10HD.
Nov 14 19:44:10 chaplin kernel: eth1: start_rx
Nov 14 19:44:10 chaplin kernel: eth1: stop_rx
Nov 14 19:44:10 chaplin kernel: eth1: start_rx
Nov 14 19:44:10 chaplin kernel: eth1: start_tx
Nov 14 19:44:10 chaplin kernel: eth1: mii_rw read from reg 1 at PHY 1: 0x=
0.
Nov 14 19:44:10 chaplin kernel: eth1: no link during initialization.
Nov 14 19:44:10 chaplin kernel: eth1: nic_irq
Nov 14 19:44:10 chaplin kernel: eth1: irq: 00000020
Nov 14 19:44:10 chaplin kernel: eth1: nic_irq completed
Nov 14 19:44:10 chaplin kernel: eth1: nic_irq
Nov 14 19:44:10 chaplin kernel: eth1: irq: 00000020
.........
