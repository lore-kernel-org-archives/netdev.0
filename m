From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH] Clean up fib_hash datastructures
Date: 21 Sep 2004 23:10:38 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1095822637.1048.23.camel@jzny.localdomain>
References: <20040918203319.24004d6e.davem@davemloft.net>
	 <1095645106.1048.190.camel@jzny.localdomain>
	 <20040919195351.0b3560e6.davem@davemloft.net>
	 <1095686672.1049.301.camel@jzny.localdomain>
	 <20040920121123.70baf895.davem@davemloft.net>
	 <20040921034212.GA28462@gondor.apana.org.au>
	 <20040920231805.3f18479c.davem@davemloft.net>
	 <20040921090423.GE8058@wotan.suse.de>
	 <20040921093252.GA32545@gondor.apana.org.au>
	 <1095764621.1049.14.camel@jzny.localdomain>
	 <1095809938.2340.19.camel@localhost.localdomain>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Steve Blake <slblake@petri-meat.com>
In-Reply-To: <1095809938.2340.19.camel@localhost.localdomain>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 2004-09-21 at 19:38, Steven Blake wrote:

> RFC 1812 was written before TOS routes were pulled out of OSPFv2 (due to
> too fee independent implementations).  No one implements FIB lookup as
> described in RFC 1812 in the core.  What people do implement is PBR, as
> well as DSCP-based nexthop selection for MPLS DIFF-TE (RFC 3564).

What about edge? 
The PBR nh selection is a post routing policy though. Do you see it 
valuable to have DSCP replace TOS for lookup? 

cheers,
jamal
