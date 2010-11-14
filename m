From: Guillaume Leclanche <guillaume@leclanche.net>
Subject: sky2 for on-board 88e8055 fails to detect mac address
Date: Sun, 14 Nov 2010 12:42:06 +0100
Message-ID: <AANLkTinR9vpuGoizvNsvnpMBM-UnWS66yMjwMQaKSk_c@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qw0-f46.google.com ([209.85.216.46]:51880 "EHLO
	mail-qw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755233Ab0KNLm1 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 14 Nov 2010 06:42:27 -0500
Received: by qwh5 with SMTP id 5so861114qwh.19
        for <netdev@vger.kernel.org>; Sun, 14 Nov 2010 03:42:26 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

I use a "Marvell Technology Group Ltd. 88E8055 PCI-E Gigabit Ethernet
Controller".
It seems that=A0the sky2 module doesn't manage to grab the mac address
from the HW :

[    0.741173] sky2: driver version 1.28
[    0.741206] sky2 0000:02:00.0: PCI INT A -> GSI 17 (level, low) -> I=
RQ 17
[    0.741216] sky2 0000:02:00.0: setting latency timer to 64
[    0.741244] sky2 0000:02:00.0: Yukon-2 EC Ultra chip revision 2
[    0.741339] sky2 0000:02:00.0: irq 44 for MSI/MSI-X
[    0.744781] sky2 0000:02:00.0: eth0: addr 00:00:00:00:00:00

Of course I can set the mac address manually with "ip link set eth0
addr ..." (and then it works fine) but I guess that's not the normal
behavior from the driver?

I'd be happy to troubleshoot but I'm not very used to kernel
internals, so tell me if you need some output.
Below a few targeted info about my system.

Guillaume

2.6.35-22-generic #35-Ubuntu SMP Sat Oct 16 20:36:48 UTC 2010 i686 GNU/=
Linux

02:00.0 Ethernet controller: Marvell Technology Group Ltd. 88E8055
PCI-E Gigabit Ethernet Controller
	Subsystem: Marvell Technology Group Ltd. 88E8055 PCI-E Gigabit
Ethernet Controller
	Flags: bus master, fast devsel, latency 0, IRQ 44
	Memory at fe8fc000 (64-bit, non-prefetchable) [size=3D16K]
	I/O ports at a800 [size=3D256]
	Expansion ROM at fe8c0000 [disabled] [size=3D128K]
	Capabilities: [48] Power Management version 3
	Capabilities: [50] Vital Product Data
	Capabilities: [5c] MSI: Enable+ Count=3D1/1 Maskable- 64bit+
	Capabilities: [e0] Express Legacy Endpoint, MSI 00
	Capabilities: [100] Advanced Error Reporting
	Kernel driver in use: sky2
	Kernel modules: sky2
