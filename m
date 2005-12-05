From: Ben Greear <greearb@candelatech.com>
Subject: Re: [RFC] ip / ifconfig redesign
Date: Mon, 05 Dec 2005 10:00:41 -0800
Message-ID: <43948049.3040508@candelatech.com>
References: <200512022253.19029.a1426z@gawab.com> <200512031646.45332.a1426z@gawab.com> <4391E4FC.1040200@candelatech.com> <20051205140057.GC24764@tuxdriver.com> <20051205174010.GA14101@buici.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Al Boldi <a1426z@gawab.com>, netdev@vger.kernel.org,
	linux-net@vger.kernel.org
Return-path: <linux-net-owner@vger.kernel.org>
To: Marc Singer <elf@buici.com>
In-Reply-To: <20051205174010.GA14101@buici.com>
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Marc Singer wrote:
> On Mon, Dec 05, 2005 at 09:01:00AM -0500, John W. Linville wrote:
> 
>>On Sat, Dec 03, 2005 at 10:33:32AM -0800, Ben Greear wrote:
>>
>>>Al Boldi wrote:
>>>
>>>
>>>>Here specifically, ip/ifconfig is implemented upside-down requiring a 
>>>>link/dev to exist for an address to be defined, in effect containing layer 
>>>>3 inside layer 2, when an address should be allowed to be defined w/o a 
>>>>link/dev much like an app is allowed to be defined w/o an address.
>>>
>>>[Removed lkml from CC list]
>>>
>>>You can add multiple virtual IP addresses to physical interfaces.  It
>>>makes no sense to have an IP without any association to an interface
>>>in my opinion.  Often, when you have multiple interfaces, you most 
>>>definately
>>>want different IPs associated specifically with particular interfaces.
>>>Think about redundant paths, routers, firewalls, and such.
>>
>>The association between IP addresses and links is already a bit murky.
>>Reference the arp_announce sysctl for what I mean.  I recall Dave M.
>>emphasizing on at least one occassion that IP addresses belong to
>>the _box_, not to the link.
>>
>>I think Al B.'s idea merits some consideration.  I definitely think
>>we blur the distinctions between L2 and L3 a bit too much in places.
>>
>>Of course, patches would be helpful...
> 
> 
> Precisely the case.  It should be the case that a box response to an
> arp on *any* interface for *any* IP address known to the box.

I certainly don't mind if this is a configurable, or even default
behaviour, but we also need the ability to only respond to particular
arps on particular interfaces, based on the IP addresses assigned
to those interfaces.  I am able to get this particular arp binding working
today, so I'm not suggesting changes, just mentioning that there are other
configurations than what you mention that are useful to people.

> As for changing the behavior, I haven't seen a compelling reason to
> change it.  IMHO, without a motivating case, we would be mucking about
> without a clear goal.

Agreed.

Thanks,
Ben


> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 


-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

