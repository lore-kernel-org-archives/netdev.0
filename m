From: jamal <hadi@cyberus.ca>
Subject: Re: Patch: Device operative state notification against 2.5.7
Date: Thu, 11 Apr 2002 07:24:06 -0400 (EDT)
Sender: owner-netdev@oss.sgi.com
Message-ID: <Pine.GSO.4.30.0204110719400.651-100000@shell.cyberus.ca>
References: <3CB2D065.A3DA60BB@isg.de>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Michael Richardson <mcr@sandelman.ottawa.on.ca>, <netdev@oss.sgi.com>
Return-path: <owner-netdev@oss.sgi.com>
To: Stefan Rompf <srompf@isg.de>
In-Reply-To: <3CB2D065.A3DA60BB@isg.de>
List-Id: netdev.vger.kernel.org



On Tue, 9 Apr 2002, Stefan Rompf wrote:

> Hi Jamal,
>
> > [discussion whether IFOP_DOWN_LOWERLAYER should send netlink messages]
> >
> > I think they should be accessible; whether you send netlink
> > advertisements everytime there is some state transition is the question.
>
> they should. For a routing daemon it is interesting to be notified when
> interfaces becomes capable or incapable of handling packets, independant
> of the reason. As long as we abstract virtual or subinterfaces as normal
> interfaces to the upper layers (which is IMHO the correct decision),
> IFOP_DOWN_LOWERLAYER must trigger a notification.

Well ... ok. Note, the user space program could maintain state
and observe when all the interfaces are down to reach the same conclusion.

Ok, Stefan, i think you should be ready to roll some code now ;->

cheers,
jamal
