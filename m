From: Ben Greear <greearb@candelatech.com>
Subject: Re: Linville's L2 rant... -- Re: PATCH Fix bonding active-backup
 behavior for VLAN interfaces
Date: Tue, 01 Aug 2006 10:21:14 -0700
Message-ID: <44CF8D8A.5080101@candelatech.com>
References: <44CA34D0.1070507@candelatech.com> <44CA87C5.1060905@candelatech.com> <20060730.205032.130618331.davem@davemloft.net> <200607311015.40255.Christophe.Devriese@eurid.eu> <20060731123038.GA10138@tuxdriver.com> <1154396348.5170.43.camel@jzny2> <20060801120836.GA29208@tuxdriver.com> <44CF7E8B.9030407@candelatech.com> <20060801170329.GG29208@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jamal Hadi Salim <hadi@cyberus.ca>,
	Christophe Devriese <Christophe.Devriese@eurid.eu>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns2.lanforge.com ([66.165.47.211]:64725 "EHLO ns2.lanforge.com")
	by vger.kernel.org with ESMTP id S1750925AbWHARV7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Aug 2006 13:21:59 -0400
To: "John W. Linville" <linville@tuxdriver.com>
In-Reply-To: <20060801170329.GG29208@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

John W. Linville wrote:

>>>I'm just not sure that cleverness is worth the headache, especially
>>>since the most clever things usually only work by accident...
>>
>>Or, work by solid, modular design and small tweaks!
> 
> 
> Point taken.  But stashing little hacks in the networking core for
> specific virtual drivers isn't totally modular either.  And even if
> it were, "modular design" probably belongs on the list of "things
> that can be taken too far", like "everything in userland", "never
> use ioctl", and "microkernels are superior". :-)

To be honest, I'm not over-joyed to see bridging hooks included
in the VLAN code..but if that is what it takes to get bridging
and VLANs to play well and be flexible, I think it is a fair price.

It certainly wouldn't hurt to have someone take a holistic view of the
various L2 device interactions.  Just documenting current functionality
on, say, the netdev wiki would be a good first step.

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

