From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [RFC/PATCH] "strict" ipv4 reassembly
Date: Tue, 17 May 2005 15:23:49 -0700
Message-ID: <428A6EF5.9080509@hp.com>
References: <20050517202730.GA79960@muc.de>	<20050517.140245.71090021.davem@davemloft.net>	<428A613F.1020303@hp.com> <20050517.151239.74747463.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev-bounce@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
In-Reply-To: <20050517.151239.74747463.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

David S.Miller wrote:
> From: Rick Jones <rick.jones2@hp.com>
> Date: Tue, 17 May 2005 14:25:19 -0700
> 
> 
>>just how much extra overhead would there be to track the interarrival time of ip 
>>datagram fragments and would that allow someone to make a guess as to how long 
>>to reasonably wait for all the fragments to arrive? (or did I miss that being 
>>shot-down already?)
> 
> 
> I spam you with fragments tightly interspaced matching a known
> shost/dhost/ID tuple, lowering your interarrival estimate.  The
> legitimate fragment source can thus never get his fragments in
> before the timer expires.
> 
> Every other one of these IP fragmentation ideas tends to have
> some DoS hole in it.

Are the holes any larger than the existing ones?  I've no idea, and perhaps the 
only answer is indeed to say "Then don't do that (fragment)!"

rick jones
