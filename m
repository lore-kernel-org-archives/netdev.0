From: =?KOI8-R?B?88XSx8XKIOnXwc7P1w==?= <1@sergey.im>
Subject: Problem with Realtek 8168
Date: Fri, 26 Apr 2013 00:46:07 +0400
Message-ID: <CAMmiNRR7+5y_1QgRZD93qzP7uQ6QQSBRhSh=cubotj6HXmdeNg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f45.google.com ([209.85.215.45]:33020 "EHLO
	mail-la0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758328Ab3DYUqJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Apr 2013 16:46:09 -0400
Received: by mail-la0-f45.google.com with SMTP id el20so55978lab.32
        for <netdev@vger.kernel.org>; Thu, 25 Apr 2013 13:46:08 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi

I have similar problem as described here:
http://www.spinics.net/lists/netdev/msg227052.html

I have ubuntu 13.04 and Asus M5A97 R2.0 mainboard. The problem also
present in ubuntu 12.10.

modinfo r8168
filename:       /lib/modules/3.8.0-19-generic/updates/dkms/r8168.ko
version:        8.035.00-NAPI
license:        GPL
description:    RealTek RTL-8168 Gigabit Ethernet driver
author:         Realtek and the Linux r8168 crew <netdev@vger.kernel.org>
srcversion:     0B1D58537B8144A161D189A
alias:          pci:v00001186d00004300sv00001186sd00004B10bc*sc*i*
alias:          pci:v000010ECd00008168sv*sd*bc*sc*i*
depends:
vermagic:       3.8.0-19-generic SMP mod_unload modversions
parm:           eee_enable:int
parm:           speed:force phy operation. Deprecated by ethtool (8). (ushort)
parm:           duplex:force phy operation. Deprecated by ethtool (8). (int)
parm:           autoneg:force phy operation. Deprecated by ethtool (8). (int)
parm:           aspm:Enable ASPM. (int)
parm:           rx_copybreak:Copy breakpoint for copy-only-tiny-frames (int)
parm:           use_dac:Enable PCI DAC. Unsafe on 32 bit PCI slot. (int)
parm:           debug:Debug verbosity level (0=none, ..., 16=all) (int)

modinfo r8169
filename:
/lib/modules/3.8.0-19-generic/kernel/drivers/net/ethernet/realtek/r8169.ko
firmware:       rtl_nic/rtl8168g-1.fw
firmware:       rtl_nic/rtl8106e-1.fw
firmware:       rtl_nic/rtl8411-1.fw
firmware:       rtl_nic/rtl8402-1.fw
firmware:       rtl_nic/rtl8168f-2.fw
firmware:       rtl_nic/rtl8168f-1.fw
firmware:       rtl_nic/rtl8105e-1.fw
firmware:       rtl_nic/rtl8168e-3.fw
firmware:       rtl_nic/rtl8168e-2.fw
firmware:       rtl_nic/rtl8168e-1.fw
firmware:       rtl_nic/rtl8168d-2.fw
firmware:       rtl_nic/rtl8168d-1.fw
version:        2.3LK-NAPI
license:        GPL
description:    RealTek RTL-8169 Gigabit Ethernet driver
author:         Realtek and the Linux r8169 crew <netdev@vger.kernel.org>
srcversion:     4CACFE2257FFC70ED84FF19
alias:          pci:v00000001d00008168sv*sd00002410bc*sc*i*
alias:          pci:v00001737d00001032sv*sd00000024bc*sc*i*
alias:          pci:v000016ECd00000116sv*sd*bc*sc*i*
alias:          pci:v00001259d0000C107sv*sd*bc*sc*i*
alias:          pci:v00001186d00004302sv*sd*bc*sc*i*
alias:          pci:v00001186d00004300sv*sd*bc*sc*i*
alias:          pci:v00001186d00004300sv00001186sd00004B10bc*sc*i*
alias:          pci:v000010ECd00008169sv*sd*bc*sc*i*
alias:          pci:v000010ECd00008168sv*sd*bc*sc*i*
alias:          pci:v000010ECd00008167sv*sd*bc*sc*i*
alias:          pci:v000010ECd00008136sv*sd*bc*sc*i*
alias:          pci:v000010ECd00008129sv*sd*bc*sc*i*
depends:
intree:         Y
vermagic:       3.8.0-19-generic SMP mod_unload modversions
parm:           use_dac:Enable PCI DAC. Unsafe on 32 bit PCI slot. (int)
parm:           debug:Debug verbosity level (0=none, ..., 16=all) (int)


Apr 24 22:35:35 drcomp kernel: [    1.705083] r8169 Gigabit Ethernet
driver 2.3LK-NAPI loaded
Apr 24 22:35:35 drcomp kernel: [    1.705370] r8169 0000:02:00.0: irq
89 for MSI/MSI-X
Apr 24 22:35:35 drcomp kernel: [    1.705643] r8169 0000:02:00.0 eth0:
RTL8168f/8111f at 0xffffc90000c7e000, 60:a4:4c:2c:f9:23, XID 08000800
IRQ 89
Apr 24 22:35:35 drcomp kernel: [    1.705646] r8169 0000:02:00.0 eth0:
jumbo features [frames: 9200 bytes, tx checksumming: ko]
