From: Mikael Abrahamsson <swmike@swm.pp.se>
Subject: Re: Fwd: PROBLEM: IPv6 Duplicate Address Detection with non RFC-conform
 ICMPv6 packets
Date: Sat, 7 May 2011 16:21:32 +0200 (CEST)
Message-ID: <alpine.DEB.2.00.1105071619100.20305@uplift.swm.pp.se>
References: <4DC54157.9010306@computer.org>  <1304773802.2821.1214.camel@edumazet-laptop>  <dc9a790de083b31ff85c0b9578c980e7@mail.insa-lyon.fr> <1304774758.2821.1237.camel@edumazet-laptop> <842648e0f4a8c6f7cd8a47cd6916a939@mail.insa-lyon.fr>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Jan Ceuleers <jan.ceuleers@computer.org>,
	netdev@vger.kernel.org
To: Gervais Arthur <arthur.gervais@insa-lyon.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from swm.pp.se ([212.247.200.143]:36843 "EHLO uplift.swm.pp.se"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755145Ab1EGOVe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 7 May 2011 10:21:34 -0400
In-Reply-To: <842648e0f4a8c6f7cd8a47cd6916a939@mail.insa-lyon.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 7 May 2011, Gervais Arthur wrote:

> If the network administrator is using some IDS like NDPMon 
> (http://ndpmon.sourceforge.net/) to detect a DAD DoS attacks, and the 
> attacker changes the MAC address like I described, it will not detect 
> the DAD DoS attack anymore (because the victim itself claims already 
> having the IPv6 address).

If the network admin allows anyone to source any packet then they're 
already screwed. Networks need IETF SAVI-WG functionality to secure their 
network, if spoofing is allowed it's already too late.

The earlier network admins realise this and stop just trying to monitor 
the problem, the better.

-- 
Mikael Abrahamsson    email: swmike@swm.pp.se
