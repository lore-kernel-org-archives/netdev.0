From: =?iso-8859-2?Q?Micha=B3_Miros=B3aw?= <mirq-linux@rere.qmqm.pl>
Subject: Re: [PATCH] net: myri10ge: convert to hw_features
Date: Fri, 15 Apr 2011 20:47:41 +0200
Message-ID: <20110415184741.GA31337@rere.qmqm.pl>
References: <20110415145050.0D65C13A66@rere.qmqm.pl> <20110415182922.GA2458@myri.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Andrew Gallatin <gallatin@myri.com>,
	Brice Goglin <brice@myri.com>
To: Jon Mason <jon.mason@myri.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:55132 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752924Ab1DOSrm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 15 Apr 2011 14:47:42 -0400
Content-Disposition: inline
In-Reply-To: <20110415182922.GA2458@myri.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Apr 15, 2011 at 01:29:22PM -0500, Jon Mason wrote:
> On Fri, Apr 15, 2011 at 04:50:50PM +0200, Micha=B3 Miros=B3aw wrote:
> > Signed-off-by: Micha=B3 Miros=B3aw <mirq-linux@rere.qmqm.pl>
> > ---
> >  drivers/net/myri10ge/myri10ge.c |   66 +++++++--------------------=
-----------
> >  1 files changed, 12 insertions(+), 54 deletions(-)
[...]
> > -static int myri10ge_set_tso(struct net_device *netdev, u32 tso_ena=
bled)
> > -{
> > -	struct myri10ge_priv *mgp =3D netdev_priv(netdev);
> > -	u32 flags =3D mgp->features & (NETIF_F_TSO6 | NETIF_F_TSO);
> > -
> > -	if (tso_enabled)
> > -		netdev->features |=3D flags;
> > -	else
> > -		netdev->features &=3D ~flags;
> > -	return 0;
> > -}
> ethtool_op_set_tso does not support TSO6.  This would remove the
> enable/disable of that feature.

Please test this. You'll see it still works.

Best Regards,
Micha=B3 Miros=B3aw
