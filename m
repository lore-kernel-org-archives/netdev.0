From: Nico Schottelius <nico-linux-20120113@schottelius.org>
Subject: brcmsmac: 3.2.0-06100: no device shown (and hangs in 3.2.0-rc7)
Date: Fri, 13 Jan 2012 13:45:59 +0100
Message-ID: <20120113124559.GA2260@schottelius.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Nico Schottelius <nico-linux-20120113@schottelius.org>
To: LKML <linux-kernel@vger.kernel.org>, b43-dev@lists.infradead.org,
	netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

with 3.2.0-06100-ge343a89 brcmsmac does not get autoloaded anymore
from udev. Loading it manually returns in dmesg:

--------------------------------------------------------------------------------
[  247.495705] bcma: Core 0 found: ChipCommon (manuf 0x4BF, id 0x800,
rev 0x22, class 0x0)
[  247.495749] bcma: Core 1 found: IEEE 802.11 (manuf 0x4BF, id 0x812,
rev 0x17, class 0x0)
[  247.495832] bcma: Core 2 found: PCIe (manuf 0x4BF, id 0x820, rev
0x0F, class 0x0)
[  247.560553] bcma: Unsupported SPROM revision: 255
[  247.560563] bcma: No SPROM available
[  247.560852] bcma: Bus registered
[  247.611789] brcmsmac bcma0:0: mfg 4bf core 812 rev 23 class 0 irq 17
[  247.634051] ieee80211 phy0: wl0: brcms_b_attach: si_attach failed
[  247.634062] ieee80211 phy0: wl0: brcms_b_attach: failed with err 11
[  247.634069] ieee80211 phy0: wl0: brcms_c_attach: failed with err 11
[  247.634111] ieee80211 phy0: brcmsmac: attach() failed with code 11
[  247.634128] brcmsmac: brcms_bcma_probe: brcms_attach failed!
--------------------------------------------------------------------------------

And ip does not show any device:

--------------------------------------------------------------------------------
[13:37] brief:~% ip l
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 16436 qdisc noqueue state UNKNOWN 
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
--------------------------------------------------------------------------------

With 3.2.0-rc7 the device works, until it begins to hang. As reported
many times before.  As I've switched the environment, it is very good
probable that an AP on channel 13 is in range.

Attached both dmesg/lsmod/configs.

Cheers,

Nico

-- 
PGP key: 7ED9 F7D3 6B10 81D7 0EC5  5C09 D7DC C8E4 3187 7DF0
