From: Chuck Ebbert <cebbert@redhat.com>
Subject: Re: Does the Netxen driver work?
Date: Mon, 09 Jul 2007 13:31:46 -0400
Message-ID: <46927102.4070502@redhat.com>
References: <468E928D.20606@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: NetDev <netdev@vger.kernel.org>
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:35135 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755664AbXGIRbv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 9 Jul 2007 13:31:51 -0400
In-Reply-To: <468E928D.20606@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 07/06/2007 03:05 PM, Ben Greear wrote:
> Hello!
> 
> I just got some Netxen 10Gbe CX4 adapters and put them into freshly
> updated Fedora 7 64-bit systems.  So far, I am not having much luck.
> 
> Kernel is:  Official F7  2.6.21-1.3228.fc7
> 
> NIC:
> 01:00.0 Ethernet controller: NetXen Incorporated NXB-10GCX4 10 Gigabit
> Ethernet PCIe Adapter with CX4 copper interface (rev 25)
> 
> The motherboard chipset is Intel based (I can provide more info is someone
> cares..but I first wanted to make sure there are no well-known issues.)
> 
> Interesting boot messages:
> 
> Jul  5 16:15:17 a440-dc kernel: ACPI: PCI Interrupt 0000:01:00.0[A] ->
> GSI 16 (level, low) -> IRQ 16
> Jul  5 16:15:17 a440-dc kernel: netxen-nic: unable to allocate MSI
> interrupt error
> Jul  5 16:15:17 a440-dc kernel: netxen-nic: XGbE board initialized
> 
> Is that MSI error fatal?
> 

Try kernel option "pci=msi".

MSI causes so many problems in 2.6.20/2.6.21 that Fedora turned it off by default.
