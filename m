From: =?iso-8859-15?q?Lothar_Wa=DFmann?= <LW@KARO-electronics.de>
Subject: Re: use after free bug in socket code
Date: Tue, 14 Jul 2009 17:18:04 +0200
Message-ID: <19036.41388.634723.358236@ipc1.ka-ro>
References: <19028.16049.907160.45293@ipc1.ka-ro>
	<20090709154533.GA27413@gondor.apana.org.au>
	<19035.23045.386506.297464@ipc1.ka-ro>
	<4A5B730B.8090902@hartkopp.net>
	<19036.9400.263297.330963@ipc1.ka-ro>
	<4A5C990E.3080703@hartkopp.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Herbert Xu <herbert@gondor.apana.org.au>, davem@davemloft.net,
	netdev@vger.kernel.org, urs.thuermann@volkswagen.de,
	Urs Thuermann <urs@isnogud.escape.de>
To: Oliver Hartkopp <oliver@hartkopp.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.karo-electronics.de ([81.173.242.67]:51817 "EHLO
	mail.karo-electronics.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753351AbZGNPSM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Jul 2009 11:18:12 -0400
In-Reply-To: <4A5C990E.3080703@hartkopp.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Oliver Hartkopp writes:
> > The situation where this triggers a bug is when the chip driver's
> > hard_start_xmit function returns a NETDEV_TX_BUSY and subsequently =
the
> > can interface is deconfigured.
> >=20
> > Maybe you could try this on different hardware?
>=20
> Will do when i'm back at work ;-)
>=20
Should I wait for the results of your tests before submitting the
patches?


Lothar Wa=DFmann
--=20
___________________________________________________________

Ka-Ro electronics GmbH | Pascalstra=DFe 22 | D - 52076 Aachen
Phone: +49 2408 1402-0 | Fax: +49 2408 1402-10
Gesch=E4ftsf=FChrer: Matthias Kaussen
Handelsregistereintrag: Amtsgericht Aachen, HRB 4996

www.karo-electronics.de | info@karo-electronics.de
___________________________________________________________
