From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tcp: Socket option to set congestion window
Date: Wed, 26 May 2010 20:04:43 -0700 (PDT)
Message-ID: <20100526.200443.232751390.davem@davemloft.net>
References: <20100526212745.GC24615@basil.fritz.box>
	<20100526.151014.70204145.davem@davemloft.net>
	<20100526231512.GD2684@nuttenaction>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: andi@firstfloor.org, therbert@google.com, shemminger@vyatta.com,
	netdev@vger.kernel.org, ycheng@google.com
To: hagen@jauu.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38030
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757566Ab0E0DEe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 May 2010 23:04:34 -0400
In-Reply-To: <20100526231512.GD2684@nuttenaction>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hagen Paul Pfeifer <hagen@jauu.net>
Date: Thu, 27 May 2010 01:15:12 +0200

> How can a domain defined as {process,peer-IP} fair to the 1MB
> bottleneck link?

You're asking about a network level issue in terms of what can be done
on a local end-node.

All an end-node can do is abide by congestion control rules and respond
to packet drops, as has been going on for decades.

People have basically (especially in Europe) given up on crazy crap
like RSVP and other forms of bandwidth limiting and reservation.  They
just oversubscribe their links, and increase their capacity as traffic
increases dictate.  It just isn't all that manageable to put people's
traffic into classes and control what they do on a large scale.

I'm also skeptical about those who say the fight belongs squarely at
the end nodes.  If you want to control the network traffic of the
meeting point of your dumbbell, you'll need a machine there doing RED
or traffic limiting.  End-host schemes simply aren't going to work
because I can just add more end-hosts to reintroduce the problem.

The dumbbell situation is independant of the end-node issues, that's
all I'm really saying.
