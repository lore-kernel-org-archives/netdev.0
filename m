From: =?iso-8859-2?Q?Micha=B3_Miros=B3aw?= <mirq-linux@rere.qmqm.pl>
Subject: Re: [RFT PATCH] net: remove legacy ethtool ops
Date: Sat, 18 Jun 2011 19:15:43 +0200
Message-ID: <20110618171543.GA11090@rere.qmqm.pl>
References: <20110507114802.A0C841389B@rere.qmqm.pl>
 <BANLkTikHS0=XaVb4tutWAJTYcMLgYPzTGA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>,
	Ben Hutchings <bhutchings@solarflare.com>,
	e1000-devel@lists.sourceforge.net
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:41945 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750776Ab1FRRPp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 18 Jun 2011 13:15:45 -0400
Content-Disposition: inline
In-Reply-To: <BANLkTikHS0=XaVb4tutWAJTYcMLgYPzTGA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, May 07, 2011 at 04:58:07AM -0700, Jeff Kirsher wrote:
> 2011/5/7 Micha=B3 Miros=B3aw <mirq-linux@rere.qmqm.pl>:
> > As all drivers are converted, we may now remove discrete offload se=
tting
> > callback handling.
> >
> > Signed-off-by: Micha=B3 Miros=B3aw <mirq-linux@rere.qmqm.pl>
> > ---
> >
> > Note: This needs to wait for Intel guys to finish conversion of the=
ir
> > LAN drivers.
> >
> > =A0include/linux/ethtool.h =A0 | =A0 52 ------
> > =A0include/linux/netdevice.h | =A0 16 --
> > =A0net/8021q/vlan_dev.c =A0 =A0 =A0| =A0 =A02 +-
> > =A0net/core/dev.c =A0 =A0 =A0 =A0 =A0 =A0| =A0 13 +-
> > =A0net/core/ethtool.c =A0 =A0 =A0 =A0| =A0399 +++------------------=
------------------------
> > =A05 files changed, 28 insertions(+), 454 deletions(-)
> I do apologize for the delay, we did find several problems with the
> original set of patches you submitted during review and testing.
> Currently we have fixed up the e1000e, yet there is still work to be
> done on the other drivers.  I will make every effort to make sure tha=
t
> we complete the work over the next week.

Ping?

Best Regards,
Micha=B3 Miros=B3aw
