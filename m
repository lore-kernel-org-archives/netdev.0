From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: [RFC] ip / ifconfig redesign
Date: Mon, 5 Dec 2005 09:01:00 -0500
Message-ID: <20051205140057.GC24764@tuxdriver.com>
References: <200512022253.19029.a1426z@gawab.com> <200512031646.45332.a1426z@gawab.com> <4391E4FC.1040200@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Al Boldi <a1426z@gawab.com>, netdev@vger.kernel.org,
	linux-net@vger.kernel.org
Return-path: <linux-net-owner@vger.kernel.org>
To: Ben Greear <greearb@candelatech.com>
Content-Disposition: inline
In-Reply-To: <4391E4FC.1040200@candelatech.com>
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Dec 03, 2005 at 10:33:32AM -0800, Ben Greear wrote:
> Al Boldi wrote:
> 
> >Here specifically, ip/ifconfig is implemented upside-down requiring a 
> >link/dev to exist for an address to be defined, in effect containing layer 
> >3 inside layer 2, when an address should be allowed to be defined w/o a 
> >link/dev much like an app is allowed to be defined w/o an address.
> 
> [Removed lkml from CC list]
> 
> You can add multiple virtual IP addresses to physical interfaces.  It
> makes no sense to have an IP without any association to an interface
> in my opinion.  Often, when you have multiple interfaces, you most 
> definately
> want different IPs associated specifically with particular interfaces.
> Think about redundant paths, routers, firewalls, and such.

The association between IP addresses and links is already a bit murky.
Reference the arp_announce sysctl for what I mean.  I recall Dave M.
emphasizing on at least one occassion that IP addresses belong to
the _box_, not to the link.

I think Al B.'s idea merits some consideration.  I definitely think
we blur the distinctions between L2 and L3 a bit too much in places.

Of course, patches would be helpful...

John
-- 
John W. Linville
linville@tuxdriver.com
