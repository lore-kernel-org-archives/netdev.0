From: Robert Olsson <Robert.Olsson@data.slu.se>
Subject: Re: [BUG] overflow in net/ipv4/route.c rt_check_expire()
Date: Fri, 1 Apr 2005 17:53:02 +0200
Message-ID: <16973.28254.203492.400896@robur.slu.se>
References: <42370997.6010302@cosmosbay.com>
	<20050315103253.590c8bfc.davem@davemloft.net>
	<42380EC6.60100@cosmosbay.com>
	<20050316140915.0f6b9528.davem@davemloft.net>
	<4239E00C.4080309@cosmosbay.com>
	<20050331221352.13695124.davem@davemloft.net>
	<424D5D34.4030800@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Eric Dumazet <dada1@cosmosbay.com>
In-Reply-To: <424D5D34.4030800@cosmosbay.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


 Hello!

Eric Dumazet writes:
 > By the way I have an updated patch... surviving very serious loads.

 Did you check for performance changes too? From what I understand 
 we can add new lookup and cache miss in the fast packet path.

 > > Anyways, I think perhaps you should dynamically allocate this lock table.
 > 
 > Maybe I should make a static sizing, (replace the 256 constant by something based on MAX_CPUS) ?

 IMO we should be careful with adding new complexity the route hash.
 Also was this dynamic behavior gc_interval needed to fix the overflow?
 gc_interval is only sort of last resort timer.

						--ro
