From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH 3/4] [NEIGH] neighbour table configuration and statistics via rtnetlink
Date: Fri, 27 May 2005 14:15:03 +0200
Message-ID: <20050527121503.GN15391@postel.suug.ch>
References: <20050526185306.GW15391@postel.suug.ch> <20050526185526.GZ15391@postel.suug.ch> <1117192464.6688.3.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1117192464.6688.3.camel@localhost.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* jamal <1117192464.6688.3.camel@localhost.localdomain> 2005-05-27 07:14
> It would have been better, IMO, to just work on a generic idev/devinet
> retrieval and setting instead of one component (as in ARP in this
> case). 

I thought about adding a devinet component to allow retrieving/setting
device specific parameters (along with other settings) but dropped the
idea because I did not want to implement the data structures twice.

I think this is cleaner, it allows one request to be sent to see
the complete arp/ndisc configuration rather than sending one to
retrieve the global configuration/statistics and another one
to retrieve device specific parameters.

Nevertheless, I'm open for changes so once I've written the devinet
component to change rp_filter, forwarding, arp_filter, etc. we can
still move the device specific NDTA_PARMS to the devinet component
if we still think it would be better. For now, the neightbl component
is clean, small, well defined and probably never needs to be touched
again.

Is that acceptable for you?
