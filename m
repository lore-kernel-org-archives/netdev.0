From: =?ISO-8859-1?Q?Cristian_Rodr=EDguez?= <crrodriguez@opensuse.org>
Subject: e1000e: Disabling IRQ #57 .. machine dies
Date: Tue, 11 Sep 2012 15:50:25 -0300
Message-ID: <504F87F1.5040004@opensuse.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: Netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f46.google.com ([209.85.219.46]:36760 "EHLO
	mail-oa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758563Ab2IKSwN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Sep 2012 14:52:13 -0400
Received: by oago6 with SMTP id o6so459276oag.19
        for <netdev@vger.kernel.org>; Tue, 11 Sep 2012 11:52:12 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi:

In current linus tree, in a machine using the e1000e driver

hwinfo --netcard
22: PCI 400.0: 0200 Ethernet controller
  [Created at pci.319]
  Unique ID: rBUF.cuT2KaC3ZS1
  Parent ID: HnsE.Z52SDLRIaH2
  SysFS ID: /devices/pci0000:00/0000:00:1c.5/0000:04:00.0
  SysFS BusID: 0000:04:00.0
  Hardware Class: network
  Model: "Intel 82574L Gigabit Network Connection"
  Vendor: pci 0x8086 "Intel Corporation"
  Device: pci 0x10d3 "82574L Gigabit Network Connection"
  SubVendor: pci 0x1043 "ASUSTeK Computer Inc."
  SubDevice: pci 0x8369
  Driver: "e1000e"
  Driver Modules: "e1000e"
  Device File: eth0
  Memory Range: 0xf7d00000-0xf7d1ffff (rw,non-prefetchable)
  I/O Ports: 0xd000-0xdfff (rw)
  Memory Range: 0xf7d20000-0xf7d23fff (rw,non-prefetchable)
  IRQ: 17 (no events)
  Link detected: yes
  Module Alias: "pci:v00008086d000010D3sv00001043sd00008369bc02sc00i00"
  Driver Info #0:
    Driver Status: e1000e is active
    Driver Activation Cmd: "modprobe e1000e"
  Config Status: cfg=no, avail=yes, need=no, active=unknown
  Attached to: #15 (PCI bridge)



cat /proc/interrupts

57 IR-PCI-MSI-edge      eth0

the driver works after a while, but then a single message

"Disabling IRQ #57"

is sent to the console and the machine dies, nothing else is written in
the logs and remote ikvm becames unresponsive so there is no way to
bring more debug info back.. kernel 3.5.3 works ok.

Anyone else seeing this ?
