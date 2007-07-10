From: Dhananjay Phadke <dhananjay.phadke@gmail.com>
Subject: Re: Does the Netxen driver work?
Date: Tue, 10 Jul 2007 10:03:02 +0530
Message-ID: <46930BFE.1020101@gmail.com>
References: <468E928D.20606@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wa-out-1112.google.com ([209.85.146.178]:11337 "EHLO
	wa-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750992AbXGJEhR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Jul 2007 00:37:17 -0400
Received: by wa-out-1112.google.com with SMTP id v27so1692803wah
        for <netdev@vger.kernel.org>; Mon, 09 Jul 2007 21:37:16 -0700 (PDT)
In-Reply-To: <468E928D.20606@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The MSI error wasn't fatal, so it was suppressed in recent fixes for
2.6.22-rc7. The driver in 2.6.21 had many bugs, but I ain't sure if
recent fixes are going to be pulled in Fedora kernel.

-Dhananjay

Ben Greear wrote:
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
> The two NICs are connected by a CX4 cable, and from dmesg output, it
> appears
> they have negotiated link properly.
> 
> However, I see tx counters incrementing on both sides, but no rx counters.
> 
> I will try the latest 22-pre kernel in the meantime, but if anyone has
> any experience getting these NICs to work, I'm interested to know about it.
> 
> Thanks,
> Ben
> 
