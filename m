From: Andrea G Forte <andreaf@cs.columbia.edu>
Subject: Re: primary and secondary ip addresses
Date: Fri, 17 Dec 2004 12:17:48 -0500
Message-ID: <41C314BC.3060507@cs.columbia.edu>
References: <41912F7A.6000408@redhat.com> <200412161153.51251.hasso@estpak.ee> <Pine.LNX.4.61.0412161103320.30452@filer.marasystems.com> <200412161302.42357.hasso@estpak.ee> <41C2F6E5.5010607@cs.columbia.edu> <Pine.LNX.4.61.0412171621200.15793@filer.marasystems.com> <41C30212.6000906@cs.columbia.edu> <Pine.LNX.4.61.0412171736210.17463@filer.marasystems.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Hasso Tepper <hasso@estpak.ee>,
	Harald Welte <laforge@gnumonks.org>,
	Neil Horman <nhorman@redhat.com>, linux-net@vger.kernel.org,
	netdev@oss.sgi.com
Return-path: <linux-net-owner@vger.kernel.org>
To: Henrik Nordstrom <hno@marasystems.com>
In-Reply-To: <Pine.LNX.4.61.0412171736210.17463@filer.marasystems.com>
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


> How it works today is that the first IP you add in a subnet becomes a 
> primary, any additional IPs you add in the same subnet becomes 
> secondary. You can have any number of primary IPs with each any number 
> of secondary IPs, the primary IPs just can't be in the same subnet.
>
Well, when I assign a new IP (for a new subnet) to the same interface 
(using ip route add...),  even though the routing table is updated, it 
still takes about 500ms for the change to happen. This new IP should be 
detected as primary, right? Also, am I right to say that any IP address 
assigned to an alias interface is a secondary IP?
Do you know where the code for the routing cache is?

Thanks for your help,
Andrea

> Regards
> Henrik


