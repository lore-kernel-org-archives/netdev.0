From: Henrik Nordstrom <hno@marasystems.com>
Subject: Re: primary and secondary ip addresses
Date: Fri, 17 Dec 2004 20:48:54 +0100 (CET)
Message-ID: <Pine.LNX.4.61.0412172046320.18698@filer.marasystems.com>
References: <41912F7A.6000408@redhat.com> <200412161153.51251.hasso@estpak.ee>
 <Pine.LNX.4.61.0412161103320.30452@filer.marasystems.com>
 <200412161302.42357.hasso@estpak.ee> <41C2F6E5.5010607@cs.columbia.edu>
 <Pine.LNX.4.61.0412171621200.15793@filer.marasystems.com>
 <41C30212.6000906@cs.columbia.edu> <20041217112025.27688eb6.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: Andrea G Forte <andreaf@cs.columbia.edu>, hasso@estpak.ee,
	laforge@gnumonks.org, nhorman@redhat.com,
	linux-net@vger.kernel.org, netdev@oss.sgi.com
Return-path: <linux-net-owner@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20041217112025.27688eb6.davem@davemloft.net>
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 17 Dec 2004, David S. Miller wrote:

> By definition, a secondary IP address on an interface is not to be used 
> as a source.

But you can, but adding a route with such address as source or 
applications excplicitly binding to this source address. And it is 
highly useful to be able to use different source addresses in the same 
subnet for different purposes.

> It is the whole reason for the distinction between primary and secondary 
> IP addresses, and it is why all secondaries are deleted once the primary 
> is removed (because there are no valid source addresses to choose from 
> any longer, therefore IP valid communications are no longer possible).

Which is a false assumption in very many situations.

Regards
Henrik
