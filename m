From: jamal <hadi@cyberus.ca>
Subject: Re: SIOCADDMULTI for unicast broken
Date: Sat, 4 Jan 2003 12:43:49 -0500 (EST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030104124133.H48869@shell.cyberus.ca>
References: <Pine.LNX.4.44.0301032100340.29812-100000@beohost.scyld.com>
 <20030103224852.L48869@shell.cyberus.ca> <3E168E26.1030006@pobox.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Donald Becker <becker@scyld.com>, Ben Greear <greearb@candelatech.com>,
   "" <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <3E168E26.1030006@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



On Sat, 4 Jan 2003, Jeff Garzik wrote:

> I wonder if there are any good uses for more advanced RX filtering that
> is beginning to appear.  I could certainly imagine an interface that was
> a more generic RX filtering interface, and [just by accident] happened
> to support existing unicast and multicast rx-mode-related controls.
>
> As vendors stuff features onto cards and try to figure out where is the
> best dividing line between TCP stack acceleration and TCP stack offload,
> it seems to me that recent cards more often than not have nice RX
> filtering capabilities.  If you look at the world through GigE-colored
> glasses, the RX filtering picture gets even better.  There are some fun
> SMP implications with flexible enough RX filtering, for example.
>

Davem had some nifty ideas on this at least for TOE. I think we ought to
start looking at that direction. Anyone who is working on this please
involve me, i have some ideas (and it would avoid me stressing you
when you output code).

cheers,
jamal
