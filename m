From: Alex Davis <alex14641@yahoo.com>
Subject: Re: System hangs after running 2.6.17rc6 with broadcom 4309 and device scape stack
Date: Sun, 18 Jun 2006 18:25:54 -0700 (PDT)
Message-ID: <20060619012554.5438.qmail@web50207.mail.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Return-path: <netdev-owner@vger.kernel.org>
Received: from web50207.mail.yahoo.com ([206.190.38.48]:53399 "HELO
	web50207.mail.yahoo.com") by vger.kernel.org with SMTP
	id S1751131AbWFSBZ4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 18 Jun 2006 21:25:56 -0400
To: netdev@vger.kernel.org, linville@tuxdriver.com
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--- Alex Davis <alex14641@yahoo.com> wrote:

> After running 2.6.17rc6 with device scape stack 
> (git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-dev.git)
> for a few hours, my system hangs. Here is the last thing I see in my logs:
> 
> [4323255.189000] NETDEV WATCHDOG: wmaster0: transmit timed out
> [4323255.189000] wmaster0: resetting interface.
> [4323255.189000] bcm43xx_d80211: Controller RESET (IEEE reset) ...
> [4323255.191000] bcm43xx_d80211: ASSERTION FAILED (bcm->mac_suspended >= 0) at:
> drivers/net/wireless/d80211/bcm43xx/bcm43xx_main.c:2191:bcm43xx_mac_suspend()
> [4323255.192000] ACPI: PCI interrupt for device 0000:02:03.0 disabled
> [4323255.192000] ACPI: PCI Interrupt 0000:02:03.0[A] -> Link [LNKB] -> GSI 7 (level, low) -> IRQ
> 7
> [4323255.198000] bcm43xx_d80211: Chip ID 0x4306, rev 0x3
> [4323255.198000] bcm43xx_d80211: Number of cores: 5
> [4323255.198000] bcm43xx_d80211: Core 0: ID 0x800, rev 0x4, vendor 0x4243, enabled
> [4323255.198000] bcm43xx_d80211: Core 1: ID 0x812, rev 0x5, vendor 0x4243, disabled
> [4323255.198000] bcm43xx_d80211: Core 2: ID 0x80d, rev 0x2, vendor 0x4243, enabled
> [4323255.198000] bcm43xx_d80211: Core 3: ID 0x807, rev 0x2, vendor 0x4243, disabled
> [4323255.198000] bcm43xx_d80211: Core 4: ID 0x804, rev 0x9, vendor 0x4243, enabled
> [4323255.201000] bcm43xx_d80211: PHY connected
> [4323255.201000] bcm43xx_d80211: Detected PHY: Version: 2, Type 2, Revision 2
> [4323255.201000] bcm43xx_d80211: Detected Radio: ID: 2205017f (Manuf: 17f Ver: 2050 Rev: 2)
> [4323255.201000] bcm43xx_d80211: Radio turned off
> [4323255.201000] bcm43xx_d80211: Radio turned off
> [4323255.201000] bcm43xx_d80211: Controller restarted
> 
> This has happened daily during the two days I've been running this version.
[snip]

Some more info:
Here is dmesg output for module loading.
Jun 16 20:04:06 siafu kernel: [4294720.383000] bcm43xx_d80211 driver
Jun 16 20:04:06 siafu kernel: [4294720.393000] ACPI: PCI Interrupt 0000:02:03.0[A] -> Link [LNKB]
-> GSI 7 (level, low) -> IRQ 7
Jun 16 20:04:06 siafu kernel: [4294720.393000] bcm43xx_d80211: Chip ID 0x4306, rev 0x3
Jun 16 20:04:06 siafu kernel: [4294720.393000] bcm43xx_d80211: Number of cores: 5
Jun 16 20:04:06 siafu kernel: [4294720.393000] bcm43xx_d80211: Core 0: ID 0x800, rev 0x4, vendor
0x4243, enabled
Jun 16 20:04:06 siafu kernel: [4294720.393000] bcm43xx_d80211: Core 1: ID 0x812, rev 0x5, vendor
0x4243, disabled
Jun 16 20:04:06 siafu kernel: [4294720.393000] bcm43xx_d80211: Core 2: ID 0x80d, rev 0x2, vendor
0x4243, enabled
Jun 16 20:04:06 siafu kernel: [4294720.393000] bcm43xx_d80211: Core 3: ID 0x807, rev 0x2, vendor
0x4243, disabled
Jun 16 20:04:06 siafu kernel: [4294720.393000] bcm43xx_d80211: Core 4: ID 0x804, rev 0x9, vendor
0x4243, enabled
Jun 16 20:04:06 siafu kernel: [4294720.396000] bcm43xx_d80211: PHY connected
Jun 16 20:04:06 siafu kernel: [4294720.396000] bcm43xx_d80211: Detected PHY: Version: 2, Type 2,
Revision 2
Jun 16 20:04:06 siafu kernel: [4294720.396000] bcm43xx_d80211: Detected Radio: ID: 2205017f
(Manuf: 17f Ver: 2050 Rev: 2)
Jun 16 20:04:06 siafu kernel: [4294720.396000] bcm43xx_d80211: Radio turned off
Jun 16 20:04:06 siafu kernel: [4294720.396000] bcm43xx_d80211: Radio turned off
Jun 16 20:04:06 siafu kernel: [4294720.464000] wmaster0: Selected rate control algorithm 'simple'
Jun 16 20:04:06 siafu kernel: [4294720.505000] bcm43xx_d80211: Virtual interface added (type:
0x00000002, ID: 4, MAC: 00:90:96:ba:32:20)
Jun 16 20:04:06 siafu kernel: [4294720.511000] bcm43xx_d80211: PHY connected
Jun 16 20:04:07 siafu kernel: [4294720.779000] bcm43xx_d80211: Radio turned on
Jun 16 20:04:07 siafu kernel: [4294720.971000] bcm43xx_d80211: Chip initialized
Jun 16 20:04:07 siafu kernel: [4294720.972000] bcm43xx_d80211: DMA initialized
Jun 16 20:04:07 siafu kernel: [4294720.972000] bcm43xx_d80211: 80211 cores initialized
Jun 16 20:04:07 siafu kernel: [4294720.972000] bcm43xx_d80211: Keys cleared
Jun 16 20:04:07 siafu kernel: [4294720.988000] wmaster0: Does not support passive scan, disabled
Jun 16 20:04:09 siafu kernel: [4294723.027000] bcm43xx_d80211: ASSERTION FAILED
(bcm->interface.if_id == if_id) at:
drivers/net/wireless/d80211/bcm43xx/bcm43xx_main.c:4344:bcm43xx_config_interface()


Here is dmesg output while wpa_supplicant is starting:
Jun 16 20:04:14 siafu kernel: [4294728.406000] wlan0: starting scan
Jun 16 20:04:14 siafu kernel: [4294728.407000] HW CONFIG: channel=1 freq=2412 phymode=3
Jun 16 20:04:14 siafu kernel: [4294728.475000] HW CONFIG: channel=2 freq=2417 phymode=3
Jun 16 20:04:14 siafu kernel: [4294728.543000] HW CONFIG: channel=3 freq=2422 phymode=3
Jun 16 20:04:14 siafu kernel: [4294728.611000] HW CONFIG: channel=4 freq=2427 phymode=3
Jun 16 20:04:14 siafu kernel: [4294728.679000] HW CONFIG: channel=5 freq=2432 phymode=3
Jun 16 20:04:14 siafu kernel: [4294728.747000] HW CONFIG: channel=6 freq=2437 phymode=3
Jun 16 20:04:15 siafu kernel: [4294728.815000] HW CONFIG: channel=7 freq=2442 phymode=3
Jun 16 20:04:15 siafu kernel: [4294728.883000] HW CONFIG: channel=8 freq=2447 phymode=3
Jun 16 20:04:15 siafu kernel: [4294728.951000] HW CONFIG: channel=9 freq=2452 phymode=3
Jun 16 20:04:15 siafu kernel: [4294729.019000] HW CONFIG: channel=10 freq=2457 phymode=3
Jun 16 20:04:15 siafu kernel: [4294729.087000] HW CONFIG: channel=11 freq=2462 phymode=3
Jun 16 20:04:15 siafu kernel: [4294729.170000] HW CONFIG: channel=1 freq=2412 phymode=3
Jun 16 20:04:15 siafu kernel: [4294729.178000] wlan0: scan completed
Jun 16 20:04:15 siafu kernel: [4294729.178000] HW CONFIG: channel=6 freq=2437 phymode=3
Jun 16 20:04:15 siafu kernel: [4294729.186000] wlan0: Initial auth_alg=0
Jun 16 20:04:15 siafu kernel: [4294729.186000] wlan0: authenticate with AP xx:xx:xx:xx:xx:xx
Jun 16 20:04:15 siafu kernel: [4294729.187000] wlan0: RX authentication from XX:XX:XX:XX:XX:XX
(alg=0 transaction=2 status=0)
Jun 16 20:04:15 siafu kernel: [4294729.187000] wlan0: authenticated
Jun 16 20:04:15 siafu kernel: [4294729.187000] wlan0: associate with AP XX:XX:XX:XX:XX:XX
Jun 16 20:04:15 siafu kernel: [4294729.189000] wlan0: RX AssocResp from XX:XX:XX:XX:XX:XX
(capab=0x411 status=0 aid=4)
Jun 16 20:04:15 siafu kernel: [4294729.189000] wlan0: associated
Jun 16 20:04:15 siafu kernel: [4294729.190000] wmaster0: Added STA XX:XX:XX:XX:XX:XX

I am using WEP encryption.

I code, therefore I am

__________________________________________________
Do You Yahoo!?
Tired of spam?  Yahoo! Mail has the best spam protection around 
http://mail.yahoo.com 
