From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH next] sgi-xp: Kill directly reference of netdev->priv
Date: Thu, 04 Dec 2008 15:12:58 -0800 (PST)
Message-ID: <20081204.151258.68139939.davem@davemloft.net>
References: <4937D38F.6010102@cn.fujitsu.com>
	<Pine.LNX.4.64.0812041538330.26947@wrl-59.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: wangchen@cn.fujitsu.com, netdev@vger.kernel.org
To: ilpo.jarvinen@helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51835
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754610AbYLDXM6 convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 Dec 2008 18:12:58 -0500
In-Reply-To: <Pine.LNX.4.64.0812041538330.26947@wrl-59.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: "Ilpo J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
Date: Thu, 4 Dec 2008 15:41:15 +0200 (EET)

> On Thu, 4 Dec 2008, Wang Chen wrote:
>=20
> > Simply replace netdev->priv with netdev_priv().
> >=20
> > Not do compile test, because no IA64 or x86_64 box.
> >=20
> > Signed-off-by: Wang Chen <wangchen@cn.fujitsu.com>
> > ---
> >  drivers/misc/sgi-xp/xpnet.c |    9 +++++----
> >  1 files changed, 5 insertions(+), 4 deletions(-)
> >=20
> > diff --git a/drivers/misc/sgi-xp/xpnet.c b/drivers/misc/sgi-xp/xpne=
t.c
> > index 71513b3..9e5233a 100644
> > --- a/drivers/misc/sgi-xp/xpnet.c
> > +++ b/drivers/misc/sgi-xp/xpnet.c
> > @@ -154,7 +154,7 @@ xpnet_receive(short partid, int channel, struct=
 xpnet_message *msg)
> >  	void *dst;
> >  	enum xp_retval ret;
> >  	struct xpnet_dev_private *priv =3D
> > -	    (struct xpnet_dev_private *)xpnet_device->priv;
> > +	    (struct xpnet_dev_private *)netdev_priv(xpnet_device);
>=20
> netdev_priv returns void, so these casts seem unnecessary here & othe=
r=20
> places belwo (which I cut)...

I took care of fixing this up when applying Wang's patch.

Thanks.
