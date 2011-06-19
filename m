From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 10/11] mv643xx_eth: enable transmit time stamping.
Date: Sun, 19 Jun 2011 20:33:18 +0200
Message-ID: <1308508398.3539.80.camel@edumazet-laptop>
References: <cover.1308481491.git.richard.cochran@omicron.at>
	 <1b5632e5cd90ed390245f3d1264e42fdd760dd7e.1308481492.git.richard.cochran@omicron.at>
	 <20110619181740.GC3594@riccoc20.at.omicron.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Lennert Buytenhek <buytenh@wantstofly.org>
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:52224 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754611Ab1FSSd1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 19 Jun 2011 14:33:27 -0400
Received: by wyb38 with SMTP id 38so1230710wyb.19
        for <netdev@vger.kernel.org>; Sun, 19 Jun 2011 11:33:25 -0700 (PDT)
In-Reply-To: <20110619181740.GC3594@riccoc20.at.omicron.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le dimanche 19 juin 2011 =C3=A0 20:17 +0200, Richard Cochran a =C3=A9cr=
it :
> On Sun, Jun 19, 2011 at 01:20:06PM +0200, Richard Cochran wrote:
> > This patch enables software (and phy device) transmit time stamping=
=2E
> > Compile tested only.
> >=20
> > Cc: Lennert Buytenhek <buytenh@wantstofly.org>
> > Signed-off-by: Richard Cochran <richard.cochran@omicron.at>
> > ---
> >  drivers/net/mv643xx_eth.c |    2 ++
> >  1 files changed, 2 insertions(+), 0 deletions(-)
> >=20
> > diff --git a/drivers/net/mv643xx_eth.c b/drivers/net/mv643xx_eth.c
> > index a5d9b1c..c7a8f10 100644
> > --- a/drivers/net/mv643xx_eth.c
> > +++ b/drivers/net/mv643xx_eth.c
> > @@ -884,6 +884,8 @@ static netdev_tx_t mv643xx_eth_xmit(struct sk_b=
uff *skb, struct net_device *dev)
> >  	if (!txq_submit_skb(txq, skb)) {
> >  		int entries_left;
> > =20
> > +		skb_tx_timestamp(skb);
> > +
> >  		txq->tx_bytes +=3D skb->len;
>=20
> And the line above is unsafe, as well.
>=20

Yes, for sure, please submit patches to fix this (before adding time
stamping patches), as this should go to stable.



