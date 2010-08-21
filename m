From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v8] PPTP: PPP over IPv4 (Point-to-Point Tunneling
 Protocol)
Date: Sat, 21 Aug 2010 09:49:23 +0200
Message-ID: <1282376963.2636.10.camel@edumazet-laptop>
References: <E1Omhkb-0005fi-00.xeb-mail-ru@f117.mail.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Dmitry Kozlov <xeb@mail.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:55311 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751385Ab0HUHt2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Aug 2010 03:49:28 -0400
Received: by wwi17 with SMTP id 17so5253011wwi.1
        for <netdev@vger.kernel.org>; Sat, 21 Aug 2010 00:49:27 -0700 (PDT)
In-Reply-To: <E1Omhkb-0005fi-00.xeb-mail-ru@f117.mail.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le samedi 21 ao=C3=BBt 2010 =C3=A0 10:40 +0400, Dmitry Kozlov a =C3=A9c=
rit :
> PPP: introduce "pptp" module which implements point-to-point tunnelin=
g protocol using pppox framework
> NET: introduce the "gre" module for demultiplexing GRE packets on ver=
sion criteria=20
>      (required to pptp and ip_gre may coexists)
> NET: ip_gre: update to use the "gre" module
>=20
> Signed-off-by: Dmitry Kozlov <xeb@mail.ru>
> ---
> This patch introduces then pptp support to the linux kernel which
> dramatically speeds up pptp vpn connections and decreases cpu usage i=
n
> comparison of existing user-space implementation (poptop/pptpclient).
> There is accel-pptp project
> (https://sourceforge.net/projects/accel-pptp/) to utilize this module=
,
> it contains plugin for pppd to use pptp in client-mode and modified
> pptpd (poptop) to build high-performance pptp NAS.
>=20
> There was many changes from initial submitted patch, most important
> are:
> 1. using rcu instead of read-write locks
> 2. using static bitmap instead of dynamically allocated
> 3. using vmalloc for memory allocation instead of BITS_PER_LONG +
> __get_free_pages
> 4. fixed many coding style issues
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

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Thanks Dmitry !



