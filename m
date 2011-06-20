From: =?iso-8859-2?Q?Micha=B3_Miros=B3aw?= <mirq-linux@rere.qmqm.pl>
Subject: Re: [RESENT PATCH] net: tuntap: Fix tun_net_fix_features()
Date: Mon, 20 Jun 2011 21:44:56 +0200
Message-ID: <20110620194456.GA3231@rere.qmqm.pl>
References: <d66c8380b6c50fdcfe2dce344b39bb470a75ba3f.1308595725.git.mirq-linux@rere.qmqm.pl>
 <1308597906.2701.148.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Herbert Xu <herbert@gondor.apana.org.au>,
	"Michael S. Tsirkin" <mst@redhat.com>,
	Shan Wei <shanwei@cn.fujitsu.com>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:34319 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751035Ab1FTTo6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 20 Jun 2011 15:44:58 -0400
Content-Disposition: inline
In-Reply-To: <1308597906.2701.148.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 20, 2011 at 08:25:06PM +0100, Ben Hutchings wrote:
> On Mon, 2011-06-20 at 21:14 +0200, Micha=B3 Miros=B3aw wrote:
> > tun->set_features are meant to limit not force the features.
> >
> > Signed-off-by: Micha=B3 Miros=B3aw <mirq-linux@rere.qmqm.pl>
> > Acked-by: Michael S. Tsirkin <mst@redhat.com>
> >=20
> > ---
> >  drivers/net/tun.c |    2 +-
> >  1 files changed, 1 insertions(+), 1 deletions(-)
> >=20
> > diff --git a/drivers/net/tun.c b/drivers/net/tun.c
> > index 4dab85e..56981c2 100644
> > --- a/drivers/net/tun.c
> > +++ b/drivers/net/tun.c
> > @@ -458,7 +458,7 @@ static u32 tun_net_fix_features(struct net_devi=
ce *dev, u32 features)
> >  {
> >  	struct tun_struct *tun =3D netdev_priv(dev);
> > =20
> > -	return (features & tun->set_features) | (features & ~TUN_USER_FEA=
TURES);
> > +	return features & (tun->set_features | ~TUN_USER_FEATURES);
>=20
> (A & B) | (A & C) <=3D> A & (B | C)
>=20
> This is a cosmetic change, not a fix.  Maybe you think it is clearer =
but
> then you should say that in the commit message.

Hmm. Noise through my braincells, I suppose. Let's just drop this patch=
=2E

Best Regards,
Micha=B3 Miros=B3aw
