From: David Miller <davem@davemloft.net>
Subject: Re: [PULL REQUEST] net-fixes: IXP4xx
Date: Sat, 09 May 2009 13:21:03 -0700 (PDT)
Message-ID: <20090509.132103.121299319.davem@davemloft.net>
References: <m33abeupx3.fsf@intrepid.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: khc@pm.waw.pl
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59846
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754822AbZEIUVH convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 9 May 2009 16:21:07 -0400
In-Reply-To: <m33abeupx3.fsf@intrepid.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Krzysztof Halasa <khc@pm.waw.pl>
Date: Sat, 09 May 2009 19:50:00 +0200

> The following changes since commit be8be9eccbf2d908a7e56b3f7a71105cd8=
8da06b:
>   Simon Horman (1):
>         ipvs: Fix IPv4 FWMARK virtual services
>=20
> are available in the git repository at:
>=20
>   git://git.kernel.org/pub/scm/linux/kernel/git/chris/linux-2.6.git n=
et-fixes
>=20
> Krzysztof Ha=B3asa (2):
>       IXP4xx: use "ENODEV" instead of "ENOSYS" in module initializati=
on.
>          (now modutils don't complain about missing module support, s=
ame
>          as c101 and n2 changes months ago).
>=20
>       IXP4xx: complete Ethernet netdev setup before calling
>          register_netdev() (recently spotted by Lubomir Rintel and
>          Andreas Mohr).
>=20
>  arch/arm/mach-ixp4xx/ixp4xx_npe.c |    2 +-
>  drivers/net/arm/ixp4xx_eth.c      |   31 ++++++++++++++++-----------=
----
>  drivers/net/wan/ixp4xx_hss.c      |    4 ++--
>  3 files changed, 19 insertions(+), 18 deletions(-)

Pulled, thanks!
