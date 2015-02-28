From: Marcel Holtmann <marcel@holtmann.org>
Subject: Realtek ethernet broken with 4.0-rc1 (invalid MAC address)
Date: Fri, 27 Feb 2015 21:20:29 -0800
Message-ID: <2534A403-D18D-4CF5-919F-0A38285AA58F@holtmann.org>
Mime-Version: 1.0 (Mac OS X Mail 8.2 \(2070.6\))
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from senator.holtmann.net ([87.106.208.187]:33850 "EHLO
	mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750704AbbB1FUf convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 Feb 2015 00:20:35 -0500
Received: from [192.168.1.122] (S010620c9d099deff.vc.shawcable.net [50.67.167.179])
	by mail.holtmann.org (Postfix) with ESMTPSA id 8E8898B338
	for <netdev@vger.kernel.org>; Sat, 28 Feb 2015 06:20:32 +0100 (CET)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I am having the following Realtek ethernet card in the Minnowboard Max:

02:00.0 Ethernet controller: Realtek Semiconductor Co., Ltd. RTL8111/8168/8411 PCI Express Gigabit Ethernet Controller (rev 0c)
        Subsystem: Realtek Semiconductor Co., Ltd. Device 0123
        Flags: bus master, fast devsel, latency 0, IRQ 266
        I/O ports at 1000 [size=256]
        Memory at 90500000 (64-bit, non-prefetchable) [size=4K]
        Memory at 90400000 (64-bit, prefetchable) [size=16K]
        Capabilities: [40] Power Management version 3
        Capabilities: [50] MSI: Enable+ Count=1/1 Maskable- 64bit+
        Capabilities: [70] Express Endpoint, MSI 01
        Capabilities: [b0] MSI-X: Enable- Count=4 Masked-
        Capabilities: [d0] Vital Product Data
        Capabilities: [100] Advanced Error Reporting
        Capabilities: [140] Virtual Channel
        Capabilities: [160] Device Serial Number xx-00-00-00-xx-xx-xx-00
        Capabilities: [170] Latency Tolerance Reporting
        Kernel driver in use: r8169
        Kernel modules: r8169

When I am running the 4.0-rc1 kernel (4.0.0-0.rc1.git0.1.fc22.x86_64 to be precise), then the MAC address of this card is invalid:

1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN mode DEFAULT group default 
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
2: enp2s0: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN mode DEFAULT group default qlen 1000
    link/ether ff:ff:ff:ff:ff:ff brd ff:ff:ff:ff:ff:ff

Just for reference, when I boot a 3.18 kernel, then card just work fine and it has a valid MAC address. So somewhere in between something broke.

Regards

Marcel
