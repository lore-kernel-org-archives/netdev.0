From: Aravind Gottipati <aravind@freeshell.org>
Subject: Re: e1000 poor network performance - 2.6.17-rc5-g705af309
Date: Sun, 28 May 2006 17:49:04 +0000
Message-ID: <20060528174904.GA20099@SDF.LONESTAR.ORG>
References: <20060526212243.GA19250@SDF.LONESTAR.ORG> <4807377b0605271410j39532f44j2cafd3239d40bf31@mail.gmail.com> <20060528074310.GA16499@SDF.LONESTAR.ORG> <20060528090409.08a9bce8@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx.freeshell.ORG ([192.94.73.18]:9459 "EHLO sdf.lonestar.org")
	by vger.kernel.org with ESMTP id S1750830AbWE1RtI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 May 2006 13:49:08 -0400
Received: from sdf.lonestar.org (IDENT:aravind@otaku.freeshell.org [192.94.73.2])
	by sdf.lonestar.org (8.13.5.20060308/8.12.10) with ESMTP id k4SHn4dK011720
	for <netdev@vger.kernel.org>; Sun, 28 May 2006 17:49:04 GMT
Received: (from aravind@localhost)
	by sdf.lonestar.org (8.13.5.20060308/8.12.8/Submit) id k4SHn4u2024080
	for netdev@vger.kernel.org; Sun, 28 May 2006 17:49:04 GMT
To: netdev@vger.kernel.org
Content-Disposition: inline
In-Reply-To: <20060528090409.08a9bce8@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, May 28, 2006 at 09:04:09AM -0700, Stephen Hemminger wrote:
> What is the interrupt assignment on this machine? 
> 	cat /proc/interrupts

root@dogmatrix:~# cat /proc/interrupts 
           CPU0       
  0:     250325    IO-APIC-edge  timer
  1:        386    IO-APIC-edge  i8042
  8:          1    IO-APIC-edge  rtc
  9:        208   IO-APIC-level  acpi
 12:       3000    IO-APIC-edge  i8042
 14:         38    IO-APIC-edge  ide0
 20:       3815   IO-APIC-level  libata, yenta, uhci_hcd:usb2, eth0, i915@pci:0000:00:02.0
 21:          2   IO-APIC-level  ohci1394, uhci_hcd:usb3
 22:          0   IO-APIC-level  sdhci:slot0, uhci_hcd:usb4
 23:         78   IO-APIC-level  ehci_hcd:usb1, uhci_hcd:usb5
NMI:          0 
LOC:     242918 
ERR:          0
MIS:          0
root@dogmatrix:~# 

