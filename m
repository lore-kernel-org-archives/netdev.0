From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] smsc95xx: Add module parameter to override MAC address
Date: Fri, 25 Jun 2010 11:17:22 -0700 (PDT)
Message-ID: <20100625.111722.27801210.davem@davemloft.net>
References: <4C2452ED.8020307@ti.com>
	<OF60E8D688.255F8F16-ON8025774D.002E17AA-8025774D.002FEC33@smsc.com>
	<4C24BB34.3010601@ti.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Steve.Glendinning@smsc.com, horms@verge.net.au,
	linux-omap@vger.kernel.org, netdev@vger.kernel.org,
	Ian.Saturley@smsc.com
To: s-jan@ti.com
Return-path: <linux-omap-owner@vger.kernel.org>
In-Reply-To: <4C24BB34.3010601@ti.com>
Sender: linux-omap-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sebastien Jan <s-jan@ti.com>
Date: Fri, 25 Jun 2010 16:20:36 +0200

> Hi Steve,
> 
> Thanks for your answer.
> 
> On 06/25/2010 10:43 AM, Steve.Glendinning@smsc.com wrote:
> [...]
>> I can see you have a different use case, but I don't think this specific
>> driver is the place for this logic.  I'd rather see it added to either
>> the usbnet framework or (preferably) the netdev framework so *all*
>> ethernet drivers can do this the same way.  otherwise we could end up
>> with slight variations of this code in every single driver!
> 
> I perfectly understand your concerns. Unfortunately, I will probably not be
> able to implement these changes into the netdev framework. However, I'd be 
> happy to make some tests if someone proposes such changes.

I don't think such logic belongs anywhere other than an initrd.

We have mechanisms by which to handle this already, and contrary to
what many people claim it is not at all so hard to create a custom
initrd.
