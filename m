From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net/dst: dst_dev_event() called after other notifiers
Date: Wed, 10 Nov 2010 06:57:11 +0100
Message-ID: <1289368631.2700.21.camel@edumazet-laptop>
References: <4CD893C6.2030803@candelatech.com>
	 <1289331475.2774.41.camel@edumazet-laptop>
	 <20101109.114853.193732360.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: greearb@candelatech.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:39143 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751772Ab0KJF5Q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Nov 2010 00:57:16 -0500
Received: by wwb39 with SMTP id 39so324824wwb.1
        for <netdev@vger.kernel.org>; Tue, 09 Nov 2010 21:57:14 -0800 (PST)
In-Reply-To: <20101109.114853.193732360.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 09 novembre 2010 =C3=A0 11:48 -0800, David Miller a =C3=A9crit=
 :
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Tue, 09 Nov 2010 20:37:55 +0100
>=20
> > [PATCH] net/dst: dst_dev_event() called after other notifiers
>=20
> Nice, applied.
>=20
> However, I had to apply this by hand:
>=20
> >  static struct notifier_block dst_dev_notifier =3D {
> >  	.notifier_call  =3D dst_dev_event,
> > +	.priority =3D -10, /* must be called after other network notifier=
s */
> >  };
>=20
> The character after ".notifier_call" in my tree is a TAB character bu=
t
> in your patch it is a sequence of spaces.  This isn't looking like th=
e
> usual email corruption, because the leading TAB characters on these
> lines are properly there.
>=20
> Please figure out why this happened so that it doesn't repeat in
> future patches :-)
>=20

I am very sorry David, I had to run yesterday night and did a stupid
hand editing right before doing so. It was a human error, not a tool
error. Next time, I'll delay the patch to next day :)

Thanks !


