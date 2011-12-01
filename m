From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: net_device flags is an unsigned int
Date: Thu, 01 Dec 2011 05:48:14 +0100
Message-ID: <1322714894.2577.19.camel@edumazet-laptop>
References: <1322714077.2577.12.camel@edumazet-laptop>
	 <20111130.233918.564313369312715101.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:60394 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752296Ab1LAEsT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Nov 2011 23:48:19 -0500
Received: by eaak14 with SMTP id k14so1624685eaa.19
        for <netdev@vger.kernel.org>; Wed, 30 Nov 2011 20:48:18 -0800 (PST)
In-Reply-To: <20111130.233918.564313369312715101.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 30 novembre 2011 =C3=A0 23:39 -0500, David Miller a =C3=A9c=
rit :
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Thu, 01 Dec 2011 05:34:37 +0100
>=20
> > -	unsigned short old_flags =3D dev->flags;
> > +	typeof(dev->flags) old_flags =3D dev->flags;
>=20
> Please, create netdev_flags_t or similar, anything but this :-)

Hmm, I thought Linus hated types like this...

Or how explain we dont have jiffies_t or similar ? ;)

Other choice would be a generic macro...

int dev_set_promiscuity(struct net_device *dev, int inc)
{
DEFINE_VARIABLE(temp, dev->flags);
=2E..
}

Hmm...
