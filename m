From: Henrik Nordstrom <hno@marasystems.com>
Subject: Re: primary and secondary ip addresses
Date: Fri, 17 Dec 2004 20:17:07 +0100 (CET)
Message-ID: <Pine.LNX.4.61.0412172011460.18385@filer.marasystems.com>
References: <41912F7A.6000408@redhat.com> <200412161153.51251.hasso@estpak.ee>
 <Pine.LNX.4.61.0412161103320.30452@filer.marasystems.com>
 <200412161302.42357.hasso@estpak.ee> <41C2F6E5.5010607@cs.columbia.edu>
 <Pine.LNX.4.61.0412171621200.15793@filer.marasystems.com>
 <41C30212.6000906@cs.columbia.edu> <Pine.LNX.4.61.0412171736210.17463@filer.marasystems.com>
 <41C314BC.3060507@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: Hasso Tepper <hasso@estpak.ee>,
	Harald Welte <laforge@gnumonks.org>,
	Neil Horman <nhorman@redhat.com>, linux-net@vger.kernel.org,
	netdev@oss.sgi.com
Return-path: <linux-net-owner@vger.kernel.org>
To: Andrea G Forte <andreaf@cs.columbia.edu>
In-Reply-To: <41C314BC.3060507@cs.columbia.edu>
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 17 Dec 2004, Andrea G Forte wrote:

> Well, when I assign a new IP (for a new subnet) to the same interface (using 
> ip route add...),  even though the routing table is updated, it still takes 
> about 500ms for the change to happen. This new IP should be detected as 
> primary, right?

If it is on a new subnet yes.

> Also, am I right to say that any IP address assigned to an 
> alias interface is a secondary IP?

It is irrelevant if you label the address or not. The "alias" labels are 
just a compatibility layer to work with old userspace programs (mainly 
ifconfig), not interfaces of their own.

See /sbin/ip addr for all the details.

Regards
Henrik

