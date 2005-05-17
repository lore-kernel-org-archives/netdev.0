From: Arthur Kepner <akepner@sgi.com>
Subject: Re: [RFC/PATCH] "strict" ipv4 reassembly
Date: Tue, 17 May 2005 11:28:05 -0700 (PDT)
Message-ID: <Pine.LNX.4.61.0505171104030.29021@linux.site>
References: <Pine.LNX.4.61.0505170914130.29021@linux.site>
 <20050517.104947.112621738.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S.Miller" <davem@davemloft.net>
In-Reply-To: <20050517.104947.112621738.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


On Tue, 17 May 2005, David S.Miller wrote:

> ....
> IP is supposed to be resilient to side effects of network
> topology, and one such common side effect is packet reordering.
> It's common, it's fine, and the networking stack deals with it
> gracefully.  Strict reassembly does not.
> 

IP was designed a looong time ago. I think it's reasonable to 
make (or at least allow for) some accomodation when networking 
bandwidths have gone up by several orders of magnitude. (And 
while we wait for IPv6 to catch on ;-) 

>
> Sure it's off by default, but isn't it a better idea
> to use NFS over TCP instead?
> 

This isn't limited to NFS, of course, though that's the 
application of most concern. I know that we have customers 
who, for good or bad reasons, _do_ use NFS over UDP. 

> Decreasing ipfrag_time is also not an option, because then
> you break fragmentation for packet radio folks :-)

Different sysctls for different folks....

--
Arthur
