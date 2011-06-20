From: =?iso-8859-2?Q?Micha=B3_Miros=B3aw?= <mirq-linux@rere.qmqm.pl>
Subject: Re: [RFT PATCH] net: remove legacy ethtool ops
Date: Mon, 20 Jun 2011 11:34:18 +0200
Message-ID: <20110620093418.GA24405@rere.qmqm.pl>
References: <20110507114802.A0C841389B@rere.qmqm.pl>
 <BANLkTikHS0=XaVb4tutWAJTYcMLgYPzTGA@mail.gmail.com>
 <20110618171543.GA11090@rere.qmqm.pl>
 <1308421191.22851.11.camel@jtkirshe-mobl>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>,
	Ben Hutchings <bhutchings@solarflare.com>,
	"e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:36347 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752955Ab1FTJeV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 20 Jun 2011 05:34:21 -0400
Content-Disposition: inline
In-Reply-To: <1308421191.22851.11.camel@jtkirshe-mobl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jun 18, 2011 at 11:19:50AM -0700, Jeff Kirsher wrote:
> On Sat, 2011-06-18 at 10:15 -0700, Micha=B3 Miros=B3aw wrote:
> > On Sat, May 07, 2011 at 04:58:07AM -0700, Jeff Kirsher wrote:
> > > 2011/5/7 Micha=B3 Miros=B3aw <mirq-linux@rere.qmqm.pl>:
> > > > As all drivers are converted, we may now remove discrete offloa=
d setting
> > > > callback handling.
> > > >
> > > > Signed-off-by: Micha=B3 Miros=B3aw <mirq-linux@rere.qmqm.pl>
> > > > ---
> > > >
> > > > Note: This needs to wait for Intel guys to finish conversion of=
 their
> > > > LAN drivers.
> > > >
> > > >  include/linux/ethtool.h   |   52 ------
> > > >  include/linux/netdevice.h |   16 --
> > > >  net/8021q/vlan_dev.c      |    2 +-
> > > >  net/core/dev.c            |   13 +-
> > > >  net/core/ethtool.c        |  399 +++--------------------------=
----------------
> > > >  5 files changed, 28 insertions(+), 454 deletions(-)
> > > I do apologize for the delay, we did find several problems with t=
he
> > > original set of patches you submitted during review and testing.
> > > Currently we have fixed up the e1000e, yet there is still work to=
 be
> > > done on the other drivers.  I will make every effort to make sure=
 that
> > > we complete the work over the next week.
> > Ping?
> I will be pushing the patches that have passed validation this weeken=
d.
> Don is still working on the ixgbe changes, I will work with him to ge=
t
> the work wrapped up early this week.

Great!

I have some more ethtool cleanups waiting after we get rid of the old
callbacks.

Best Regards,
Micha=B3 Miros=B3aw
