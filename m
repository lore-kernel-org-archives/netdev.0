From: jamal <hadi@cyberus.ca>
Subject: Re: IP stack question
Date: Mon, 24 Jun 2002 14:59:04 -0400 (EDT)
Sender: owner-netdev@oss.sgi.com
Message-ID: <Pine.GSO.4.30.0206241450330.13908-100000@shell.cyberus.ca>
References: <3D175B5F.5050403@candelatech.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "Bloch, Jack" <Jack.Bloch@icn.siemens.com>,
   "'netdev@oss.sgi.com'" <netdev@oss.sgi.com>
Return-path: <owner-netdev@oss.sgi.com>
To: Ben Greear <greearb@candelatech.com>
In-Reply-To: <3D175B5F.5050403@candelatech.com>
List-Id: netdev.vger.kernel.org



On Mon, 24 Jun 2002, Ben Greear wrote:

> It would not defeat the purpose of detecting at least one bad network
> link of the two.
>

Unless i misunderstood:
He seems to be trying to do a loopback test from one of his interfaces to
the network and back on another of his interfaces.

> I wonder if a ping -I eth1 255.255.255.255 would accomplish the
> goal as well?
>

This would probably cause a broadcast storm if you are doing a loopback
test ;->

Actually now that i think about it, you could probably modify ping
to do setsockopt(fd,....,SO_DONTROUTE,...) and send it out on a specific
interface. Dont know if it would work.

> I would actually like to be able to force a machine to not do local
> routing as well, and force packets out over an interface even if
> the destination is a local IP,  using source-based-routing,
> or something similar.  There is no way to do this currently?
>

Try that SO_DONTROUTE and see if solves your problem; you probably have to
bind the socket to a specific device as well;
For all that trouble, i would suggest you may just as well write a sock
packet based  app.

cheers,
jamal
