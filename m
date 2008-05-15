From: Andy Fleming <afleming@freescale.com>
Subject: Re: [PATCH] PHYLIB: Add 1000Base-X support for Broadcom bcm5482
Date: Thu, 15 May 2008 16:11:13 -0500
Message-ID: <07AD8671-95BB-4E5F-9BDD-469F207EACE1@freescale.com>
References: <1210695378.13845.362.camel@localhost.localdomain> <Pine.LNX.4.55.0805140018340.7267@cliff.in.clinika.pl> <1210804791.13845.423.camel@localhost.localdomain> <Pine.LNX.4.55.0805142354530.15223@cliff.in.clinika.pl> <1210885435.13845.512.camel@localhost.localdomain>
Mime-Version: 1.0 (Apple Message framework v919.2)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Content-Transfer-Encoding: 7bit
Cc: "Maciej W. Rozycki" <macro@linux-mips.org>,
	netdev <netdev@vger.kernel.org>
To: Nate Case <ncase@xes-inc.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from az33egw01.freescale.net ([192.88.158.102]:63836 "EHLO
	az33egw01.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752843AbYEOVLY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 May 2008 17:11:24 -0400
In-Reply-To: <1210885435.13845.512.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On May 15, 2008, at 16:03, Nate Case wrote:

> On Thu, 2008-05-15 at 00:15 +0100, Maciej W. Rozycki wrote:
>> OK.  One note on this occasion: please keep the registers sorted by  
>> the
>> index.  I missed it with the original review, but the additional  
>> registers
>> at 0x15, 0x17 and 0x18 (and the values within) should be placed  
>> between
>> MII_BCM54XX_ESR at 0x11 and MII_BCM54XX_ISR at 0x1a.
>
> Fixed this in patch v3 (coming up shortly).
>
>> I was a bit worried how it plays with actually trying to force  
>> different,
>> perhaps incompatible, link parameters.
>
> I didn't try forcing speeds from userspace, but the worst I can  
> envision
> happening is that after forcing 10mbit/s or half-duplex mode (for
> example) it would still report 1000mbit/s FD.  The forcing itself  
> would
> probably not report an error, though you could argue that it  
> should.  My
> understanding is that the hardware will take the writes but ignore  
> those
> registers in 1000Base-X mode.

To get an error in these situations, you could change the phydev's  
supported modes to indicate only 1000BT is supported, and that  
autonegotiation has to be off.

Andy
