From: Julian Anastasov <ja@ssi.bg>
Subject: Re: suggestion for routing code improvement
Date: Thu, 11 Apr 2002 15:08:23 +0300 (EEST)
Sender: owner-netdev@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0204111451570.9056-100000@l>
References: <15541.29604.537736.704406@robur.slu.se>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Chris Friesen <cfriesen@nortelnetworks.com>, <netdev@oss.sgi.com>
Return-path: <owner-netdev@oss.sgi.com>
To: Robert Olsson <Robert.Olsson@data.slu.se>
In-Reply-To: <15541.29604.537736.704406@robur.slu.se>
List-Id: netdev.vger.kernel.org


	Hello,

On Thu, 11 Apr 2002, Robert Olsson wrote:

> There is already RTPROT_KERNEL and proto RTPROT_STATIC is way for the
> administrator to interact with the routing daemon even if is a you say
> that this is not currently implemented by all daemons. I have used this
> with gated.

	Well, I now see, it is used in gated. But only in one route table
which is a drawback.

> IMHO even static routes implements a routing policy from some administrator
> view and should therefore by configured, debugged etc. This job has to done
> somewhere and a userland daemon seems most adequate at least in my eyes.

	Agreed. Add to this that sometimes many such agents play with
the routes but in its own area (different tables, etc) and the things
become more complex. I still don't know for daemon that can work with
multiple routing tables in Linux, some even don't recognize the
preferred source IPs and the ip rules.

> And with the current model the "network" comes up in a clean fashion. I think
> it easier to just add the needed routes rather to check the old history and
> deal with this. Probably we need to check is address, netmask changes etc
> so the old routes will be installed in the same context.
>
> A very simple daemon for static routes would do the job we are talking about
> here and should be easy to configure through config files or just via netlink.
> And just replace it with zebra/gated/bird when the complexity requires it.

	More correctly, the settings are more complex than the mentioned
daemons can handle. Sticking with one route table is not enough in most
of the cases. This is the main reason the mentioned patches for static
routes to exist. They are more manageable (with scripts) for setups where
routing protocols are not used.

> Cheers.
>
> 						--ro

Regards

--
Julian Anastasov <ja@ssi.bg>
