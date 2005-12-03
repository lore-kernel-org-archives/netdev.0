From: Ben Greear <greearb@candelatech.com>
Subject: Re: [RFC] ip / ifconfig redesign
Date: Sat, 03 Dec 2005 10:33:32 -0800
Message-ID: <4391E4FC.1040200@candelatech.com>
References: <200512022253.19029.a1426z@gawab.com> <200512031646.45332.a1426z@gawab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net@vger.kernel.org
Return-path: <linux-net-owner@vger.kernel.org>
To: Al Boldi <a1426z@gawab.com>
In-Reply-To: <200512031646.45332.a1426z@gawab.com>
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Al Boldi wrote:

> Here specifically, ip/ifconfig is implemented upside-down requiring a 
> link/dev to exist for an address to be defined, in effect containing layer 3 
> inside layer 2, when an address should be allowed to be defined w/o a 
> link/dev much like an app is allowed to be defined w/o an address.

[Removed lkml from CC list]

You can add multiple virtual IP addresses to physical interfaces.  It
makes no sense to have an IP without any association to an interface
in my opinion.  Often, when you have multiple interfaces, you most definately
want different IPs associated specifically with particular interfaces.
Think about redundant paths, routers, firewalls, and such.

If you do see a benefit to your proposal, please describe how you would
use it, and why you cannot do this thing with today's code.  Philosophical
musings about the 'proper' way to do things without concrete examples is
unlikely to get you very far :)

Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

