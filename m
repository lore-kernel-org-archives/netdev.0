From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/2] AF_PACKET fanout support
Date: Tue, 05 Jul 2011 18:20:41 -0700 (PDT)
Message-ID: <20110705.182041.1392492274453963565.davem@davemloft.net>
References: <20110704.212002.1680758539791986198.davem@davemloft.net>
	<CA+mtBx_MtQGqNT6iungW7eyStpvLEGYsgXQ8=mYq_JR8jw3=DQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: victor@inliniac.net, netdev@vger.kernel.org, willemb@google.com
To: therbert@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:43838 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754498Ab1GFBUt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jul 2011 21:20:49 -0400
In-Reply-To: <CA+mtBx_MtQGqNT6iungW7eyStpvLEGYsgXQ8=mYq_JR8jw3=DQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Herbert <therbert@google.com>
Date: Tue, 5 Jul 2011 17:46:36 -0700

> Thanks for these patches!  Is it possible you could use an alternative
> term than "fanout"?  I think this may be more often associated with a
> transmit operation (e.g. multicast fanout).

I've never heard such terminology myself.

Sorry, the fanout name is staying :-)

> Also, another useful mode of steering would be to steer packets to a
> socket which was recently processed by a thread running on the same
> CPU; somewhat analogous to RFS (cc'ed WIllem Bruijn who is already
> working on this I believe).

This sounds like a good way to overload a local socket and prevent
pushing the work to lesser used sockets on other cpus.
