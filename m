From: Angelo Dureghello <angelo70@gmail.com>
Subject: Micrel KSZ8031 - phy link missing
Date: Wed, 08 Oct 2014 20:28:57 +0200
Message-ID: <54358269.4040205@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f171.google.com ([209.85.212.171]:50700 "EHLO
	mail-wi0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752640AbaJHS3A (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Oct 2014 14:29:00 -0400
Received: by mail-wi0-f171.google.com with SMTP id em10so11238956wid.10
        for <netdev@vger.kernel.org>; Wed, 08 Oct 2014 11:28:59 -0700 (PDT)
Received: from [192.168.0.2] (host155-25-dynamic.14-87-r.retail.telecomitalia.it. [87.14.25.155])
        by mx.google.com with ESMTPSA id gt7sm19394015wib.18.2014.10.08.11.28.58
        for <netdev@vger.kernel.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 08 Oct 2014 11:28:58 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dear,

i am trying to figure out why, moving to kernel 3.16.2, i have phy-link 
missing.

I have an arm-corex AM1808 (TI OMAPL-138/DAVINCI) cpu based board, using 
Micrel KSZ8031.


.....
Bad block table not found for chip 0
Bad block table not found for chip 0
Scanning device for bad blocks
Bad block table written to 0x000007fe0000, version 0x01
Bad block table written to 0x000007fc0000, version 0x01
8 cmdlinepart partitions found on MTD device davinci_nand.0
Creating 8 MTD partitions on "davinci_nand.0":
0x000000000000-0x000000020000 : "u-boot-env"
0x000000020000-0x000000180000 : "u-boot"
0x000000180000-0x0000001a0000 : "bootparms"
0x0000001a0000-0x000000200000 : "factory-info"
EMAC: device MAC address: 00:08:e1:03:2a:c5
GPIO LEDs: old hardware revision detected
0x000000200000-0x000000600000 : "kernel"
0x000000600000-0x000000700000 : "config"
0x000000700000-0x000004300000 : "rootfs"
0x000004300000-0x000007f00000 : "update"
davinci_nand davinci_nand.0: controller rev. 2.5
davinci_mdio davinci_mdio.0: Runtime PM disabled, clock forced on.
davinci_mdio davinci_mdio.0: davinci mdio revision 1.5
davinci_mdio davinci_mdio.0: detected phy mask fffffffc
libphy: davinci_mdio.0: probed
davinci_mdio davinci_mdio.0: phy[0]: device davinci_mdio-0:00, driver 
Micrel KSZ8031
davinci_mdio davinci_mdio.0: phy[1]: device davinci_mdio-0:01, driver 
Micrel KSZ8031
omap_rtc da830-rtc: rtc core: registered da830-rtc as rtc0
da830-rtc: RTC power up reset detected
da830-rtc: already running
usbcore: registered new interface driver usbhid
usbhid: USB HID core driver
TCP: cubic registered
NET: Registered protocol family 17
Key type dns_resolver registered
UBI: attaching mtd6 to ubi0
UBI: scanning is finished
UBI: attached mtd6 (name "rootfs", size 60 MiB) to ubi0
UBI: PEB size: 131072 bytes (128 KiB), LEB size: 126976 bytes
UBI: min./max. I/O unit sizes: 2048/2048, sub-page size 2048
UBI: VID header offset: 2048 (aligned 2048), data offset: 4096
UBI: good PEBs: 480, bad PEBs: 0, corrupted PEBs: 0
UBI: user volume: 1, internal volumes: 1, max. volumes count: 128
UBI: max/mean erase counter: 2/0, WL threshold: 4096, image sequence 
number: 1732378828
UBI: available PEBs: 0, total reserved PEBs: 480, PEBs reserved for bad 
PEB handling: 20
UBI: background thread "ubi_bgt0d" started, PID 978
davinci_emac davinci_emac.1: Runtime PM disabled, clock forced on.
davinci_emac davinci_emac.1: Runtime PM disabled, clock forced on.
davinci_emac davinci_emac.1: Runtime PM disabled, clock forced on.
input: gpio-keys as /devices/platform/gpio-keys.0/input/input0
omap_rtc da830-rtc: setting system clock to 2014-10-08 18:19:00 UTC 
(1412792340)
ALSA device list:
   No soundcards found.
UBIFS: background thread "ubifs_bgt0_0" started, PID 988
UBIFS: mounted UBI device 0, volume 0, name "rootfs"
UBIFS: LEB size: 126976 bytes (124 KiB), min./max. I/O unit sizes: 2048 
bytes/2048 bytes
UBIFS: FS size: 56504320 bytes (53 MiB, 445 LEBs), journal size 9023488 
bytes (8 MiB, 72 LEBs)
UBIFS: reserved for root: 0 bytes (0 KiB)
UBIFS: media format: w4/r0 (latest is w4/r0), UUID 
3946B77C-1A15-4675-B537-F22C6CABE24F, small LPT model
VFS: Mounted root (ubifs filesystem) on device 0:13.
devtmpfs: mounted
Freeing unused kernel memory: 140K (c05ad000 - c05d0000)
Please wait: booting...
Populating /dev using udev: udevd[1008]: starting version 182
done
Starting System Watchdog service: done
Mounting configuration partition...
Checking that all configuration is in place...
Done
Starting LED service: done
Setting time zone...
UTC
Time zone set
Starting network...
davinci_mdio davinci_mdio.0: resetting idled controller
net eth0: attached PHY driver [Micrel KSZ8031] 
(mii_bus:phy_addr=davinci_mdio-0:00, id=221556)
udhcpc (v1.20.2) started
Sending discover...
Sending discover...
Sending discover...
No lease, failing
Adjusting output audio levels
...

It says no lease. But i verified that even setting a fixed ip, board is 
not reachable.
Tracing inside phy.c i don't see the link to come up. Nothing seen on WS.

As far as you know, there can be some bug open for davinci-emac and micrel ?

Many thanks
Angelo
