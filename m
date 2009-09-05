From: Marcel Holtmann <marcel@holtmann.org>
Subject: Re: [PATCH] netlink: silence compiler warning
Date: Sat, 05 Sep 2009 03:08:01 +0200
Message-ID: <1252112881.27694.3.camel@violet>
References: <4AA1B712.6060900@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Brian Haley <brian.haley@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from senator.holtmann.net ([87.106.208.187]:56055 "EHLO
	mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933928AbZIEBIA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Sep 2009 21:08:00 -0400
In-Reply-To: <4AA1B712.6060900@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Brian,

> CC      net/netlink/genetlink.o
> net/netlink/genetlink.c: In function =E2=80=98genl_register_mc_group=E2=
=80=99:
> net/netlink/genetlink.c:139: warning: =E2=80=98err=E2=80=99 may be us=
ed uninitialized in this function
>=20
> From following the code 'err' is initialized, but set it to zero to
> silence the warning.
>=20
> Signed-off-by: Brian Haley <brian.haley@hp.com>
> ---
>=20
> diff --git a/net/netlink/genetlink.c b/net/netlink/genetlink.c
> index 575c643..66f6ba0 100644
> --- a/net/netlink/genetlink.c
> +++ b/net/netlink/genetlink.c
> @@ -136,7 +136,7 @@ int genl_register_mc_group(struct genl_family *fa=
mily,
>  {
>  	int id;
>  	unsigned long *new_groups;
> -	int err;
> +	int err =3D 0;
> =20
>  	BUG_ON(grp->name[0] =3D=3D '\0');

can we please add the err =3D -E... where it actually is needed and not
stupidly go ahead and silence compiler warnings with err =3D 0. This ha=
s
been posted before.

Regards

Marcel


