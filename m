From: jamal <hadi@cyberus.ca>
Subject: Re: [net-next-2.6 PATCH 1/7] xfrm: introduce basic mark
 infrastructure
Date: Tue, 16 Feb 2010 08:16:04 -0500
Message-ID: <1266326164.6776.263.camel@bigi>
References: <1266160732-946-1-git-send-email-hadi@cyberus.ca>
	 <1266160732-946-2-git-send-email-hadi@cyberus.ca>
	 <4B796B70.2050102@trash.net> <1266253235.6776.90.camel@bigi>
	 <4B797F09.5050207@trash.net> <1266254073.6776.109.camel@bigi>
	 <m37hqdcvgm.fsf@ursa.amorsen.dk> <1266321437.6776.250.camel@bigi>
	 <m3hbphxrnm.fsf@ursa.amorsen.dk>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>, timo.teras@iki.fi,
	herbert@gondor.apana.org.au, davem@davemloft.net,
	netdev@vger.kernel.org
To: Benny Amorsen <benny+usenet@amorsen.dk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from qw-out-2122.google.com ([74.125.92.27]:18338 "EHLO
	qw-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753750Ab0BPNQH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Feb 2010 08:16:07 -0500
Received: by qw-out-2122.google.com with SMTP id 5so697085qwi.37
        for <netdev@vger.kernel.org>; Tue, 16 Feb 2010 05:16:05 -0800 (PST)
In-Reply-To: <m3hbphxrnm.fsf@ursa.amorsen.dk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2010-02-16 at 13:59 +0100, Benny Amorsen wrote:

> From your description, I would add the IPSEC SPD + SA with a specific
> mark. Then I would set the mark in the rule table if I want the packets
> to go through the tunnel, or clear the mark to have them go through
> normal routing.

yes.

> Not perfect, because I would have to replicate parts of
> the routing table in the rule table, but it could be made to work.

Agreed this is a problem and not a nice one (the counter arguement is
at least theres a way for some users now..

> Perfect would be if I could set mark in the routing table instead of the
> rule table, but sometimes perfect is the enemy of good...

This is actually an interesting idea and is not far-fetched (and would
certainly get rid of the replication problem). If i understood
correctly, you would have:
ip route add blah blah mark 0x10

and that the routing core will use the mark to (as it does for example
with ifindex) to pick the route? I like the idea for the simple fact it
will reduce immensely configuration in some cases..

cheers,
jamal



