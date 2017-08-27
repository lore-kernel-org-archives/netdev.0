From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH 0/4] irda: move it to drivers/staging so we can delete it
Date: Sun, 27 Aug 2017 16:15:16 -0700
Message-ID: <1503875716.12569.54.camel@perches.com>
References: <20170827150334.32495-1-gregkh@linuxfoundation.org>
         <1503848143.12569.48.camel@perches.com> <20170827161307.GA3528@kroah.com>
         <1503850759.12569.50.camel@perches.com> <20170827165337.GA5769@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 8bit
Cc: davem@davemloft.net, samuel@sortiz.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, devel@driverdev.osuosl.org
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
        irda-users <irda-users@lists.sourceforge.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170827165337.GA5769@kroah.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 2017-08-27 at 18:53 +0200, Greg Kroah-Hartman wrote:
> On Sun, Aug 27, 2017 at 09:19:19AM -0700, Joe Perches wrote:
> > On Sun, 2017-08-27 at 18:13 +0200, Greg Kroah-Hartman wrote:
> > > On Sun, Aug 27, 2017 at 08:35:43AM -0700, Joe Perches wrote:
> > > > On Sun, 2017-08-27 at 17:03 +0200, Greg Kroah-Hartman wrote:
> > > > > The IRDA code has long been obsolete and broken.  So, to keep people
> > > > > from trying to use it, and to prevent people from having to maintain it,
> > > > > let's move it to drivers/staging/ so that we can delete it entirely from
> > > > > the kernel in a few releases.
> > > > 
> > > > 
> > > > MAINTAINERS should be updated as well.
> > > > 
> > > > It'd probably be nice to try to get an email to
> > > > the irda mailing list too if it still works.
> > > 
> > > As get_maintainer.pl didn't show it, odds are it doesn't...
> > 
> > get_maintainer doesn't show it because it's subscriber-only.
> > If you want get_maintainer to show it, add -s
> > 
> > $ ./scripts/get_maintainer.pl  -s -f net/irda/
> > Samuel Ortiz <samuel@sortiz.org> (maintainer:IRDA SUBSYSTEM)
> > "David S. Miller" <davem@davemloft.net> (maintainer:NETWORKING [GENERAL])
> > irda-users@lists.sourceforge.net (subscriber list:IRDA SUBSYSTEM)
> > netdev@vger.kernel.org (open list:IRDA SUBSYSTEM)
> > linux-kernel@vger.kernel.org (open list)
> 
> Sorry, am not going to subscribe to a random list just to send patches
> that delete the subsystem :)

Then you do a disservice to those that actually might
be using that subsystem.
