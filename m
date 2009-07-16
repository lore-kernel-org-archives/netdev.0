From: Caleb Cushing <xenoterracide@gmail.com>
Subject: Re: e1000e 2.6.30.1 massive packet loss
Date: Thu, 16 Jul 2009 05:05:51 -0400
Message-ID: <81bfc67a0907160205q7b20354bsf2389e3f7feac004@mail.gmail.com>
References: <81bfc67a0907160049q3d43093cy52276f0fe1157d89@mail.gmail.com>
	 <4A5EDEF7.7090303@cosmosbay.com>
	 <81bfc67a0907160120i2528d9abq6c1bd6ffbae8a433@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from an-out-0708.google.com ([209.85.132.250]:62870 "EHLO
	an-out-0708.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754170AbZGPJFx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jul 2009 05:05:53 -0400
In-Reply-To: <81bfc67a0907160120i2528d9abq6c1bd6ffbae8a433@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2.6.30.1 with the issue.

           CPU0       CPU1       CPU2       CPU3
  0:         36          0          0          0    XT-PIC-XT        timer
  1:          2          0          0          0    XT-PIC-XT        i8042
  2:          0          0          0          0    XT-PIC-XT        cascade
  4:          3          0          0          0    XT-PIC-XT        ohci1394
  5:        392          0          0          0    XT-PIC-XT
uhci_hcd:usb2, EMU10K1
  6:          2          0          0          0    XT-PIC-XT        floppy
  8:        163          0          0          0    XT-PIC-XT        rtc0
  9:          0          0          0          0    XT-PIC-XT
acpi, ehci_hcd:usb3, uhci_hcd:usb6
 10:          0          0          0          0    XT-PIC-XT
uhci_hcd:usb4
 11:       1318          0          0          0    XT-PIC-XT
ehci_hcd:usb1, uhci_hcd:usb5, uhci_hcd:usb7, uhci_hcd:usb8
 12:          4          0          0          0    XT-PIC-XT        i8042
 25:        801        812        813        785   PCI-MSI-edge      i915
 26:       3233       3217       3261       3263   PCI-MSI-edge      ahci
 27:        199        200        184        173   PCI-MSI-edge      eth0
NMI:          0          0          0          0   Non-maskable interrupts
LOC:      14886      16536      13854      15765   Local timer interrupts
SPU:          0          0          0          0   Spurious interrupts
RES:        504        515        358        397   Rescheduling interrupts
CAL:         55         79         74         44   Function call interrupts
TLB:        649       1202        685        902   TLB shootdowns
TRM:          0          0          0          0   Thermal event interrupts
THR:          0          0          0          0   Threshold APIC interrupts
ERR:          0
MIS:          0

qdisc pfifo_fast 0: dev eth0 root bands 3 priomap  1 2 2 2 1 2 0 0 1 1
1 1 1 1 1 1
 Sent 82807 bytes 499 pkt (dropped 0, overlimits 0 requeues 0)
 rate 0bit 0pps backlog 0b 0p requeues 0

eth0      Link encap:Ethernet  HWaddr 00:21:9B:06:4C:C9
          inet addr:192.168.1.3  Bcast:192.168.1.255  Mask:255.255.255.0
          inet6 addr: fe80::221:9bff:fe06:4cc9/64 Scope:Link
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:366 errors:0 dropped:0 overruns:0 frame:0
          TX packets:519 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:100
          RX bytes:130219 (127.1 Kb)  TX bytes:86900 (84.8 Kb)
          Memory:fdfc0000-fdfe0000

lo        Link encap:Local Loopback
          inet addr:127.0.0.1  Mask:255.0.0.0
          inet6 addr: ::1/128 Scope:Host
          UP LOOPBACK RUNNING  MTU:16436  Metric:1
          RX packets:817 errors:0 dropped:0 overruns:0 frame:0
          TX packets:817 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:0
          RX bytes:55043 (53.7 Kb)  TX bytes:55043 (53.7 Kb)
