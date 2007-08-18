From: Willy Tarreau <w@1wt.eu>
Subject: Re: Marvell 88E8056 gigabit ethernet controller
Date: Sat, 18 Aug 2007 14:17:14 +0200
Message-ID: <20070818121714.GA28247@1wt.eu>
References: <20070818053812.GP6002@1wt.eu> <244053.17817.qm@web38913.mail.mud.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Kevin E <kevin360@yahoo.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 1wt.eu ([62.212.114.60]:1739 "EHLO 1wt.eu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750759AbXHRMZF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 18 Aug 2007 08:25:05 -0400
Content-Disposition: inline
In-Reply-To: <244053.17817.qm@web38913.mail.mud.yahoo.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Aug 18, 2007 at 04:45:26AM -0700, Kevin E wrote:
> 
> --- Willy Tarreau <w@1wt.eu> wrote:
> 
> > No Stephen, look again, he says that moving the
> > video card into the broken
> > system does not change anything.
> 
> Correct, I've used three different video cards in the
> broken machine.  I've used an old PCI vid card, the
> PCI-X vid card from the working machine, and now PCI-X
> card I just bought yesterday (nvidia based).  None
> have affected whether the Marvell chipset works or
> not.  
> 
> Also, the broken machine is a server so I don't start
> X on it.  It just sits in console mode all the time. 
> The CPU (Core2 E4400) used to be in the working
> machine, then upgraded it to the Q6600 and put the old
> E4400 in the new MB that became the broken machine. 
> Memory was brand new out of the package.  So I've used
> the E4400 in a MB that worked fine.
> 
> 
> > I don't understand why the working one is on PCI bus
> > 3 while the other
> > is on PCI bus 4. It's just as if the chip embedded a
> > PCI bridge. Maybe
> > those chips are just cheaper dual-channel
> > controllers with one faulty
> > controller disabled. It would also explain why the
> > PCI ID is different.
> 
> I've attached the "lspci -vvv" output for the two
> machines, if it doesn't come through just let me know
> how I can get it to you.

OK, in this trace, both controllers are on the same bus. The broken
one has 'Capabilities: [100] Advanced Error Reporting' the other
does not have, and the bridge to this bus has two more capabilities :
'Capabilities: [100] Virtual Channel' and 'Capabilities: [180] Unknown (5)'.

I don't know whether it can jutify a different behaviour. Also, maybe this
is caused by a minuscule difference in the BIOS setup ?

Regards,
Willy

