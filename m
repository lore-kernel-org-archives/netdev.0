From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [RFC] netem - add jitter support.
Date: Mon, 12 Jul 2004 08:12:39 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040712081239.21697179@dell_ss3.pdx.osdl.net>
References: <20040708135320.03366bd7@dell_ss3.pdx.osdl.net>
	<1089335650.1046.150.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@redhat.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: hadi@cyberus.ca
In-Reply-To: <1089335650.1046.150.camel@jzny.localdomain>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On 08 Jul 2004 21:14:10 -0400
jamal <hadi@cyberus.ca> wrote:

> On Thu, 2004-07-08 at 16:53, Stephen Hemminger wrote:
> > This patch adds jitter if desired to the delayed packets in the
> > netem scheduler.  I dropped the rate stuff out and reorganized so
> > that an underlying pfifo queue is used (next plan is to make it
> > have class ops).
> > 
> > The jitter is given as sigma to a Gaussian normal distribution.  The actual
> > implementation is a reduced form of the table driven stuff in NISTnet
> > (free). 
> 
> Good stuff. 
> - Is that NIST code/reference ok to put there? I have a feeling its
> non-free.

In README.License:
	As a U.S. government publication, so to speak, NIST Net is not
	copyrighted.  You can do whatever you want with it, including
	employing its code in whole or in part in any other package
	or product.  You need not credit me or NIST (though not doing
	so would be a bit rude).


> - Could that table be computed in user space instead? This way you are
> not restricted to just the normal distribution. I could also use them
> if available from within tc sources,

That wouldn't be hard, maybe even the ability to do correlated distributions.


> cheers,
> jamal
> 
