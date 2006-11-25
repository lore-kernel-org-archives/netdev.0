From: dean gaudet <dean@arctic.org>
Subject: gratuitous arp
Date: Sat, 25 Nov 2006 15:33:15 -0800 (PST)
Message-ID: <Pine.LNX.4.64.0611251526040.8068@twinlark.arctic.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <netdev-owner@vger.kernel.org>
Received: from twinlark.arctic.org ([207.7.145.18]:46501 "EHLO
	twinlark.arctic.org") by vger.kernel.org with ESMTP id S935212AbWKYXdQ
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 25 Nov 2006 18:33:16 -0500
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

hi...

i ran into some problems recently which would have been avoided if my box 
did a gratuitous arp as it brought up all interfaces (the router took 
forever to timeout the ARP entries for interface aliases).  so i set about 
looking to see why that wasn't happening.

i either missed it, or there's no code in the kernel to do it -- but 
that's cool, because it's easy enough to do from userland.  i'm guessing 
this is the intention.

however my debian and ubuntu boxes aren't doing grat arp and don't seem to 
have options to do it (i do know about using various other tools such as 
arping, send_arp, garp to do it manually).

before i go opening bugs with the distribution folks, could someone chime 
in as to what is the recommended approach these days?  did grat arp fall 
out of favour, or is it just a case of userland not keeping up?

thanks
-dean
