From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH][XFRM] export SPD info
Date: Sat, 28 Apr 2007 21:19:36 -0700 (PDT)
Message-ID: <20070428.211936.35015201.davem@davemloft.net>
References: <1177681421.4059.2.camel@localhost>
	<463200CC.6010207@trash.net>
	<1177684168.4059.38.camel@localhost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, netdev@vger.kernel.org
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48844
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754564AbXD2ET1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 Apr 2007 00:19:27 -0400
In-Reply-To: <1177684168.4059.38.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: jamal <hadi@cyberus.ca>
Date: Fri, 27 Apr 2007 10:29:28 -0400

> On Fri, 2007-27-04 at 15:55 +0200, Patrick McHardy wrote:
> 
> > 
> > It it really worth the extra code for dumping them conditionally?
> > The attributes are neither large nor will they be sent very often.
> > 
> 
> That thought did cross my mind when i was coding this;-> I hate the way
> netlink filters are done in user space with iproute2 - dumping 50
> objects just so i can get to one. So i used that as my guiding
> principle; i have no qualms with the few extra lines.
> Actually, I was hoping it would provide motivation for someone else to
> do a better filtering scheme (which sits in the kernel).

I think filtering in the kernel makes sense when the kernel
is in a unique place to make the algorithmic complexity of the
filtering minimal.  The TCP socket dumping is a good example
of that.

For things like this I think it's really unnecessary.

Figure out what the basic information is and just provide it every
time.  You have a full release cycle to work out what that is, and if
we miss anything, afterwards we can still extend with attributes.
