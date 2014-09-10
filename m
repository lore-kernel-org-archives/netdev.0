From: Luis de Lago <luisdelago@gmail.com>
Subject: Trouble with Realtek Ethernet RTL8111/8168/8411 (rev 12)
Date: Wed, 10 Sep 2014 14:47:09 +0200
Message-ID: <CAMafrUA0pC01sAw=-nbsknVY_mA1OoW=goehchbyWC0qq0+oCg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f177.google.com ([209.85.213.177]:35505 "EHLO
	mail-ig0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750899AbaIJMrK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Sep 2014 08:47:10 -0400
Received: by mail-ig0-f177.google.com with SMTP id uq10so2908175igb.10
        for <netdev@vger.kernel.org>; Wed, 10 Sep 2014 05:47:09 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello everybody,

i was directed here by members of the arch forum where i have reported
my problem and where the information provided below is perhaps more
readable:
https://bbs.archlinux.org/viewtopic.php?pid=1455220#p1455220

if i shouldn't have written to you plz feel free to let me know and
plz help me adressing this to the right channel.

my situation is the following ... [BlogPost]

i plugin the ethernet cable but network manager still shows "no cable
attached" and no ip adress information ...

neither the lights of the ethernet port of the router nor the ones of
the laptop light up ...

here are my details:
i have the same problem under arch in kernel 3.16 and 3.14 and under
ubuntu 14.04 kernel 3.13

$ ifconfig
-------------------------------------------------------------------------------------
enp3s0f1: flags=4099<UP,BROADCAST,MULTICAST>  mtu 1500
        ether 00:90:f5:f9:fd:d9  txqueuelen 1000  (Ethernet)
        RX packets 0  bytes 0 (0.0 B)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 0  bytes 0 (0.0 B)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0

lo: flags=73<UP,LOOPBACK,RUNNING>  mtu 65536
        inet 127.0.0.1  netmask 255.0.0.0
        inet6 ::1  prefixlen 128  scopeid 0x10<host>
        loop  txqueuelen 0  (Local Loopback)
        RX packets 656  bytes 51072 (49.8 KiB)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 656  bytes 51072 (49.8 KiB)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0

wlp2s0: wlan chip by intel works fine

$ lspci -v
----------------------------------------------------------------------------------------------
[...]

03:00.0 Unassigned class [ff00]: Realtek Semiconductor Co., Ltd.
Device 5287 (rev 01)
Subsystem: CLEVO/KAPOK Computer Device 5494
Flags: bus master, fast devsel, latency 0, IRQ 56
Memory at f7c15000 (32-bit, non-prefetchable) [size=4K]
Expansion ROM at f7c00000 [disabled] [size=64K]
Capabilities: <access denied>
Kernel driver in use: rtsx_pci
Kernel modules: rtsx_pci

03:00.1 Ethernet controller: Realtek Semiconductor Co., Ltd.
RTL8111/8168/8411 PCI Express Gigabit Ethernet Controller (rev 12)
Subsystem: CLEVO/KAPOK Computer Device 5494
Flags: bus master, fast devsel, latency 0, IRQ 61
I/O ports at e000 [size=256]
Memory at f7c14000 (64-bit, non-prefetchable) [size=4K]
Memory at f7c10000 (64-bit, non-prefetchable) [size=16K]
Capabilities: <access denied>
Kernel driver in use: r8169
Kernel modules: r8169

the computer that has the problem is a laptop and i dunno why there
are 2 Realtek Entries ... it definitly has only ONE ethernet port!

((installing aur r8168 and loading the module ofc did not fix the
problem as suggested by others ...))

$ dmesg | grep 8169
------------------------------------------------------------
[    2.304595] r8169 Gigabit Ethernet driver 2.3LK-NAPI loaded
[    2.304609] r8169 0000:03:00.1: can't disable ASPM; OS doesn't have
ASPM control
[    2.310138] r8169 0000:03:00.1: irq 61 for MSI/MSI-X
[    2.310452] r8169 0000:03:00.1 eth0: RTL8411 at 0xffffc900018c6000,
00:90:f5:f9:fd:d9, XID 1c800880 IRQ 61
[    2.310457] r8169 0000:03:00.1 eth0: jumbo features [frames: 9200
bytes, tx checksumming: ko]
[    5.594516] r8169 0000:03:00.1 enp3s0f1: rtl_phy_reset_cond == 1
(loop: 100, delay: 1).
[    5.596608] r8169 0000:03:00.1 enp3s0f1: link down

thanks for reading!

Bruno
