From: "Steve Iribarne" <steve.iribarne@dilithiumnetworks.com>
Subject: RE: Do you know the TCP stack? (127.x.x.x routing)
Date: Thu, 10 Mar 2005 07:04:02 -0800
Message-ID: <B8561865DB141248943E2376D0E85215FFE3DC@DHOST001-17.DEX001.intermedia.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Catalin\(ux aka Dino\) BOIE" <util@deuroconsult.ro>,
	<hadi@cyberus.ca>, "Henrik Nordstrom" <hno@marasystems.com>,
	"Martin Mares" <mj@ucw.cz>, "Zdenek Radouch" <zdenek@rcn.com>,
	"Eran Mann" <emann@mrv.com>, "Thomas Graf" <tgraf@suug.ch>,
	"Andi Kleen" <ak@muc.de>, <netdev@oss.sgi.com>,
	<linux-net@vger.kernel.org>
Content-class: urn:content-classes:message
To: <dtor_core@ameritech.net>
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


-> This assumes that the client did not apply the same hack you did.
-> 

They wouldn't do it on the same machine or system. I control my internal
system.  It's an embedded system which means I have complete control.
If they applied it somewhere else on the network, I wouldn't receive any
of those packets because the router would drop it and my patch drops the
127.xxx rcv'd packets if not received on the proper VLAN and my system
doesn't accept tagged packets from the outside world.

I don't think I'm the only one who has done this.  As a matter of fact,
I KNOW I'm not.  When I worked on BSD years ago (10+), I worked for a
company who did the same sort of hack.

-stv
