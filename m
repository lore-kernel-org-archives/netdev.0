From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] net: reorganize sk_buff for faster
 __copy_skb_header()
Date: Sun, 28 Sep 2014 21:57:10 -0700
Message-ID: <1411966630.30721.7.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1411678046.16953.45.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1411680004.16953.57.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20140928.173759.584339934179620924.davem@davemloft.net>
	 <20140929.000611.1697245481977504922.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, amirv@mellanox.com,
	john.r.fastabend@intel.com, brouer@redhat.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f177.google.com ([209.85.192.177]:42640 "EHLO
	mail-pd0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750753AbaI2E5M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Sep 2014 00:57:12 -0400
Received: by mail-pd0-f177.google.com with SMTP id v10so14730115pde.36
        for <netdev@vger.kernel.org>; Sun, 28 Sep 2014 21:57:11 -0700 (PDT)
In-Reply-To: <20140929.000611.1697245481977504922.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2014-09-29 at 00:06 -0400, David Miller wrote:
> From: David Miller <davem@davemloft.net>
> Date: Sun, 28 Sep 2014 17:37:59 -0400 (EDT)
>=20
> > Applied, thanks!
>=20
> Eric, I had to revert.  Please enable IPVS in your build tests.
>=20
> net/ipv4/ip_output.c: In function =E2=80=98ip_copy_metadata=E2=80=99:
> net/ipv4/ip_output.c:470:4: error: =E2=80=98struct sk_buff=E2=80=99 h=
as no member named =E2=80=98ipvs_property=E2=80=99
>   to->ipvs_property =3D from->ipvs_property;
>     ^
> net/ipv4/ip_output.c:470:26: error: =E2=80=98struct sk_buff=E2=80=99 =
has no member named =E2=80=98ipvs_property=E2=80=99
>   to->ipvs_property =3D from->ipvs_property;

Ah sorry, will send a v2.

Thanks
