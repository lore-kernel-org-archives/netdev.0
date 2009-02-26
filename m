From: Gary Thomas <gary@mlbassoc.com>
Subject: Re: Marvell 88E609x switch?
Date: Thu, 26 Feb 2009 08:47:29 -0700
Message-ID: <49A6B991.2090703@mlbassoc.com>
References: <49A49C06.90908@mlbassoc.com> <20090225131550.GA24996@xi.wantstofly.org> <49A5B877.8080403@mlbassoc.com> <20090226151107.GN17040@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Lennert Buytenhek <buytenh@wantstofly.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 137-67-76-76.skybeam.com ([76.76.67.137]:4808 "EHLO
	mail.chez-thomas.org" rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org
	with ESMTP id S1753746AbZBZPrl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Feb 2009 10:47:41 -0500
In-Reply-To: <20090226151107.GN17040@xi.wantstofly.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Lennert Buytenhek wrote:
> On Wed, Feb 25, 2009 at 02:30:31PM -0700, Gary Thomas wrote:
> 
>>>> Is there support for this device anywhere?  In particular,
>>>> the M88E6095 switch.
>>> Not at the moment, but it should be easy enough to add.  If your
>>> board already runs on 2.6.28+, I can whip up some patches for you
>>> to try from the docs I have for that part.
>> That would be much appreciated, thanks.
> 
> I noticed that the 6095/6095F are quite similar to the 6131 as far
> as the register set goes.  So something along these lines (hacky
> patch, breaks 6131, not for mainline) might just work to detect
> single 6095s (cascading DSA chips is something that needs more work,
> let's get the single-chip case working first).
> 
> The other thing you'll need to do is create dsa platform devices
> for your switch chips, a la how it's done in arch/arm/mach-orion5x/
> or arch/arm/mach-kirkwood/ for example -- you need to pass in a struct
> device * for your network device, a struct device * for your mii bus,
> the switch MII address on the MII bus, and names of the individual
> ports (where you'll specify "cpu" for the port on the switch chip that
> the CPU is connected to).
> 
> Let me know if this works.
> 

Thanks, I'll give it a try.  It will take a little effort
to get setup as I have to work within the open firmware
structure (that's how all the various components are
specified).

-- 
------------------------------------------------------------
Gary Thomas                 |  Consulting for the
MLB Associates              |    Embedded world
------------------------------------------------------------
