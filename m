From: Robert Olsson <Robert.Olsson@data.slu.se>
Subject: Re: [TG3]: Add hw coalescing infrastructure.
Date: Thu, 12 May 2005 09:53:53 +0200
Message-ID: <17027.2961.116716.572730@robur.slu.se>
References: <20050511.141530.57445142.davem@davemloft.net>
	<1115846256.8570.109.camel@rh4>
	<20050511.192819.24336786.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mchan@broadcom.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20050511.192819.24336786.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


David S. Miller writes:
 > From: "Michael Chan" <mchan@broadcom.com>
 > Subject: Re: [TG3]: Add hw coalescing infrastructure.
 > Date: Wed, 11 May 2005 14:17:36 -0700

 > > Yes, and MTU size dependent too. But we may not want to coalesce the
 > > same way when running at 10/100 Mbps. For example, if one packet has
 > > arrived, we don't want to wait 120 usec or 1200 usec to see if another
 > > packet will arrive before we interrupt at 100 and 10 Mbps respectively.
 > 
 > That's a good point.  I think it would be wise for us to try
 > and come up with a dynamic mitigation algorithm that is as MTU
 > and link speed agnostic as possible.

 Size of RX-ring is also to be taken to account. You probably have to design 
 for samllest packets otherwise you risk RX-ring overrun and packet drop. 

 > One thing to note is that what we're really trying to do is
 > maximize the amount of work done per interrupt, without
 > unduly adding latency to packet reception.
 > 
 > Work done per-interrupt, and maximum latency, are better goals
 > because formulas based upon those values will automatically take
 > differences in CPU and BUS I/O speed into account.

  Yes.

  Cheers.
					--ro
 
