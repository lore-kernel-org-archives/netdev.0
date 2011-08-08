From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: 802.3ad bonding brain damaged?
Date: Mon, 08 Aug 2011 21:42:58 +0100
Message-ID: <1312836178.2863.12.camel@bwh-desktop>
References: <4E3EECF6.90409@cfl.rr.com>
	 <1312790234.7020.26.camel@arkology.n2.diac24.net>
	 <4E4041B5.5040908@cfl.rr.com> <4E4043AB.1060500@genband.com>
	 <4E4047CF.5030705@cfl.rr.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Chris Friesen <chris.friesen@genband.com>,
	David Lamparter <equinox@diac24.net>, netdev@vger.kernel.org
To: Phillip Susi <psusi@cfl.rr.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:54046 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752196Ab1HHUnC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Aug 2011 16:43:02 -0400
In-Reply-To: <4E4047CF.5030705@cfl.rr.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2011-08-08 at 16:32 -0400, Phillip Susi wrote:
> On 8/8/2011 4:14 PM, Chris Friesen wrote:
> > Bonding doesn't know about "higher level protocols". Also, assuming that
> > higher level protocols already deal with reordering can be dangerous.
> > I've dealt with network protocols and apps that assumed there would be
> > no reordering because at the time they were written they used
> > point-to-point links. They actually work fairly well with single links,
> > so it would be reasonable to try and keep them working with bonded links.
> 
> Try, sure, but if you can't without seriously affecting performance, 
> then having a knob for damn the torpedoes, full speed ahead mode seems 
> reasonable.
> 
> I wonder how it is that people have reported that Windows machines 
> manage to do this?  Come to think of it, can windows even bond in 
> software?  Maybe it's only possible on Windows with dual port cards 
> where the drivers and hardware can make sure that the bonded interfaces 
> service a single queue and maintain ordering that way?

Microsoft doesn't provide a generic bonding driver for Windows.  (This
probably a sensible choice, considering how many different things people
expect the Linux bonding driver to do.)  Some hardware vendors provide
bonding or 'teaming' drivers that work with their own hardware, and
sometimes with other drivers as well.  So if people report that 'Windows
machines manage to do this' then you need to ask those people *which*
driver they are using.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

