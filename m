From: david rebbe <ic3man5@gmail.com>
Subject: R8169 driver freezes computer, how to debug?
Date: Tue, 5 Apr 2011 10:39:19 -0400
Message-ID: <BANLkTi=4cUNNX6qFfDsbJoL8B+vLX8eAbg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org
To: romieu@fr.zoreil.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gx0-f174.google.com ([209.85.161.174]:44718 "EHLO
	mail-gx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752402Ab1DEOjU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Apr 2011 10:39:20 -0400
Received: by gxk21 with SMTP id 21so151532gxk.19
        for <netdev@vger.kernel.org>; Tue, 05 Apr 2011 07:39:19 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

I'm having an issue with loading this driver. # modprobe r8169
instantly freezes my computer (keyboard/mouse/display) all lock up.
I'm looking for a way to diagnose this problem so I can actually
report it correctly.

Here is a thread I started with information on my issue:
http://www.linuxquestions.org/questions/debian-26/figuring-out-what-the-kernel-is-doing-870343/page2.html

I have 6 realtek cards, three are PCI Express (onboard, 1x slot, 16x
slot) and three PCI. The issue only is there when the 1x card is
inside the 16x slot (Removing/Disabling onboard doesn't help). I've
somewhat looked into debugging the module but haven't found a way to
debug without having the module loaded first.

Would it be worthwhile to try the drivers from realtek's website and
see, if they issue is still present?

# lspci
00:00.0 Host bridge: Advanced Micro Devices [AMD] RS880 Host Bridge
00:01.0 PCI bridge: Advanced Micro Devices [AMD] RS780 PCI to PCI
bridge (int gfx)
00:02.0 PCI bridge: Advanced Micro Devices [AMD] RS780 PCI to PCI
bridge (ext gfx port 0)
00:04.0 PCI bridge: Advanced Micro Devices [AMD] RS780 PCI to PCI
bridge (PCIE port 0)
00:05.0 PCI bridge: Advanced Micro Devices [AMD] RS780 PCI to PCI
bridge (PCIE port 1)
00:11.0 SATA controller: ATI Technologies Inc SB700/SB800 SATA
Controller [IDE mode]
00:12.0 USB Controller: ATI Technologies Inc SB700/SB800 USB OHCI0 Controller
00:12.1 USB Controller: ATI Technologies Inc SB700 USB OHCI1 Controller
00:12.2 USB Controller: ATI Technologies Inc SB700/SB800 USB EHCI Controller
00:13.0 USB Controller: ATI Technologies Inc SB700/SB800 USB OHCI0 Controller
00:13.1 USB Controller: ATI Technologies Inc SB700 USB OHCI1 Controller
00:13.2 USB Controller: ATI Technologies Inc SB700/SB800 USB EHCI Controller
00:14.0 SMBus: ATI Technologies Inc SBx00 SMBus Controller (rev 3c)
00:14.1 IDE interface: ATI Technologies Inc SB700/SB800 IDE Controller
00:14.2 Audio device: ATI Technologies Inc SBx00 Azalia (Intel HDA)
00:14.3 ISA bridge: ATI Technologies Inc SB700/SB800 LPC host controller
00:14.4 PCI bridge: ATI Technologies Inc SBx00 PCI to PCI Bridge
00:14.5 USB Controller: ATI Technologies Inc SB700/SB800 USB OHCI2 Controller
00:18.0 Host bridge: Advanced Micro Devices [AMD] Family 10h Processor
HyperTransport Configuration
00:18.1 Host bridge: Advanced Micro Devices [AMD] Family 10h Processor
Address Map
00:18.2 Host bridge: Advanced Micro Devices [AMD] Family 10h Processor
DRAM Controller
00:18.3 Host bridge: Advanced Micro Devices [AMD] Family 10h Processor
Miscellaneous Control
00:18.4 Host bridge: Advanced Micro Devices [AMD] Family 10h Processor
Link Control
01:05.0 VGA compatible controller: ATI Technologies Inc RS880 [Radeon HD 4200]
02:00.0 Ethernet controller: Realtek Semiconductor Co., Ltd.
RTL8111/8168B PCI Express Gigabit Ethernet controller (rev 03)
03:00.0 Ethernet controller: Realtek Semiconductor Co., Ltd.
RTL8111/8168B PCI Express Gigabit Ethernet controller (rev 03)
04:00.0 Ethernet controller: Realtek Semiconductor Co., Ltd.
RTL8111/8168B PCI Express Gigabit Ethernet controller (rev 03)
05:05.0 Ethernet controller: Realtek Semiconductor Co., Ltd. RTL-8169
Gigabit Ethernet (rev 10)
05:06.0 Ethernet controller: Realtek Semiconductor Co., Ltd. RTL-8169
Gigabit Ethernet (rev 10)
05:07.0 Ethernet controller: Realtek Semiconductor Co., Ltd. RTL-8169
Gigabit Ethernet (rev 10)

Thanks,
Dave
