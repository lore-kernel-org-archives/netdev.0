From: Pavel Roskin <proski@gnu.org>
Subject: Re: What is in bcm43xx-wireless-dev.git?
Date: Sun, 14 Jan 2007 11:39:10 -0500
Message-ID: <20070114113910.py9s0gggk8gwskwo@webmail.spamcop.net>
References: <20070113024543.aj2n40s4k0g0cgws@webmail.spamcop.net>
	<200701141115.43799.mb@bu3sch.de>
	<20070114091812.hz2fokosw0o0cc0k@webmail.spamcop.net>
	<200701141651.46705.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=_4a5qijdyp58g"
Content-Transfer-Encoding: 7bit
Cc: bcm43xx-dev@lists.berlios.de, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgate.cesmail.net ([216.154.195.36]:37150 "HELO
	mailgate.cesmail.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1751331AbXANQjM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 14 Jan 2007 11:39:12 -0500
To: Michael Buesch <mb@bu3sch.de>
In-Reply-To: <200701141651.46705.mb@bu3sch.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This message is in MIME format.

--=_4a5qijdyp58g
Content-Type: text/plain; charset="ISO-8859-1"
Content-Disposition: inline
Content-Transfer-Encoding: 7bit

Quoting Michael Buesch <mb@bu3sch.de>:

> Ok, nice.
> Can you send me a complete dmesg log after you brought up the card
> and tried to assoc/send some packets?

Attached.

--
Regards,
Pavel Roskin

--=_4a5qijdyp58g
Content-Type: text/x-log; charset="ISO-8859-1"; name="kernel.log"
Content-Disposition: attachment; filename="kernel.log"
Content-Transfer-Encoding: 7bit

ACPI: PCI Interrupt 0000:0c:00.0[A] -> GSI 17 (level, low) -> IRQ 17
PCI: Setting latency timer of device 0000:0c:00.0 to 64
ssb: Sonics Silicon Backplane found on PCI device 0000:0c:00.0
ssb: Core 0 found: ChipCommon (cc 0x800, rev 0x11, vendor 0x4243)
ssb: Core 1 found: IEEE 802.11 (cc 0x812, rev 0x0A, vendor 0x4243)
ssb: Core 2 found: USB 1.1 Host (cc 0x817, rev 0x03, vendor 0x4243)
ssb: Core 3 found: PCI-E (cc 0x820, rev 0x01, vendor 0x4243)
ssb: Switching to ChipCommon core, index 0
ssb: Switching to PCI-E core, index 3
ssb: PCIcore in client mode found
wmaster0: Selected rate control algorithm 'simple'
ssb: Switching to IEEE 802.11 core, index 1
ssb: Switching to PCI-E core, index 3
ssb: Switching to IEEE 802.11 core, index 1
bcm43xx_d80211: Adding Interface type 2
bcm43xx_d80211: Found PHY: Version 4, Type 2, Revision 8
bcm43xx_d80211: Found Radio: Manuf 0x17F, Version 0x2050, Revision 2
bcm43xx_d80211: Loading firmware version 351.126 (2006-07-29 05:54:02)
ssb: Switching to ChipCommon core, index 0
ssb: Switching to IEEE 802.11 core, index 1
bcm43xx_d80211: Radio turned on
bcm43xx_d80211: FIXME: Possibly broken code in bcm43xx_phy_initg() at drivers/net/wireless/d80211/bcm43xx/bcm43xx_phy.c:1650
bcm43xx_d80211: Chip initialized
bcm43xx_d80211: 32-bit DMA initialized
bcm43xx_d80211: Wireless interface started
wmaster0: Does not support passive scan, disabled
wlan0: starting scan
wlan0: scan completed
bcm43xx_d80211: Using hardware based encryption for keyidx: 0, mac: ff:ff:ff:ff:ff:ff
wlan0: Initial auth_alg=0
wlan0: authenticate with AP 00:0f:66:2f:ef:59
wlan0: authenticate with AP 00:0f:66:2f:ef:59
wlan0: authenticate with AP 00:0f:66:2f:ef:59
wlan0: authentication with AP 00:0f:66:2f:ef:59 timed out
bcm43xx_d80211: Using hardware based encryption for keyidx: 0, mac: ff:ff:ff:ff:ff:ff
wlan0: starting scan
wlan0: scan completed
bcm43xx_d80211: Using hardware based encryption for keyidx: 0, mac: ff:ff:ff:ff:ff:ff
bcm43xx_d80211: Using hardware based encryption for keyidx: 0, mac: ff:ff:ff:ff:ff:ff
wlan0: starting scan
wlan0: scan completed
bcm43xx_d80211: Using hardware based encryption for keyidx: 0, mac: ff:ff:ff:ff:ff:ff
bcm43xx_d80211: Using hardware based encryption for keyidx: 0, mac: ff:ff:ff:ff:ff:ff
wlan0: starting scan
bcm43xx_d80211: Wireless interface stopped
bcm43xx_d80211: Removing Interface type 2
bcm43xx_d80211: DMA-32 0x0200 (RX) max used slots: 1/64
bcm43xx_d80211: DMA-32 0x02A0 (TX) max used slots: 0/128
bcm43xx_d80211: DMA-32 0x0280 (TX) max used slots: 0/128
bcm43xx_d80211: DMA-32 0x0260 (TX) max used slots: 0/128
bcm43xx_d80211: DMA-32 0x0240 (TX) max used slots: 0/128
bcm43xx_d80211: DMA-32 0x0220 (TX) max used slots: 2/128
bcm43xx_d80211: DMA-32 0x0200 (TX) max used slots: 0/128
bcm43xx_d80211: Radio turned off
ssb: Switching to ChipCommon core, index 0
bcm43xx_d80211: Adding Interface type 2
ssb: Switching to IEEE 802.11 core, index 1
bcm43xx_d80211: Found PHY: Version 4, Type 2, Revision 8
bcm43xx_d80211: Found Radio: Manuf 0x17F, Version 0x2050, Revision 2
bcm43xx_d80211: Loading firmware version 351.126 (2006-07-29 05:54:02)
ssb: Switching to ChipCommon core, index 0
ssb: Switching to IEEE 802.11 core, index 1
bcm43xx_d80211: Radio turned on
bcm43xx_d80211: FIXME: Possibly broken code in bcm43xx_phy_initg() at drivers/net/wireless/d80211/bcm43xx/bcm43xx_phy.c:1650
bcm43xx_d80211: Chip initialized
bcm43xx_d80211: 32-bit DMA initialized
bcm43xx_d80211: Wireless interface started
wmaster0: Does not support passive scan, disabled
bcm43xx_d80211: Using hardware based encryption for keyidx: 0, mac: ff:ff:ff:ff:ff:ff
bcm43xx_d80211: Using hardware based encryption for keyidx: 0, mac: ff:ff:ff:ff:ff:ff
wlan0: starting scan
wlan0: scan completed
bcm43xx_d80211: Using hardware based encryption for keyidx: 0, mac: ff:ff:ff:ff:ff:ff
wlan0: starting scan
wlan0: scan completed
bcm43xx_d80211: Using hardware based encryption for keyidx: 0, mac: ff:ff:ff:ff:ff:ff
wlan0: Initial auth_alg=0
wlan0: authenticate with AP 00:0f:66:2f:ef:59
wlan0: authenticate with AP 00:0f:66:2f:ef:59
wlan0: authenticate with AP 00:0f:66:2f:ef:59
wlan0: authentication with AP 00:0f:66:2f:ef:59 timed out
bcm43xx_d80211: Using hardware based encryption for keyidx: 0, mac: ff:ff:ff:ff:ff:ff
wlan0: starting scan
wlan0: scan completed
bcm43xx_d80211: Using hardware based encryption for keyidx: 0, mac: ff:ff:ff:ff:ff:ff
bcm43xx_d80211: Using hardware based encryption for keyidx: 0, mac: ff:ff:ff:ff:ff:ff
bcm43xx_d80211: Wireless interface stopped
bcm43xx_d80211: Removing Interface type 2
bcm43xx_d80211: DMA-32 0x0200 (RX) max used slots: 1/64
bcm43xx_d80211: DMA-32 0x02A0 (TX) max used slots: 0/128
bcm43xx_d80211: DMA-32 0x0280 (TX) max used slots: 0/128
bcm43xx_d80211: DMA-32 0x0260 (TX) max used slots: 0/128
bcm43xx_d80211: DMA-32 0x0240 (TX) max used slots: 0/128
bcm43xx_d80211: DMA-32 0x0220 (TX) max used slots: 2/128
bcm43xx_d80211: DMA-32 0x0200 (TX) max used slots: 0/128
bcm43xx_d80211: Radio turned off
ssb: Switching to ChipCommon core, index 0

--=_4a5qijdyp58g
Content-Type: text/x-log; charset="ISO-8859-1"; name="wpa_supplicant.log"
Content-Disposition: attachment; filename="wpa_supplicant.log"
Content-Transfer-Encoding: 7bit

# ./wpa_supplicant -D wext -i wlan0 -c JEDI3.conf 
ioctl[SIOCSIWAUTH]: Operation not supported
WEXT auth param 4 value 0x0 - ioctl[SIOCSIWAUTH]: Operation not supported
WEXT auth param 5 value 0x1 - Trying to associate with 00:0f:66:2f:ef:59 (SSID='JEDI' freq=2437 MHz)
ioctl[SIOCSIWAUTH]: Operation not supported
WEXT auth param 5 value 0x1 - ioctl[SIOCSIWMODE]: Device or resource busy
Association request to the driver failed
Authentication with 00:00:00:00:00:00 timed out.
Trying to associate with 00:0f:66:2f:ef:59 (SSID='JEDI' freq=2437 MHz)
ioctl[SIOCSIWAUTH]: Operation not supported
WEXT auth param 5 value 0x1 - ioctl[SIOCSIWMODE]: Device or resource busy
Association request to the driver failed
Authentication with 00:00:00:00:00:00 timed out.
Trying to associate with 00:0f:66:2f:ef:59 (SSID='JEDI' freq=2437 MHz)
ioctl[SIOCSIWAUTH]: Operation not supported
WEXT auth param 5 value 0x1 - ioctl[SIOCSIWMODE]: Device or resource busy
Association request to the driver failed
Authentication with 00:00:00:00:00:00 timed out.
CTRL-EVENT-TERMINATING - signal 2 received
ioctl[SIOCSIWAUTH]: Operation not supported
WEXT auth param 5 value 0x0 - ioctl[SIOCSIWAUTH]: Operation not supported

--=_4a5qijdyp58g--
