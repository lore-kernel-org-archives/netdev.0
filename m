From: Julian Anastasov <ja@ssi.bg>
Subject: Re: suggestion for routing code improvement
Date: Thu, 11 Apr 2002 15:58:20 +0300 (EEST)
Sender: owner-netdev@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0204111536470.2204-100000@l>
References: <Pine.GSO.4.30.0204110805460.651-100000@shell.cyberus.ca>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Robert Olsson <Robert.Olsson@data.slu.se>,
   Chris Friesen <cfriesen@nortelnetworks.com>, <netdev@oss.sgi.com>
Return-path: <owner-netdev@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
In-Reply-To: <Pine.GSO.4.30.0204110805460.651-100000@shell.cyberus.ca>
List-Id: netdev.vger.kernel.org


	Hello,

On Thu, 11 Apr 2002, jamal wrote:

> > 	Well, I now see, it is used in gated. But only in one route table
> > which is a drawback.
>
> I thought gated was capable of using at least main and local.

	Looking in the sources, main+default and after patching
with one table more

> If i am not mistaken zebra is now capable of using more tables as well.

	Last time I checked it 6 months ago and today I don't see
much progress on the web site but you can be right :)

> It would probably be actually better policy to enter all static routes in
> one table.

	It is not always possible, all we are using Advanced Linux
Networking, though :)

> Robert, when you enter a static route from gated, is it registered as
> proto gated or proto static?

	I see that gated uses many protos while Zebra uses small
number (one?). Actually, gated can use RTPROT_STATIC for its table.

> While i like Julians patch (adding no complexity, IMO) I see that the
> functionality could be very easily moved outside the kernel where you
> could also do a lot more fancy things (very complex decision making
> example: based on which devs go down, what next multihops to use etc).
> Unfortunately, it does require extra code in user space.

	Yes, we can ping indirect nexthops, do layer 7 health checks,
alter the nexthops' weights. Usually we don't demand such super
job from a routing daemon, the things are mostly "do it yourself" :)

> cheers,
> jamal

Regards

--
Julian Anastasov <ja@ssi.bg>
