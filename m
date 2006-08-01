From: Jamal Hadi Salim <hadi@cyberus.ca>
Subject: Re: Linville's L2 rant... -- Re: PATCH Fix bonding active-backup
	behavior for VLAN interfaces
Date: Tue, 01 Aug 2006 08:33:34 -0400
Message-ID: <1154435614.5170.111.camel@jzny2>
References: <44CA34D0.1070507@candelatech.com>
	 <44CA87C5.1060905@candelatech.com>
	 <20060730.205032.130618331.davem@davemloft.net>
	 <200607311015.40255.Christophe.Devriese@eurid.eu>
	 <20060731123038.GA10138@tuxdriver.com> <1154396348.5170.43.camel@jzny2>
	 <20060801120836.GA29208@tuxdriver.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Christophe Devriese <Christophe.Devriese@eurid.eu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx02.cybersurf.com ([209.197.145.105]:25515 "EHLO
	mx02.cybersurf.com") by vger.kernel.org with ESMTP id S1751184AbWHAMdi
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Aug 2006 08:33:38 -0400
Received: from mail.cyberus.ca ([209.197.145.21])
	by mx02.cybersurf.com with esmtp (Exim 4.30)
	id 1G7tRM-0007ug-1r
	for netdev@vger.kernel.org; Tue, 01 Aug 2006 08:33:40 -0400
To: "John W. Linville" <linville@tuxdriver.com>
In-Reply-To: <20060801120836.GA29208@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2006-01-08 at 08:08 -0400, John W. Linville wrote:
[..]
> There is no doubt that we need to be able to do all three (vlan,
> bridge, bond) at once.  I'm just not convinced we need to support
> stacking them in every conceivable order.  

In theory there should be no issues stacking netdevices in any order
you want. In other words the hooks for doing so exist (albeit in some
limited way[1]). Practically, some of the topologies of interconnected
netdevices dont make a lot of sense. The danger is in restricting how
the stacking happens and overlooking some future creative use.
Safer to let the user own the policy and configure any way they want aka
"shoot themselves in the foot".

> And, I think that a
> reconsideration of all three functions as a group could lead to
> better/cleaner functionality with easier support for extension (e.g.
> 802.1s).

Agreed. I have some very strong opinions on this subject that i could
share with you if you want. For example, IMO, I think it would be a lot
reasonable to assume that a VLAN or VLANS are attributes of a netdevice
(just like IP addresses or MAC addresses are). 

cheers,
jamal

