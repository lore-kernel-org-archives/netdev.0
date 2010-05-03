From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] IPv4: unresolved multicast route cleanup
Date: Mon, 03 May 2010 15:41:28 -0700 (PDT)
Message-ID: <20100503.154128.10559786.davem@davemloft.net>
References: <4BDE9BCB.8040803@indakom.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: andreas.meissner@indakom.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49458
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757110Ab0ECWlV convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 3 May 2010 18:41:21 -0400
In-Reply-To: <4BDE9BCB.8040803@indakom.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Andreas Mei=DFner <andreas.meissner@indakom.de>
Date: Mon, 03 May 2010 11:47:55 +0200

> --- net/ipv4/ipmr.c.orig    2010-05-03 10:55:06.000000000 +0200
> +++ net/ipv4/ipmr.c    2010-05-03 10:58:30.000000000 +0200
> @@ -753,7 +753,8 @@ ipmr_cache_unresolved(struct net *net, v
>         c->next =3D mfc_unres_queue;
>         mfc_unres_queue =3D c;
>=20
> -        mod_timer(&ipmr_expire_timer, c->mfc_un.unres.expires);
> +        if (atomic_read(&net->ipv4.cache_resolve_queue_len) =3D=3D 1=
)
> +            mod_timer(&ipmr_expire_timer, c->mfc_un.unres.expires);
>     }

Your email client has corrupted tabs into space characters, and
the new code in your patch is not indented properly.

Please read Documentation/SubmittingPatches and
Documentation/email-clients.txt for help.

Thanks.
