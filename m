From: Jamal Hadi <hadi@shell.cyberus.ca>
Subject: Re: [PATCH, untested] Support for PPPOE on SMP
Date: Fri, 27 Jun 2003 22:21:21 -0400 (EDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030627213846.V90398@shell.cyberus.ca>
References: <20030625.143334.85380461.davem@redhat.com>
 <20030626035824.D68B62C147@lists.samba.org> <20030625.205941.41631020.davem@redhat.com>
 <16122.53298.150512.793074@h006008986325.ne.client2.attbi.com>
 <20030626190407.S87648@shell.cyberus.ca> <16124.11495.374998.153330@h006008986325.ne.client2.attbi.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "David S. Miller" <davem@redhat.com>, rusty@rustcorp.com.au,
   paulus@samba.org, netdev@oss.sgi.com, fcusack@samba.org
Return-path: <netdev-bounce@oss.sgi.com>
To: James Carlson <carlson@workingcode.com>
In-Reply-To: <16124.11495.374998.153330@h006008986325.ne.client2.attbi.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



On Fri, 27 Jun 2003, James Carlson wrote:

> Jamal Hadi writes:
> > So what about packet being loss? Wouldnt that ensure reordering?
>
> Please explain.  What pattern of loss possibly results in one packet
> being inserted in the stream ahead of another?
>
> Here's loss:		1 2 4 5 6
>
> Here's reordering:	1 2 4 3 5 6
>
> Loss preserves ordering.  To get misordering, you have to
> intentionally hold onto a message and reinsert it later.  What I've

And thats what i was implying.
In your above example:

1 2 4 5 6
If the entity above the wire cared about packet 3 there will be a
retransmit. so it becomes:

1 2 4 5 6 3

I suppose if you can ensure ordering with a retransmit by having a window
of size 1 clocked by ACKs.


cheers,
jamal
