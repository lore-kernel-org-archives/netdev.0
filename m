From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v7] PPTP: PPP over IPv4 (Point-to-Point Tunneling
 Protocol)
Date: Fri, 20 Aug 2010 08:24:59 +0200
Message-ID: <1282285499.2295.2.camel@edumazet-laptop>
References: <E1Om1Q6-0005Fm-00.xeb-mail-ru@f239.mail.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Dmitry Kozlov <xeb@mail.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:39187 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750959Ab0HTGZF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Aug 2010 02:25:05 -0400
Received: by wyb32 with SMTP id 32so3183158wyb.19
        for <netdev@vger.kernel.org>; Thu, 19 Aug 2010 23:25:03 -0700 (PDT)
In-Reply-To: <E1Om1Q6-0005Fm-00.xeb-mail-ru@f239.mail.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 19 ao=C3=BBt 2010 =C3=A0 13:28 +0400, Dmitry Kozlov a =C3=A9cr=
it :
> Ang again...
> This patch contains:
> 1. pptp driver
> 2. gre demultiplexer driver for demultiplexing gre packets with diffe=
rent gre version
> so ip_gre and pptp may coexists
> 3. ip_gre modification
> 4. other stuff
>=20
> Changes from v6:
> 1. memory allocation moved to begin of module initialization
> 2. fixed coding style issues
> Thanks to Eric Dumazet.
>=20
> --
>  MAINTAINERS              |   14 +
>  drivers/net/Kconfig      |   11 +
>  drivers/net/Makefile     |    1 +
>  drivers/net/pptp.c       |  726 ++++++++++++++++++++++++++++++++++++=
++++++++++
>  include/linux/if_pppox.h |   59 +++--
>  include/net/gre.h        |   18 ++
>  net/ipv4/Kconfig         |    7 +
>  net/ipv4/Makefile        |    1 +
>  net/ipv4/gre.c           |  151 ++++++++++
>  net/ipv4/ip_gre.c        |   14 +-
>  10 files changed, 975 insertions(+), 27 deletions(-)


Seems fine to me, but you need to make a nice looking Changelog and add
your "Signed-off-by: ...." signature.

Thanks


