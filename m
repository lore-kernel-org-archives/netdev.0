From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: Marvell 88E8056 gigabit ethernet controller
Date: Fri, 17 Aug 2007 17:03:41 -0700
Message-ID: <20070817170341.7f2645fa@freepuppy.rosehill.hemminger.net>
References: <424491.59139.qm@web38906.mail.mud.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Kevin E <kevin360@yahoo.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:52288 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751364AbXHRAEO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Aug 2007 20:04:14 -0400
In-Reply-To: <424491.59139.qm@web38906.mail.mud.yahoo.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 17 Aug 2007 05:42:13 -0700 (PDT)
Kevin E <kevin360@yahoo.com> wrote:

> Hi all,
> 
> 	I've read where the onboard Marvell lan controller on
> some Gigabyte boards don't work.  I've got two systems
> using the same Gigabyte board, on one the LAN works on
> the other it dies like described by others.  Here's
> the systems:
> 
> 
> Working system:
> Gigabyte 965P-DS3 rev 3.3  (BIOS F10)
> Core2 Q6600
> 2GB Corsair XMS2 memory
> kernel 2.6.22.3
> 
> lspci for LAN controller:
> 04:00.0 Ethernet controller: Marvell Technology Group
> Ltd. 88E8056 PCI-E Gigabit Ethernet Controller (rev
> 14)
> 
> 
> Broken system:
> Gigabyte 965P-DS3 rev 3.3  (BIOS F10)
> Core2 E4400
> 2GB Corsair XMS2 memory
> kernel 2.6.22.3
> 
> lspci for LAN controller:
> 03:00.0 Ethernet controller: Marvell Technology Group
> Ltd. Unknown device 4364 (rev 12)
> 
> 
> 	The BIOS for the two systems are setup the same and
> the config for the kernels are the same too.  I've
> actually tried taking the kernel from the working
> system and booting it on the broken one but still the
> LAN dies after a couple of seconds.  The working
> system has one card plugged in (nvidia based PCI-X
> video card), I've taken that card and plugged into the
> broken system, booted the same kernel, and it still
> dies after a while.
> 
> 	I will gladly provide any info needed if it can help
> in getting this chipset working on the Gigabyte
> boards.
> 
> 	Thanks,
> 	Kevin

I maintain the sky2 driver, and have one of the (buggy) Gigabyte motherboards.
It is interesting that the problem seems to track with video card.
Are you using the Nvidia binary driver?
The video card in the system I have troubles with is:
	ATI Technologies Inc RV370 [Radeon X300SE]

Surprisingly, using other PCI-E cards with same driver (different Marvell chips)
has no problem.  Vendor version of sk98lin driver has same failure mode
on the buggy hardware.

You might want to look at lspci -vvv output on two system to see if there
are differences. Perhaps there is a CPU speed dependency?

