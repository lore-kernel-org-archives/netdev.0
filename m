From: Andi Kleen <ak@suse.de>
Subject: Re: [IPv4] Kill remnant of ip_nat_dumb
Date: Wed, 22 Sep 2004 20:14:33 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040922181433.GH27432@wotan.suse.de>
References: <20040922040155.GA19302@gondor.apana.org.au> <1095855039.1045.67.camel@jzny.localdomain> <20040922110931.68b113a4.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: hadi@cyberus.ca, herbert@gondor.apana.org.au, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20040922110931.68b113a4.davem@davemloft.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, Sep 22, 2004 at 11:09:31AM -0700, David S. Miller wrote:
> On 22 Sep 2004 08:10:39 -0400
> jamal <hadi@cyberus.ca> wrote:
> 
> > Geez, I missed that we killed static NAT too. Whats wrong with it?
> > I know at least two users of this - did we ask or 
> > is posting on netdev == ask?
> 
> It's gone until someone fixes it up into working condition
> once more.  It's been broken ever since the first bits
> of IPSEC dst cache infrastructure went in.

Also netfilter has a static NAT too these days, so it doesn't 
seem to be very useful to have another one.

-Andi
