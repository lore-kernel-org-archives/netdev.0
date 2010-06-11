From: Rick Jones <rick.jones2@hp.com>
Subject: Re: Weak host model vs .interface down
Date: Fri, 11 Jun 2010 10:13:42 -0700
Message-ID: <4C126EC6.9000506@hp.com>
References: <OF1D06F11A.44DE8C5A-ONC125773F.00437856-C125773F.004425B9@transmode.se>	<4C126514.30905@hp.com> <OFE6F71D1A.A94BE06C-ONC125773F.005C80CF-C125773F.005DF884@transmode.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Joakim Tjernlund <joakim.tjernlund@transmode.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0027.austin.hp.com ([15.216.28.34]:29569 "EHLO
	g1t0027.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755495Ab0FKRNo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Jun 2010 13:13:44 -0400
In-Reply-To: <OFE6F71D1A.A94BE06C-ONC125773F.005C80CF-C125773F.005DF884@transmode.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> The weak model doesn't go into such detail, it is assumption/impl. detail
> to assume that the ip address still is part of the system even when the interface
> is down. One could just as well define interface down as temporarly removing
> the IP address from the system too. This makes make much more sense to me and
> if you always want the system to answer on a IP adress you make it an IP alias.
> 
> Since the current behaviour is a problem to me and routers in general, can
> we change this? What is the current usage model which needs it to stay as is?

Router != end-system  so I wouldn't think the weak or strong end-system model 
would apply to a router.  I think Stephen already posted a patch to allow that 
for when one's box was a router rather than an end-system.

rick jones
It's a router!
No, it's an end-system!
...
http://snltranscripts.jt.org/75/75ishimmer.phtml
