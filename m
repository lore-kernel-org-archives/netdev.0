From: jamal <hadi@cyberus.ca>
Subject: Re: suggestion for routing code improvement
Date: Thu, 11 Apr 2002 08:18:50 -0400 (EDT)
Sender: owner-netdev@oss.sgi.com
Message-ID: <Pine.GSO.4.30.0204110805460.651-100000@shell.cyberus.ca>
References: <Pine.LNX.4.44.0204111451570.9056-100000@l>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Robert Olsson <Robert.Olsson@data.slu.se>,
   Chris Friesen <cfriesen@nortelnetworks.com>, <netdev@oss.sgi.com>
Return-path: <owner-netdev@oss.sgi.com>
To: Julian Anastasov <ja@ssi.bg>
In-Reply-To: <Pine.LNX.4.44.0204111451570.9056-100000@l>
List-Id: netdev.vger.kernel.org



On Thu, 11 Apr 2002, Julian Anastasov wrote:

>
> 	Hello,
>
> On Thu, 11 Apr 2002, Robert Olsson wrote:
>
> > There is already RTPROT_KERNEL and proto RTPROT_STATIC is way for the
> > administrator to interact with the routing daemon even if is a you say
> > that this is not currently implemented by all daemons. I have used this
> > with gated.
>
> 	Well, I now see, it is used in gated. But only in one route table
> which is a drawback.

I thought gated was capable of using at least main and local.
If i am not mistaken zebra is now capable of using more tables as well.
It would probably be actually better policy to enter all static routes in
one table.
Robert, when you enter a static route from gated, is it registered as
proto gated or proto static?
While i like Julians patch (adding no complexity, IMO) I see that the
functionality could be very easily moved outside the kernel where you
could also do a lot more fancy things (very complex decision making
example: based on which devs go down, what next multihops to use etc).
Unfortunately, it does require extra code in user space.
The question is: Would people who need this functionality be not very lazy
and actually fetch this code and compile it? ;->

cheers,
jamal
