From: Jack Daniel <wanders.thirst@gmail.com>
Subject: Intel Pro1000 on CN5020, hangs Uboot
Date: Wed, 14 Apr 2010 13:48:41 +0530
Message-ID: <y2pf6b367b71004140118s93d7b47rfa88399bfbe5b91b@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pw0-f46.google.com ([209.85.160.46]:63021 "EHLO
	mail-pw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752433Ab0DNISm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Apr 2010 04:18:42 -0400
Received: by pwj9 with SMTP id 9so6075410pwj.19
        for <netdev@vger.kernel.org>; Wed, 14 Apr 2010 01:18:41 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I have a OCTEON CN5020, on which I tried plugging in an Intel Pro 1000
PCI NIC. But Uboot hangs with a trap exception. Uboot has no problems
with a Realtek RTL8139 NIC PCI card that supports 100MBps. Could
someone tell me the reason for such a behaviour?

Regards,
Jack


Uboot Version (as reported by Uboot) : U-Boot 1.1.1 (Development
build, svnversion: u-boot:47725, exec:47725)
Uboot start up message:
PAL rev: 1.01, MCU rev: 1.07, CPU voltage: 1.20
DRAM:  512 MB
Clearing DRAM....... done
Flash:  8 MB
BIST check passed.
Starting PCI
PCI Status: PCI 32-bit
Reg: 0x0 0x0
Reg: 0x1 0x62
Reg: 0x2 0x0
Reg: 0x3 0x0
Reg: 0x4 0x0
Reg: 0x5 0xE
Reg: 0x6 0x1
Reg: 0x7 0xFFFFFFFFC00D5C70
Reg: 0x8 0x800119040000000E
Reg: 0x9 0x61784
Reg: 0xA 0xFFFFFFFFC0000A4C
Reg: 0xB 0xFFFFFFFFC0062208
Reg: 0xC 0xFFFFFFFFC0062550
Reg: 0xD 0xFFFFFFFFC005E4A0
Reg: 0xE 0x20
Reg: 0xF 0x0
Reg: 0x10 0xFFFFFFFFC00D5CA0
Reg: 0x11 0xFFFFFFFFC008F490
Reg: 0x12 0x0
Reg: 0x13 0x0
Reg: 0x14 0x0
Reg: 0x15 0x0
Reg: 0x16 0xFF00
Reg: 0x17 0xFFFFFFFFC00D5CA6
Reg: 0x18 0xFFFFFFFFC0062550
Reg: 0x19 0xFFFFFFFFC0038E24
Reg: 0x1A 0xFFFFFFFFFFFF8000
Reg: 0x1B 0x30
Reg: 0x1C 0xFFFFFFFFBFC621D0
Reg: 0x1D 0xFFFFFFFFFFFF97F8
Reg: 0x1E 0xFFFFFFFFC00D5CA4
Reg: 0x1F 0xFFFFFFFFBFC00AE0
status:   0x504000E7
cause:    0x4000801C
epc:      0xFFFFFFFFC0038EC8
badvaddr: 0x0
