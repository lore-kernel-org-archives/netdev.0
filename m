From: James Chapman <jchapman@katalix.com>
Subject: Re: Multiqueue and virtualization WAS(Re: [PATCH 3/3] NET: [SCHED]
 Qdisc changes and sch_rr added for multiqueue
Date: Fri, 06 Jul 2007 16:59:58 +0100
Message-ID: <468E66FE.9070007@katalix.com>
References: <1183215164.5165.13.camel@localhost>	 <20070630.133357.77057070.davem@davemloft.net>	 <1183466553.5159.51.camel@localhost>	 <20070703.142431.49854676.davem@davemloft.net>	 <1183515611.5174.34.camel@localhost>	 <1183707166.6005.172.camel@localhost.localdomain> <1183732755.5155.85.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Rusty Russell <rusty@rustcorp.com.au>,
	David Miller <davem@davemloft.net>, kaber@trash.net,
	peter.p.waskiewicz.jr@intel.com, netdev@vger.kernel.org,
	jeff@garzik.org, auke-jan.h.kok@intel.com
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from s36.avahost.net ([74.53.95.194]:47248 "EHLO s36.avahost.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754428AbXGFQAX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 Jul 2007 12:00:23 -0400
In-Reply-To: <1183732755.5155.85.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

jamal wrote:
> If the issue is usability of listing 1024 netdevices, i can think of
> many ways to resolve it.
> One way we can resolve the listing is with a simple tag to the netdev
> struct i could say "list netdevices for guest 0-10" etc etc.

This would be a useful feature, not only for virtualization. I've seen 
some boxes with thousands of net devices (mostly ppp, but also some 
ATM). It would be nice to be able to assign a tag to an arbitrary set of 
devices.

Does the network namespace stuff help with any of this?

-- 
James Chapman
Katalix Systems Ltd
http://www.katalix.com
Catalysts for your Embedded Linux software development

