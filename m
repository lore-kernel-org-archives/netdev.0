From: Jagan Teki <jagannadh.teki@gmail.com>
Subject: Link up issue on ethernet/realtek/r8169.c
Date: Fri, 4 Apr 2014 12:17:51 +0530
Message-ID: <CAD6G_RTVPip-G34AxLRpFbs50WFFtWS6yth-r-E889h2B2Cd-w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: nic_swsd@realtek.com, romieu@fr.zoreil.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

I'm using TP-LINK PCIe NIC card on my PCIe Root Complex.

Probing looks fine by setting:
r8169 Gigabit Ethernet driver 2.3LK-NAPI loaded
PCI: enabling device 0000:00:00.0 (0140 -> 0143)
PCI: enabling device 0000:01:00.0 (0140 -> 0143)
r8169 0000:01:00.0 eth0: RTL8168e/8111e at 0xf006a000,
c0:4a:00:07:18:d4, XID 0c200000 IRQ 89
r8169 0000:01:00.0 eth0: jumbo features [frames: 9200 bytes, tx
checksumming: ko]

But I have an issue while in link is up

$ ifconfig 192.168.1.10 up
r8169 0000:01:00.0: Direct firmware load failed with error -2
r8169 0000:01:00.0: Falling back to user helper
r8169 0000:01:00.0 eth0: unable to load firmware patch
rtl_nic/rtl8168e-2.fw (-2)
r8169 0000:01:00.0 eth0: link down

Looks like firmware loading is failed in open call, Can any one
suggest how to debug further.

thanks!
-- 
Jagan.
