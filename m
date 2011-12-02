From: David Lamparter <equinox@diac24.net>
Subject: Re: ebtables on a stick
Date: Fri, 2 Dec 2011 17:04:42 +0100
Message-ID: <20111202160442.GQ589422@jupiter.n2.diac24.net>
References: <20111128143901.GA589422@jupiter.n2.diac24.net>
 <4ED566A8.2000108@ziu.info>
 <925A849792280C4E80C5461017A4B8A2A048F6@mail733.InfraSupportEtc.com>
 <20111201071456.GJ589422@jupiter.n2.diac24.net>
 <925A849792280C4E80C5461017A4B8A2A048F8@mail733.InfraSupportEtc.com>
 <20111201144745.GK589422@jupiter.n2.diac24.net>
 <925A849792280C4E80C5461017A4B8A2A048F9@mail733.InfraSupportEtc.com>
 <20111201165040.GL589422@jupiter.n2.diac24.net>
 <925A849792280C4E80C5461017A4B8A2A048FA@mail733.InfraSupportEtc.com>
 <4ED8F15D.8020909@ziu.info>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Greg Scott <GregScott@Infrasupport.com>,
	David Lamparter <equinox@diac24.net>, netdev@vger.kernel.org
To: Michal Soltys <soltys@ziu.info>
Return-path: <netdev-owner@vger.kernel.org>
Received: from spaceboyz.net ([87.106.131.203]:44153 "EHLO spaceboyz.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756801Ab1LBQE4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 2 Dec 2011 11:04:56 -0500
Content-Disposition: inline
In-Reply-To: <4ED8F15D.8020909@ziu.info>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Dec 02, 2011 at 04:40:13PM +0100, Michal Soltys wrote:
> You should be able to avoid whole proxy thing altogether (on your 
> router), by doing:
> 
> ip add add 1.2.115.157/32 dev eth0
> ip ro del table local 192.168.99.5/32 dev eth0
> ip route add 1.2.115.157/32 dev eth1

... and any application that looks at the local interface addresses
(e.g. ntpd, bind, etc.) will get thoroughly confused. Oh and worst-case
(i don't know/didn't check) source address selection as well.

I'd advise against it.

> instead of:
> 
> ip neigh add proxy 1.2.115.157 dev eth0


-David
