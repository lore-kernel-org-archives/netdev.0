From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [linux-pm] power draw depending on PHY speed
Date: Fri, 28 Aug 2009 20:29:07 +0100
Message-ID: <1251487747.2785.13.camel@achroite>
References: <76FA3B279DD9DA48896E2B40494495720368E449@USA7061MS02.na.xerox.net>
	 <200908282103.59159.rjw@sisk.pl>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Leisner, Martin" <Martin.Leisner@xerox.com>,
	linux-pm@lists.linux-foundation.org, martyleisner@yahoo.com,
	NetDEV list <netdev@vger.kernel.org>
To: "Rafael J. Wysocki" <rjw@sisk.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost02.mail.zen.net.uk ([212.23.3.141]:39199 "EHLO
	smarthost02.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752316AbZH1T3M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Aug 2009 15:29:12 -0400
In-Reply-To: <200908282103.59159.rjw@sisk.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2009-08-28 at 21:03 +0200, Rafael J. Wysocki wrote:
> On Friday 28 August 2009, Leisner, Martin wrote:
> > While doing some current probe measurements (i.e. to measure the effects
> > of NAP and frequency scaling with a freescale processor) I noticed some
> > very
> > significant differents if we ran on 100Mbit of 1000Mbit ethernet.
> > 
> > The hardware guys like at their data sheets and agreed.
> > 
> > Does anyone "drop ethernet speed" to save power?
> > (when a system is idle, is isn't necessary to run 1G ethernet).
> 
> I don't know, really.  This is a netdev question IMO (CC added).

Doing this through the existing autonegotiation mechanism is a bad idea,
because it requires bringing the link down, possibly for a few seconds.
There is a standard on the way (802.3az, aka Energy-Efficient Ethernet
or EEE) which will allow for speed renegotiation without dropping the
link.

> > When a system has WOL capability, what speed does it run at when the
> > system is sleeping?
> 
> That's a very good question.  I bet that depends on the NIC in question, at
> least I'm not sure if any spec regulates it.

I'm not aware of a spec, but generally a 1G or 10G multi-speed PHY will
not advertise speeds higher than 100 Mbit/s when sleeping.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

