From: Jean Delvare <jdelvare@suse.de>
Subject: Re: [PATCH] isdn: disable HiSax NetJet driver on microblaze arch
Date: Mon, 22 Jun 2015 13:27:33 +0200
Message-ID: <1434972453.4568.8.camel@chaos.site>
References: <87pp4vw3ep.fsf@gmail.com>
	 <20150621.095400.890337700038231482.davem@davemloft.net>
	 <87y4jdc58w.fsf@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, isdn@linux-pingi.de,
	Chen Gang <gang.chen.5i5j@gmail.com>,
	Ralf Baechle <ralf@linux-mips.org>
To: Nicolai Stange <nicstange@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:60204 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933398AbbFVL1h (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 22 Jun 2015 07:27:37 -0400
In-Reply-To: <87y4jdc58w.fsf@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le Sunday 21 June 2015 =C3=A0 19:59 +0200, Nicolai Stange a =C3=A9crit =
:
> David Miller <davem@davemloft.net> writes:
> >> Note that endianess on microblaze is not determined through Kconfi=
g,
> >> but by means of a compiler provided CPP macro, namely __MICROBLAZE=
EL__.
> >> However, gcc defaults to big endianess on that platform.
> > Applied, but we're long overdue for an across-the-board-available
> > endianness Kconfig option that can flat out be used in these situat=
ions.
> > The current way this is handled is at best, a mess.

I fully agree.

> Thanks!
>=20
> Regarding the general Kconfig endianess symbol, I will do another pat=
ch
> based on the information of
>   git grep '_endian\.h' -- arch/
> and supply every arch with either of CONFIG_CPU_{LITTLE,BIG}_ENDIAN i=
f
> lacking.

Note that Chen Gang (Cc'd) attempted the same almost a year ago:
http://patchwork.linux-mips.org/patch/7540/
then:
http://marc.info/?t=3D140958656400002&r=3D1&w=3D2

The idea was great IMHO but it did not work out, and I can't remember
why.

--=20
Jean Delvare
SUSE L3 Support
