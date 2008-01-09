From: linel patrice <patnathanael@yahoo.fr>
Subject: Re : Bonding : Monitoring of 4965 wireless card
Date: Wed, 9 Jan 2008 20:44:27 +0000 (GMT)
Message-ID: <177189.1005.qm@web25711.mail.ukl.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: "John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from web25711.mail.ukl.yahoo.com ([217.12.10.53]:39009 "HELO
	web25711.mail.ukl.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1753115AbYAIUvJ convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 Jan 2008 15:51:09 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I'm doing a bonding with my eth0(e1000 driver) and my wlan
 card(iwl4965). It work like i want, when i'm in wifi the dhcp give me =
my ethernet
 adress. When i unplug the cable, my wlan card become in charge of
 network. My problem is when i disconnect the wlan card, the bonding do=
es not
 detect it correctly, and ifplugstatus show me wlan0 not connected and
 wmaster0 connected!! The bonding module does not say no active
 interface, it work like wlan is on.

Am i clear?


----- Message d'origine ----
De : John W. Linville <linville@tuxdriver.com>
=C0 : patnel972-linux@yahoo.fr
Cc : netdev@vger.kernel.org
Envoy=E9 le : Mercredi, 9 Janvier 2008, 18h02mn 05s
Objet : Re: Bonding : Monitoring of 4965 wireless card

On Wed, Jan 09, 2008 at 09:00:05AM +0000, patnel972-linux@yahoo.fr
 wrote:
> Hi,
>=20
> I want to make a bond with my wireless card. The ipw driver create
 two
>  interfaces (wlan0 and wmaster0). When i switch the rf_kill button,
>  ifplug detect wlan0 unplugged but not wmaster0. If i down wlan0
 (while
>  rf_kil ), bonding detect the inactivity when i up the interface.
>=20
> Have you some idea where is the problem? the driver or the miimon of
>  the module?
>=20
> my module parameters mode=3D1 miimon=3D100 primary eth0

I'm not sure I understand your description...what are you trying to do?
How exactly is it failing?

John
--=20
John W. Linville
linville@tuxdriver.com
--
To unsubscribe from this list: send the line "unsubscribe netdev" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html





   =20
  _____________________________________________________________________=
________=20
Ne gardez plus qu'une seule adresse mail ! Copiez vos mails vers Yahoo!
 Mail http://mail.yahoo.fr





      _________________________________________________________________=
____________=20
Ne gardez plus qu'une seule adresse mail ! Copiez vos mails vers Yahoo!=
 Mail http://mail.yahoo.fr
