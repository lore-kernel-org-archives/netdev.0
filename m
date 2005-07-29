From: Robert Olsson <Robert.Olsson@data.slu.se>
Subject: Re: [PATCH] Add prefetches in net/ipv4/route.c
Date: Fri, 29 Jul 2005 19:44:42 +0200
Message-ID: <17130.27402.526238.962563@robur.slu.se>
References: <42E8FF24.9070009@cosmosbay.com>
	<20050728.123922.126777020.davem@davemloft.net>
	<42E94680.8060309@cosmosbay.com>
	<20050728.135826.63129319.davem@davemloft.net>
	<42E94D11.4090002@cosmosbay.com>
	<17130.16951.581026.863431@robur.slu.se>
	<42EA6202.703@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Rick Jones <rick.jones2@hp.com>
In-Reply-To: <42EA6202.703@hp.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Rick Jones writes:

 > >  My experiences from playing with prefetching eth_type_trans in this 
 > >  case. One must look in the total performance not just were the 
 > >  prefetching is done. In this case I was able to get eth_type_trans
 > >  down in the profile list but other functions increased so performance
 > >  was the same or lower. This needs to be sorted out... 
 > 
 > How many of the architectures have PMU's that can give us cache miss statistics? 
 >   Itanium does, and can go so far as to tell us which addresses and instructions 
 > are involved - do the others?

 I've seem XEON and Opterons has performance counters for this that can 
 be used with oprofile. Intel has a document (was it an application note?) 
 describing prefetching. Really a lot of things to consider to become 
 successful.

 > That sort of data would seem to be desirable in this sort of situation.

 Also what scenario code patch and load we optimizing for Eric mentioned 
 this briefly. 

 Cheers.
					--ro


 
