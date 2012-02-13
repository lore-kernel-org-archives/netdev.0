From: Florian Fainelli <florian@openwrt.org>
Subject: Re: [PATCH 0/5] NET: PHY names vs MDIO bus names regression fixes
Date: Mon, 13 Feb 2012 23:00:27 +0100
Message-ID: <201202132300.27736.florian@openwrt.org>
References: <1329132204-27946-1-git-send-email-florian@openwrt.org> <20120213.160204.622185887026096350.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:64676 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755732Ab2BMWAf convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Feb 2012 17:00:35 -0500
Received: by wgbdt10 with SMTP id dt10so5298548wgb.1
        for <netdev@vger.kernel.org>; Mon, 13 Feb 2012 14:00:34 -0800 (PST)
In-Reply-To: <20120213.160204.622185887026096350.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 13 f=E9vrier 2012 22:02:04, David Miller a =E9crit :
> From: Florian Fainelli <florian@openwrt.org>
> Date: Mon, 13 Feb 2012 12:23:19 +0100
>=20
> > This patch serie aims at fixing the regressions introduced with the
> > "use an unique MDIO bus name" patchset. Some drivers still formatte=
d
> > the PHY id to use the old bus name (e.g: "0" or "1") and therefore
> > the PHY probing logic gets broken because their underlying MDIO bus
> > name was changed too from "0" to <foo>-<id>.
> >=20
> > The offending patches got introduced during 3.3-rc1.
>=20
> Then why the heck are you CC:'ing -stable on these patches?

There was no reason, just some bad habit.

>=20
> We're still in the 3.3-rcX phase, so there is no other tree in
> the world these patches should be applied to.
>=20
> In any event, for networking stuff, you shouldn't be adding
> the stable CC: anyways, I take care of all networking stable
> submissions myself.

Allright, do you want me to resend these without the CC or are they oka=
y as=20
is?
--=20
=46lorian
