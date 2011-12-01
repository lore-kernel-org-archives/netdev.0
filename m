From: David Lamparter <equinox@diac24.net>
Subject: Re: ebtables on a stick
Date: Thu, 1 Dec 2011 15:47:45 +0100
Message-ID: <20111201144745.GK589422@jupiter.n2.diac24.net>
References: <925A849792280C4E80C5461017A4B8A2A04879@mail733.InfraSupportEtc.com>
 <925A849792280C4E80C5461017A4B8A2A0487A@mail733.InfraSupportEtc.com>
 <925A849792280C4E80C5461017A4B8A2A0487F@mail733.InfraSupportEtc.com>
 <20111128143901.GA589422@jupiter.n2.diac24.net>
 <4ED566A8.2000108@ziu.info>
 <925A849792280C4E80C5461017A4B8A2A048F6@mail733.InfraSupportEtc.com>
 <20111201071456.GJ589422@jupiter.n2.diac24.net>
 <925A849792280C4E80C5461017A4B8A2A048F8@mail733.InfraSupportEtc.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Lamparter <equinox@diac24.net>, netdev@vger.kernel.org
To: Greg Scott <GregScott@Infrasupport.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from spaceboyz.net ([87.106.131.203]:53247 "EHLO spaceboyz.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754588Ab1LAOr7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 1 Dec 2011 09:47:59 -0500
Content-Disposition: inline
In-Reply-To: <925A849792280C4E80C5461017A4B8A2A048F8@mail733.InfraSupportEtc.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 01, 2011 at 08:39:07AM -0600, Greg Scott wrote:
> I wonder what's different this morning?  A bunch of firewall conntrack
> entries would have expired by now.  I was changing rules fast and
> furious last night, maybe there were some stale conntrack entries that
> messed with my head.  But this morning it's working as expected.
> 
> Must be an important project, otherwise it wouldn't give me all this
> trouble.

Heh. Nice to see you got it to work.

A few last words about the subnet mask on the windows box:

The 1.2.115.144/28 subnet is on eth0 on your router. The windows host
with 1.2.115.157 is _not_ connected to that subnet. It is on eth1 on
your router, and it can't reach any hosts from 1.2.115.144/28 without
going through your router, so /32 is the correct configuration there.

That /32 just means "on my ethernet segment i'm alone with that
address". If the windows box has /28 as subnet mask, it will try to ARP
for other hosts from that subnet, instead of going through the router.
So, that'll break connectivity to them...


-David
