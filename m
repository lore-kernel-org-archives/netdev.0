From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] route:ip_rt_frag_needed always return unzero
Date: Wed, 19 Oct 2011 05:57:00 +0200
Message-ID: <1318996620.19139.9.camel@edumazet-laptop>
References: <1318921469-25599-1-git-send-email-gaofeng@cn.fujitsu.com>
	 <1318929797.2657.21.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <4E9E2929.7070701@cn.fujitsu.com> <4E9E36DC.4050304@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	netdev@vger.kernel.org
To: Gao feng <gaofeng@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:41365 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753625Ab1JSD5F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Oct 2011 23:57:05 -0400
Received: by wwe6 with SMTP id 6so1886729wwe.1
        for <netdev@vger.kernel.org>; Tue, 18 Oct 2011 20:57:03 -0700 (PDT)
In-Reply-To: <4E9E36DC.4050304@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 19 octobre 2011 =C3=A0 10:33 +0800, Gao feng a =C3=A9crit :

> And move atomic_inc(&__rt_peer_genid) just like func ip_rt_update_pmt=
u?
>=20
> diff --git a/net/ipv4/route.c b/net/ipv4/route.c
> index 6cde0fa..3e1aa5c 100644
> --- a/net/ipv4/route.c
> +++ b/net/ipv4/route.c
> @@ -1568,11 +1568,12 @@ unsigned short ip_rt_frag_needed(struct net *=
net, const
>                         est_mtu =3D mtu;
>                         peer->pmtu_learned =3D mtu;
>                         peer->pmtu_expires =3D pmtu_expires;
> +
> +                       atomic_inc(&__rt_peer_genid);
>                 }
>=20
>                 inet_putpeer(peer);
>=20
> -               atomic_inc(&__rt_peer_genid);
>         }
>         return est_mtu;
>  }
>=20

This one is fine, please provide a changelog and official submission.

Thanks
