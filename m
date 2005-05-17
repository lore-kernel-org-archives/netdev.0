From: Andi Kleen <ak@muc.de>
Subject: Re: [RFC/PATCH] "strict" ipv4 reassembly
Date: 17 May 2005 22:27:30 +0200
Message-ID: <20050517202730.GA79960@muc.de>
References: <m1sm0l7jcl.fsf@muc.de> <OF0221F508.AD091D99-ON88257004.006D0C52-88257004.006D8293@us.ibm.com> <m1k6lx7gkf.fsf@muc.de> <20050517.132202.59028935.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: dlstevens@us.ibm.com, akepner@sgi.com, jheffner@psc.edu,
        netdev@oss.sgi.com, netdev-bounce@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
Date: Tue, 17 May 2005 22:27:30 +0200
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20050517.132202.59028935.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, May 17, 2005 at 01:22:02PM -0700, David S. Miller wrote:
> From: Andi Kleen <ak@muc.de>
> Date: Tue, 17 May 2005 22:17:36 +0200
> 
> > At least for a directly connected flat network you could get it from ARP.
> 
> So we can make this host based, and store that "arp RTT" thing in the
> inetpeer cache.  :-)

Arghl, you said the "i" word....
Anyways, I think the neighbour cache is fully appropiate, is it not?

But it's not clear such a hack would be worth it anyways. 
If anything it would be probably better to let mountd set the RTTs, e.g. 
implicitely with MSG_CONFIRM (I hope it is using it these days ...) 

-Andi
