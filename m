From: Andi Kleen <ak@muc.de>
Subject: Re: [RFC/PATCH] "strict" ipv4 reassembly
Date: Tue, 17 May 2005 22:17:36 +0200
Message-ID: <m1k6lx7gkf.fsf@muc.de>
References: <m1sm0l7jcl.fsf@muc.de>
	<OF0221F508.AD091D99-ON88257004.006D0C52-88257004.006D8293@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: akepner@sgi.com, "David S. Miller" <davem@davemloft.net>,
        John Heffner <jheffner@psc.edu>, netdev@oss.sgi.com,
        netdev-bounce@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: David Stevens <dlstevens@us.ibm.com>
In-Reply-To: <OF0221F508.AD091D99-ON88257004.006D0C52-88257004.006D8293@us.ibm.com> (David
 Stevens's message of "Tue, 17 May 2005 12:56:05 -0700")
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

David Stevens <dlstevens@us.ibm.com> writes:

> Dave,
>         Shouldn't that be an estimator on the destination RTT? Or is that
> what you meant? A fast link locally that traverses a slow path along the 
> way
> would time out too fast.
>         Of course, getting an RTT estimate if there hasn't been TCP 
> traffic
> is a complication. :-)

At least for a directly connected flat network you could get it from ARP.

-Andi
