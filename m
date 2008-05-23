From: Jon Masters <jonathan@jonmasters.org>
Subject: Re: network interface *name* alias support?
Date: Fri, 23 May 2008 10:50:43 -0400
Message-ID: <1211554243.11907.4.camel@perihelion>
References: <1211410078.27149.70.camel@perihelion>
	 <1211548070.21380.500.camel@pmac.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Woodhouse <dwmw2@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dallas.jonmasters.org ([72.29.103.172]:53253 "EHLO
	dallas.jonmasters.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751327AbYEWOuq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 May 2008 10:50:46 -0400
In-Reply-To: <1211548070.21380.500.camel@pmac.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Fri, 2008-05-23 at 14:07 +0100, David Woodhouse wrote:
> On Wed, 2008-05-21 at 18:47 -0400, Jon Masters wrote:
> > 
> > I would like to add support for network interface name aliases to the
> > kernel. For example, rather than simply "eth0", one might have:
> > 
> > eth0 -> eth_slot_0_0
> > 
> > And use either name for device configuration, etc. This should be pretty
> > easy, but I would like some comments - in particular, has this been done
> > already and I'm missing something?
> > 
> > Why is this useful? Say, for example that your a manufacturer building
> > machines using the latest DMI extension to SMBIOS that allows you to
> > specify what the physical ordering of interfaces is. Then, a
> > distribution might choose to configure based on the physical slot
> > ordering specified by the vendor - allowing for "rip and replace".
> 
> Why do you need a given interface to have more than one name? Why not
> just assign names according to whatever criteria you care about?
> That's entirely a udev problem, surely?

Well, for various reasons, we have folks who want to always retain the
existing "legacy" naming to "avoid confusion". Yeah, personally I don't
really think it matters...but apparently it does, so I'm happy to oblige
and have udev set an alias according to physical slot position aswell.

Jon.


