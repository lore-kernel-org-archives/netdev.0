From: jamal <hadi@cyberus.ca>
Subject: Re: [net-next-2.6 PATCH 1/7] xfrm: introduce basic mark
 infrastructure
Date: Wed, 17 Feb 2010 06:58:25 -0500
Message-ID: <1266407905.3799.24.camel@bigi>
References: <1266160732-946-1-git-send-email-hadi@cyberus.ca>
	 <1266160732-946-2-git-send-email-hadi@cyberus.ca>
	 <4B796B70.2050102@trash.net> <1266253235.6776.90.camel@bigi>
	 <4B797F09.5050207@trash.net> <1266254073.6776.109.camel@bigi>
	 <m37hqdcvgm.fsf@ursa.amorsen.dk> <1266321437.6776.250.camel@bigi>
	 <m3hbphxrnm.fsf@ursa.amorsen.dk> <1266326164.6776.263.camel@bigi>
	 <m3635w4zg0.fsf@ursa.amorsen.dk>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>, timo.teras@iki.fi,
	herbert@gondor.apana.org.au, davem@davemloft.net,
	netdev@vger.kernel.org
To: Benny Amorsen <benny+usenet@amorsen.dk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f178.google.com ([209.85.221.178]:41424 "EHLO
	mail-qy0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756227Ab0BQL6a (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Feb 2010 06:58:30 -0500
Received: by qyk8 with SMTP id 8so1702646qyk.24
        for <netdev@vger.kernel.org>; Wed, 17 Feb 2010 03:58:28 -0800 (PST)
In-Reply-To: <m3635w4zg0.fsf@ursa.amorsen.dk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2010-02-16 at 22:56 +0100, Benny Amorsen wrote:
> jamal <hadi@cyberus.ca> writes:

> > ip route add blah blah mark 0x10
> 
> Exactly.
> 
> > and that the routing core will use the mark to (as it does for example
> > with ifindex) to pick the route? I like the idea for the simple fact it
> > will reduce immensely configuration in some cases..
> 
> It would certainly be handy for me...
> 

I would certainly be interested in adding this feature for the reasons
described above. 

An additional interesting connection would be to tie this feature to
grouping of netdevices for the purpose of multipath routing. This would
be the same as what we do currently with bindtodevice but on a group
instead of a single netdevice. It would require to also have general
purpose netdev->mark to group multiple netdevices (for this case).
The dev->mark could also be handy for other things (which have not
been efficiently solved in the past); example, i could add mark 0x10 to
all ppp* devices and then do "ip link ls mark 0x10" and it would only
fetch ppp* (or for shit-and-giggles as some New Brunswickians like to
say, ip link mark 0x10 down)

Patrick, thoughts? see anything breaking from either feature?

cheers,
jamal

