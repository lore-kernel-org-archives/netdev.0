From: "Catalin(ux aka Dino) BOIE" <util@deuroconsult.ro>
Subject: RE: Do you know the TCP stack? (127.x.x.x routing)
Date: Thu, 10 Mar 2005 17:25:00 +0200 (EET)
Message-ID: <Pine.LNX.4.62.0503101721170.15067@webhosting.rdsbv.ro>
References: <B8561865DB141248943E2376D0E85215FFE3DC@DHOST001-17.DEX001.intermedia.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: dtor_core@ameritech.net, hadi@cyberus.ca,
	Henrik Nordstrom <hno@marasystems.com>,
	Martin Mares <mj@ucw.cz>, Zdenek Radouch <zdenek@rcn.com>,
	Eran Mann <emann@mrv.com>, Thomas Graf <tgraf@suug.ch>,
	Andi Kleen <ak@muc.de>, netdev@oss.sgi.com,
	linux-net@vger.kernel.org
To: Steve Iribarne <steve.iribarne@dilithiumnetworks.com>
In-Reply-To: <B8561865DB141248943E2376D0E85215FFE3DC@DHOST001-17.DEX001.intermedia.net>
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> -> This assumes that the client did not apply the same hack you did.

:) Exactly!

> They wouldn't do it on the same machine or system. I control my internal
> system.  It's an embedded system which means I have complete control.
> If they applied it somewhere else on the network, I wouldn't receive any
> of those packets because the router would drop it and my patch drops the
> 127.xxx rcv'd packets if not received on the proper VLAN and my system
> doesn't accept tagged packets from the outside world.
>
> I don't think I'm the only one who has done this.  As a matter of fact,
> I KNOW I'm not.  When I worked on BSD years ago (10+), I worked for a
> company who did the same sort of hack.

I think that the best way is to choose a 10.0.0.0/24|16|8 net and let the 
client to configure other net if it has the same net somewhere.

I agree that 127 is a lot less used that 10, but you never know.

Probably you will choose anyway 127, but I suggest to have a possibility 
the user choose another class if he wants.

---
Catalin(ux aka Dino) BOIE
catab at deuroconsult.ro
http://kernel.umbrella.ro/
