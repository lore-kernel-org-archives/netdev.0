From: Henrik Nordstrom <hno@marasystems.com>
Subject: Re: primary and secondary ip addresses
Date: Fri, 17 Dec 2004 17:39:47 +0100 (CET)
Message-ID: <Pine.LNX.4.61.0412171736210.17463@filer.marasystems.com>
References: <41912F7A.6000408@redhat.com> <200412161153.51251.hasso@estpak.ee>
 <Pine.LNX.4.61.0412161103320.30452@filer.marasystems.com>
 <200412161302.42357.hasso@estpak.ee> <41C2F6E5.5010607@cs.columbia.edu>
 <Pine.LNX.4.61.0412171621200.15793@filer.marasystems.com>
 <41C30212.6000906@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: Hasso Tepper <hasso@estpak.ee>,
	Harald Welte <laforge@gnumonks.org>,
	Neil Horman <nhorman@redhat.com>, linux-net@vger.kernel.org,
	netdev@oss.sgi.com
Return-path: <linux-net-owner@vger.kernel.org>
To: Andrea G Forte <andreaf@cs.columbia.edu>
In-Reply-To: <41C30212.6000906@cs.columbia.edu>
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 17 Dec 2004, Andrea G Forte wrote:

> This does not help, since if I want to use my secondary IP address instead of 
> my primary, I cannot delete the primary otherwise all of my secondary IPs are 
> lost as well (and since I can only have only one primary IP address).

Why change the primary address? What is wrong with simply changing the 
route to use the other source IP?

> -If I use a secondary IP and try to invalidate the primary (i.e. by removing 
> its routing table entry), it takes about 500ms for the actual change (data 
> packets sent on the secondary IP instead of the primary) to take effect.

This is most likely the routing cache or something.

> I honestly do not understand what harm could do to have more than one primary 
> address, especially on different subnets.

How it works today is that the first IP you add in a subnet becomes a 
primary, any additional IPs you add in the same subnet becomes secondary. 
You can have any number of primary IPs with each any number of secondary 
IPs, the primary IPs just can't be in the same subnet.

Regards
Henrik

