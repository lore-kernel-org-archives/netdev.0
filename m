From: Tom St Denis <tstdenis@elliptictech.com>
Subject: Re: IPsec AH use of ahash
Date: Sun, 20 Jan 2013 10:07:24 -0500 (EST)
Message-ID: <2012247681.93123.1358694444237.JavaMail.root@elliptictech.com>
References: <1358691094.5705.40.camel@marge.simpson.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <erdnetdev@gmail.com>,
	"Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>,
	David Miller <davem@davemloft.net>,
	steffen klassert <steffen.klassert@secunet.com>,
	herbert@gondor.apana.org.au, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, Michal Kubecek <mkubecek@suse.cz>
To: Mike Galbraith <bitbucket@online.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1358691094.5705.40.camel@marge.simpson.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

----- Original Message -----
> From: "Mike Galbraith" <bitbucket@online.de>
> To: "Tom St Denis" <tstdenis@elliptictech.com>
> Cc: "Eric Dumazet" <erdnetdev@gmail.com>, "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>, "David Miller"
> <davem@davemloft.net>, "steffen klassert" <steffen.klassert@secunet.com>, herbert@gondor.apana.org.au,
> linux-kernel@vger.kernel.org, netdev@vger.kernel.org, "Michal Kubecek" <mkubecek@suse.cz>
> Sent: Sunday, 20 January, 2013 9:11:34 AM
> Subject: Re: IPsec AH use of ahash
> 
> On Sun, 2013-01-20 at 07:55 -0500, Tom St Denis wrote:
> > 
> > ----- Original Message -----
> > > From: "Mike Galbraith" <bitbucket@online.de>
> > > To: "Tom St Denis" <tstdenis@elliptictech.com>
> > > Cc: "Eric Dumazet" <erdnetdev@gmail.com>, "Waskiewicz Jr, Peter
> > > P" <peter.p.waskiewicz.jr@intel.com>, "David Miller"
> > > <davem@davemloft.net>, "steffen klassert"
> > > <steffen.klassert@secunet.com>, herbert@gondor.apana.org.au,
> > > linux-kernel@vger.kernel.org, netdev@vger.kernel.org, "Michal
> > > Kubecek" <mkubecek@suse.cz>
> > > Sent: Sunday, 20 January, 2013 12:06:21 AM
> > > Subject: Re: IPsec AH use of ahash
> > > 
> > > On Sat, 2013-01-19 at 05:30 -0500, Tom St Denis wrote:
> > > 
> > > > For those of us who do Kernel development during business hours
> > > > it's
> > > > hard to justify the work when the path to mainline is
> > > > convoluted
> > > > and
> > > > landmined.
> > > 
> > > Sounds as though any patches you submit land on your dinner plate
> > > just
> > > like potatoes.  Hand the cook a pot of half peeled potatoes,
> > > he/she
> > > may
> > > say try again.  The result of a little extra effort is tastier
> > > taters
> > > for everybody feasting at the common table.. including you.
> > 
> > No, in reality what happened is the chef made potatos [incorrectly]
> > got busy and asked others to help out and make more potatos.  Then
> > came back and said ...
> 
> Bottom line: either you grit your teeth and try again or you don't.
> Calling the chef a big meanie doesn't put taters on dinner plates.

One point you're missing is that *I* have CMAC support.  *YOU* don't.  So being contrary and adversarial about it isn't really hurting me, it's annoying me because I have to manually supply a patch for my users but at the end of the day it isn't me who is losing out.  It seems odd that the maintainers who should be happy to receive original content which adds standards support are so ardent that it must be done perfectly and totally unlike the code they submit (which I've already shown doesn't meet these standards).

The other point is that the system can use some working on and unless people raise concerns nothing will change.  Large swathes of kernel code don't meet these "coding standards" despite the fact that many source files that are in violation have been "worked on" long after the checkpatch script was written.

In all likelihood I will submit a revised CMAC patch but it'll take time before I can get business hours to work on it.  So instead of having a maintainer just touch it up we're all going to lose out because of pride?

Tom
