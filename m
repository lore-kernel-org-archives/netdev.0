From: Robert Olsson <Robert.Olsson@data.slu.se>
Subject: Re: suggestion for routing code improvement
Date: Thu, 11 Apr 2002 15:01:03 +0200
Sender: owner-netdev@oss.sgi.com
Message-ID: <15541.35087.61146.809057@robur.slu.se>
References: <15541.29604.537736.704406@robur.slu.se>
	<Pine.LNX.4.44.0204111451570.9056-100000@l>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Robert Olsson <Robert.Olsson@data.slu.se>,
   Chris Friesen <cfriesen@nortelnetworks.com>, <netdev@oss.sgi.com>
Return-path: <owner-netdev@oss.sgi.com>
To: Julian Anastasov <ja@ssi.bg>
In-Reply-To: <Pine.LNX.4.44.0204111451570.9056-100000@l>
List-Id: netdev.vger.kernel.org



Hello!

Julian Anastasov writes:
 > 
 > 	Well, I now see, it is used in gated. But only in one route table
 > which is a drawback.
 
 gated netlink code came from Alexey. I had to adjust the preference for 
 "static" in gated to get the desired effect.
 
 > 
 > 	More correctly, the settings are more complex than the mentioned
 > daemons can handle. Sticking with one route table is not enough in most
 > of the cases. This is the main reason the mentioned patches for static
 > routes to exist. They are more manageable (with scripts) for setups where
 > routing protocols are not used.

 Well we can be happy for the well-designed routing/netlink system Linux 
 got and as you say routing software does not yet fully utilize this. 
 But I think we agree that we shouldn't have kernel to compensate for this.

 I did some benchmarking/profiling on the routing lookup/cache/garbage 
 collection it seems to be well done too. Having listened to all fuzz 
 about routing lookups at GIGE speeds. :-)

 Cheers.

						--ro
