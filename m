From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 0/2] NET: Accurate packet scheduling for ATM/ADSL
Date: Tue, 20 Jun 2006 03:04:31 +0200
Message-ID: <4497499F.8040507@trash.net>
References: <1150278004.26181.35.camel@localhost.localdomain>	 <1150286766.5233.15.camel@jzny2>	 <1150289724.26181.74.camel@localhost.localdomain> <1150377383.5116.38.camel@jzny2>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Jesper Dangaard Brouer <hawk@comx.dk>,
	Stephen Hemminger <shemminger@osdl.org>,
	netdev@vger.kernel.org, lartc@mailman.ds9a.nl,
	russell-tcatm@stuart.id.au, hawk@diku.dk
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:61688 "EHLO
	stinky.trash.net") by vger.kernel.org with ESMTP id S965029AbWFTBFT
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 19 Jun 2006 21:05:19 -0400
To: hadi@cyberus.ca
In-Reply-To: <1150377383.5116.38.camel@jzny2>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

jamal wrote:
> You are still speaking ATM (and the above may still be valid), but: 
> Could you for example look at the netdevice->type and from that figure
> out the link layer overhead and compensate for it.
> Obviously a lot more useful if such activity is doable in user space
> without any knowledge of the kernel? and therefore zero change to the
> kernel and everything then becomes forward and backward compatible.

It would be nice to have support for HFSC as well, which unfortunately
needs to be done in the kernel since it doesn't use rate tables.
What about qdiscs like SFQ (which uses the packet size in quantum
calculations)? I guess it would make sense to use the wire-length
there as well.

