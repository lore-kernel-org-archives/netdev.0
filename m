From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: Re: [PATCH net-next v2 07/10] net/faraday: Read MAC address from
 chip
Date: Tue, 19 Jul 2016 20:57:53 +1000
Message-ID: <1468925873.8568.47.camel@kernel.crashing.org>
References: <1468579460-13768-1-git-send-email-gwshan@linux.vnet.ibm.com>
	 <1468579460-13768-8-git-send-email-gwshan@linux.vnet.ibm.com>
	 <063D6719AE5E284EB5DD2968C1650D6D5F4FC97F@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"joel@jms.id.au" <joel@jms.id.au>,
	"gerlitz.or@gmail.com" <gerlitz.or@gmail.com>,
	"weixue@trustnetic.com" <weixue@trustnetic.com>,
	"yuvali@mellanox.com" <yuvali@mellanox.com>,
	"alexei.starovoitov@gmail.com" <alexei.starovoitov@gmail.com>,
	"f.fainelli@gmail.com" <f.fainelli@gmail.com>
To: David Laight <David.Laight@ACULAB.COM>,
	"'Gavin Shan'" <gwshan@linux.vnet.ibm.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:43339 "EHLO gate.crashing.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752665AbcGSK6p (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Jul 2016 06:58:45 -0400
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D5F4FC97F@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2016-07-19 at 10:50 +0000, David Laight wrote:
> > +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0if (!is_valid_ether_addr(mac)) {
> > +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0mac[5] =3D (m >> 8) & 0xff;
> > +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0mac[4] =3D m & 0xff;
> > +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0mac[3] =3D (l >> 24) & 0xff;
> > +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0mac[2] =3D (l >> 16) & 0xff;
> > +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0mac[1] =3D (l >>=C2=A0 8) & 0xff;
> > +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0mac[0] =3D l & 0xff;
> > +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0}
> ...
>=20
> That is horrid, not all byte reversed addresses will be invalid.

Right, that's just a hack for a broken vendor uboot we had here, Gavin,
drop that part of the patch please.

Cheers,
Ben.
