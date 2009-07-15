From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] net/can bugfix: use after free bug in can protocol
 drivers
Date: Wed, 15 Jul 2009 11:20:52 -0700 (PDT)
Message-ID: <20090715.112052.12345414.davem@davemloft.net>
References: <19036.41388.634723.358236@ipc1.ka-ro>
	<4A5CC626.8020800@grandegger.com>
	<19037.40189.520170.8242@ipc1.ka-ro>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: wg@grandegger.com, oliver@hartkopp.net,
	herbert@gondor.apana.org.au, netdev@vger.kernel.org,
	urs.thuermann@volkswagen.de, urs@isnogud.escape.de
To: LW@KARO-electronics.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34632
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932142AbZGOSUs convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 15 Jul 2009 14:20:48 -0400
In-Reply-To: <19037.40189.520170.8242@ipc1.ka-ro>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Lothar Wa=DFmann <LW@KARO-electronics.de>
Date: Wed, 15 Jul 2009 11:10:21 +0200

> Fix a use after free bug in can protocol drivers
>=20
> The release functions of the can protocol drivers lack a call to
> sock_orphan() which leads to referencing freed memory under certain
> circumstances.
>=20
> This patch fixes a bug reported here:
> https://lists.berlios.de/pipermail/socketcan-users/2009-July/000985.h=
tml
>=20
> Signed-off-by: Lothar Wassmann <LW@KARO-electronics.de>
> Acked-by: Oliver Hartkopp <oliver@hartkopp.net>

Applied.
