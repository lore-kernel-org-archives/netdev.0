From: David Lamparter <equinox@diac24.net>
Subject: Re: ebtables on a stick
Date: Mon, 28 Nov 2011 16:30:02 +0100
Message-ID: <20111128153002.GB589422@jupiter.n2.diac24.net>
References: <925A849792280C4E80C5461017A4B8A2A04879@mail733.InfraSupportEtc.com>
 <925A849792280C4E80C5461017A4B8A2A0487A@mail733.InfraSupportEtc.com>
 <925A849792280C4E80C5461017A4B8A2A0487F@mail733.InfraSupportEtc.com>
 <20111128143901.GA589422@jupiter.n2.diac24.net>
 <925A849792280C4E80C5461017A4B8A2A0488A@mail733.InfraSupportEtc.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Lamparter <equinox@diac24.net>, netdev@vger.kernel.org
To: Greg Scott <GregScott@Infrasupport.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from spaceboyz.net ([87.106.131.203]:34042 "EHLO spaceboyz.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751293Ab1K1PaI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 Nov 2011 10:30:08 -0500
Content-Disposition: inline
In-Reply-To: <925A849792280C4E80C5461017A4B8A2A0488A@mail733.InfraSupportEtc.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Nov 28, 2011 at 08:54:09AM -0600, Greg Scott wrote:
> > This doesn't answer your question, but your use case is better solved
> > with proxy arp.
>
> ...But maybe there's a way to make my NIC only answer ARPs for certain IP Addresses I care about?  That would nicely solve the problem.  If it works.  

"ip neigh add proxy 1.2.3.4 dev eth0". Please look at the example i gave
you.

> In my earlier near-disaster, I did this:
> 
> echo 1 > /proc/sys/net/ipv4/conf/${INET_IFACE}/proxy_arp

NO. You do not touch this switch. Be afraid of this switch.

The instructions i gave you are complete. This switch is not involved.

> to turn on proxy arp.  I wonder if that ip neighbor stuff does it selectively?  

We already had this discussion in July.

"ip neigh add proxy" is independent of /proc/.../proxy_arp.


-David
