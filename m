From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [IPv4] Kill remnant of ip_nat_dumb
Date: Wed, 22 Sep 2004 11:09:31 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040922110931.68b113a4.davem@davemloft.net>
References: <20040922040155.GA19302@gondor.apana.org.au>
	<1095855039.1045.67.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: hadi@cyberus.ca
In-Reply-To: <1095855039.1045.67.camel@jzny.localdomain>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On 22 Sep 2004 08:10:39 -0400
jamal <hadi@cyberus.ca> wrote:

> Geez, I missed that we killed static NAT too. Whats wrong with it?
> I know at least two users of this - did we ask or 
> is posting on netdev == ask?

It's gone until someone fixes it up into working condition
once more.  It's been broken ever since the first bits
of IPSEC dst cache infrastructure went in.

The old code is in the source history if anyone wants to
resurrect it and try to get it going again, but frankly
my opinion is:

1) there are ways to do that with other technologies
   in the tree, hey even tc actions could do it (wink wink :-)

2) judging by the amount of complaints of it not working any-
   more (ie. nearly zero), I don't think it's worth spending
   time on it

But have at it if you want :-)
