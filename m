From: Julian Anastasov <ja@ssi.bg>
Subject: Re: suggestion for routing code improvement
Date: Thu, 11 Apr 2002 16:06:58 +0300 (EEST)
Sender: owner-netdev@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0204111602001.29371-100000@l>
References: <15541.35087.61146.809057@robur.slu.se>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Chris Friesen <cfriesen@nortelnetworks.com>, <netdev@oss.sgi.com>
Return-path: <owner-netdev@oss.sgi.com>
To: Robert Olsson <Robert.Olsson@data.slu.se>
In-Reply-To: <15541.35087.61146.809057@robur.slu.se>
List-Id: netdev.vger.kernel.org


	Hello,

On Thu, 11 Apr 2002, Robert Olsson wrote:

>  Well we can be happy for the well-designed routing/netlink system Linux
>  got and as you say routing software does not yet fully utilize this.
>  But I think we agree that we shouldn't have kernel to compensate for this.

	Agreed. We are not trying to insert routing daemon into kernel :)

>  I did some benchmarking/profiling on the routing lookup/cache/garbage
>  collection it seems to be well done too. Having listened to all fuzz
>  about routing lookups at GIGE speeds. :-)

	If you use another hash function for the route cache you can
even get better :) In my tests with many hosts i got 8% increase in
performance.

>  Cheers.
>
> 						--ro

Regards

--
Julian Anastasov <ja@ssi.bg>
