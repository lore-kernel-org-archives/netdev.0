From: "Arnaldo Carvalho de Melo" <acme@redhat.com>
Subject: Re: [PATCH net-2.6.25] Fix pcounter build error without CONFIG_SMP
Date: Mon, 26 Nov 2007 13:23:05 -0200
Message-ID: <20071126152305.GD14520@ghostprotocols.net>
References: <Pine.LNX.4.64.0711261630020.18529@kivilampi-30.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Arnaldo Carvalho de Melo <acme@redhat.com>,
	Netdev <netdev@vger.kernel.org>
To: Ilpo =?iso-8859-1?Q?J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:59489 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750875AbXKZPXZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 26 Nov 2007 10:23:25 -0500
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0711261630020.18529@kivilampi-30.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Em Mon, Nov 26, 2007 at 04:35:38PM +0200, Ilpo J=E4rvinen escreveu:
>=20
> I keep getting this build error and couldn't find anyone fixing
> it in archives. ...Maybe all net developers except me build
> just SMP kernels :-).

Thank you! UP is for sissies anyway :-P

Acked-by: Arnaldo Carvalho de Melo <acme@redhat.com>
=20
> In file included from include/net/sock.h:50,
>                  from ipc/mqueue.c:35:
> include/linux/pcounter.h: In function 'pcounter_add':
> include/linux/pcounter.h:87: error: 'struct pcounter' has no
> member named 'value'
> make[1]: *** [ipc/mqueue.o] Error 1
> make: *** [ipc] Error 2
>=20
> Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>
> ---
>  include/linux/pcounter.h |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
>=20
> diff --git a/include/linux/pcounter.h b/include/linux/pcounter.h
> index 620aade..9c4760a 100644
> --- a/include/linux/pcounter.h
> +++ b/include/linux/pcounter.h
> @@ -84,7 +84,7 @@ static inline int pcounter_getval(const struct pcou=
nter *self)
> =20
>  static inline void pcounter_add(struct pcounter *self, int inc)
>  {
> -	self->value +=3D inc;
> +	self->val +=3D inc;
>  }
> =20
>  static inline int pcounter_getval(const struct pcounter *self)
> --=20
> 1.5.0.6

