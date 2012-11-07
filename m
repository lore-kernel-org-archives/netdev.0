From: Nolwenn <donolwenn@gmail.com>
Subject: Re: Possible bug with r8169 driver
Date: Wed, 07 Nov 2012 10:54:48 +0100
Message-ID: <6037895.4WQG8HALS9@bureau>
References: <2197741.c8FeV4Xbis@bureau> <20121001185629.GA4922@electric-eye.fr.zoreil.com> <2B85B2AE7F334F8CBC4C4A084CA849FB@realtek.com.tw>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: 'Francois Romieu' <romieu@fr.zoreil.com>, netdev@vger.kernel.org,
	'nic_swsd' <nic_swsd@realtek.com>
To: hayeswang <hayeswang@realtek.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:57554 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753914Ab2KGJy5 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Nov 2012 04:54:57 -0500
Received: by mail-ee0-f46.google.com with SMTP id b15so779845eek.19
        for <netdev@vger.kernel.org>; Wed, 07 Nov 2012 01:54:54 -0800 (PST)
In-Reply-To: <2B85B2AE7F334F8CBC4C4A084CA849FB@realtek.com.tw>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 4 octobre 2012 10:09:22 hayeswang a =C3=A9crit :
> Francois Romieu [mailto:romieu@fr.zoreil.com]
> [...]
>=20
> > diff --git a/drivers/net/ethernet/realtek/r8169.c
> > b/drivers/net/ethernet/realtek/r8169.c
> > index eb81da4..e0f1b8d 100644
> > --- a/drivers/net/ethernet/realtek/r8169.c
> > +++ b/drivers/net/ethernet/realtek/r8169.c
> > @@ -4271,8 +4271,8 @@ static void rtl_set_rx_mode(struct
> > net_device *dev)
> >=20
> >  		mc_filter[1] =3D swab32(data);
> >  =09
> >  	}
> >=20
> > -	RTL_W32(MAR0 + 4, mc_filter[1]);
> > -	RTL_W32(MAR0 + 0, mc_filter[0]);
> > +	RTL_W32(MAR0 + 4, 0xffffffff);
> > +	RTL_W32(MAR0 + 0, 0xffffffff);
> >=20
> >  	RTL_W32(RxConfig, tmp);
> > =20
> >  }
>=20
> The RTL_GIGA_MAC_VER_35 is designed without multicast hardware filter=
, so
> you should set IO 0x08 ~ 0x0f to 0xff for receiving all multicast pac=
kets
> without filtering them.
>=20

Hello,

=46ew weeks later, does I have to do something or it will be fix in the=
 next=20
kernel ?

Regards

Nolwenn
