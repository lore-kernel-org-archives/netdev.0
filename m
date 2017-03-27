From: Nathan Royce <nroycea+kernel-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: ath: firmware panic! exccause: 0x0000000d
Date: Mon, 27 Mar 2017 03:26:38 -0500
Message-ID: <CALaQ_hrEk5_iHQ7TPXe3+6LKDfuqXVfmYNGW3Jb0hqwnL4up-A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: ath9k-devel-A+ZNKFmMK5xy9aJCnZT0Uw@public.gmane.org, kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org,
        linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

I find that every time all of the cpu cores are being used, when
compiling the kernel source for example, I end up losing my wireless
adapter.
It seems to be an old issue: https://bbs.archlinux.org/viewtopic.php?id=182173

ARM ODroid XU4

$ uname -a
Linux server 4.11.0-rc1-00315-g106e4da60209-dirty #1 SMP Sun Mar 12
16:44:41 CDT 2017 armv7l GNU/Linux

$ lsusb
...
Bus 003 Device 009: ID 0cf3:7015 Qualcomm Atheros Communications
TP-Link TL-WN821N v3 / TL-WN822N v2 802.11n [Atheros A
R7010+AR9287]
...

*****
Mar 27 02:48:49 server kernel: usb 3-1.2.4: ath: firmware panic!
exccause: 0x0000000d; pc: 0x0090ae81; badvaddr: 0x10ff4038
Mar 27 02:48:49 server kernel: usb 3-1.2.4: USB disconnect, device number 7
Mar 27 02:48:49 server kernel: ath: phy0: Chip reset failed
Mar 27 02:48:49 server kernel: ath: phy0: Unable to reset channel
(2442 Mhz) reset status -22
Mar 27 02:48:49 server kernel: ath: phy0: Unable to set channel
Mar 27 02:48:49 server kernel: ath: phy0: RX failed to go idle in 10
ms RXSM=0x4ceb
Mar 27 02:48:49 server kernel: ath: phy0: Failed to wakeup in 500us
Mar 27 02:48:49 server kernel: ath: phy0: RX failed to go idle in 10
ms RXSM=0x4ceb
Mar 27 02:48:49 server kernel: ath: phy0: Failed to wakeup in 500us
Mar 27 02:48:50 server kernel: br0: port 2(custom_wlan0) entered disabled state
Mar 27 02:48:50 server audit: ANOM_PROMISCUOUS dev=custom_wlan0 prom=0
old_prom=256 auid=4294967295 uid=0 gid=0 ses=4294967
Mar 27 02:48:50 server kernel: device custom_wlan0 left promiscuous mode
Mar 27 02:48:50 server kernel: br0: port 2(custom_wlan0) entered disabled state
Mar 27 02:48:50 server hostapd[422]: custom_wlan0: AP-STA-DISCONNECTED
<sanitized>
Mar 27 02:48:50 server systemd-networkd[414]: custom_wlan0: Lost carrier
Mar 27 02:48:50 server hostapd[422]: Failed to set beacon parameters
Mar 27 02:48:50 server hostapd[422]: custom_wlan0: INTERFACE-DISABLED
Mar 27 02:48:50 server kernel: usb 3-1.2.4: ath9k_htc: USB layer deinitialized
Mar 27 02:48:50 server systemd[1]: Starting Load/Save RF Kill Switch Status...
-- Subject: Unit systemd-rfkill.service has begun start-up
-- Defined-By: systemd
-- Support: http://lists.freedesktop.org/mailman/listinfo/systemd-devel
--
-- Unit systemd-rfkill.service has begun starting up.
Mar 27 02:48:50 server systemd[1]: Started Load/Save RF Kill Switch Status.
-- Subject: Unit systemd-rfkill.service has finished start-up
-- Defined-By: systemd
-- Support: http://lists.freedesktop.org/mailman/listinfo/systemd-devel
--
-- Unit systemd-rfkill.service has finished starting up.
--
-- The start-up result is done.
Mar 27 02:48:50 server kernel: usb 3-1.2.4: new high-speed USB device
number 9 using xhci-hcd
Mar 27 02:48:50 server kernel: usb 3-1.2.4: New USB device found,
idVendor=0cf3, idProduct=7015
Mar 27 02:48:50 server kernel: usb 3-1.2.4: New USB device strings:
Mfr=16, Product=32, SerialNumber=48
Mar 27 02:48:50 server kernel: usb 3-1.2.4: Product: USB WLAN
Mar 27 02:48:50 server kernel: usb 3-1.2.4: Manufacturer: ATHEROS
Mar 27 02:48:50 server kernel: usb 3-1.2.4: SerialNumber: 12345
Mar 27 02:48:50 server kernel: usb 3-1.2.4: ath9k_htc: Firmware
ath9k_htc/htc_7010-1.4.0.fw requested
Mar 27 02:48:50 server kernel: usb 3-1.2.4: ath9k_htc: Transferred FW:
ath9k_htc/htc_7010-1.4.0.fw, size: 72812
Mar 27 02:48:50 server kernel: ath9k_htc 3-1.2.4:1.0: ath9k_htc: HTC
initialized with 45 credits
Mar 27 02:48:50 server kernel: ath9k_htc 3-1.2.4:1.0: ath9k_htc: FW Version: 1.4
...
*****
