From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tcp: Socket option to set congestion window
Date: Wed, 26 May 2010 15:10:14 -0700 (PDT)
Message-ID: <20100526.151014.70204145.davem@davemloft.net>
References: <87fx1e1sat.fsf@basil.nowhere.org>
	<20100526.140818.245406045.davem@davemloft.net>
	<20100526212745.GC24615@basil.fritz.box>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: therbert@google.com, shemminger@vyatta.com, netdev@vger.kernel.org,
	ycheng@google.com
To: andi@firstfloor.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42588
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753915Ab0EZWKF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 May 2010 18:10:05 -0400
In-Reply-To: <20100526212745.GC24615@basil.fritz.box>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andi Kleen <andi@firstfloor.org>
Date: Wed, 26 May 2010 23:27:45 +0200

> As I understand the idea was that the application knows
> what flows belong to a single peer and wants to have
> a single cwnd for all of those. Perhaps there would
> be a way to generalize that to tell it to the kernel.
> 
> e.g. have a "peer id"  that is known by applications
> and the kernel could manage cwnds shared between connections
> associated with the same peer id?
> 
> Just an idea, I admit I haven't thought very deeply
> about this. Feel free to poke holes into it.

Yes, a CWND "domain" that can include multiple sockets is
something that might gain some traction.

The "domain" could just simply be the tuple {process,peer-IP}
