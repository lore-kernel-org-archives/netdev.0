From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net] dql: Fix inconsistency between file mode and attr
 method.
Date: Sat, 14 Jan 2012 18:21:11 +0100
Message-ID: <1326561671.5287.27.camel@edumazet-laptop>
References: <20120115021021.1bb055da.shimoda.hiroaki@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org, therbert@google.com
To: Hiroaki SHIMODA <shimoda.hiroaki@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:41460 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755818Ab2ANRVP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 Jan 2012 12:21:15 -0500
Received: by werb13 with SMTP id b13so1113122wer.19
        for <netdev@vger.kernel.org>; Sat, 14 Jan 2012 09:21:14 -0800 (PST)
In-Reply-To: <20120115021021.1bb055da.shimoda.hiroaki@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le dimanche 15 janvier 2012 =C3=A0 02:10 +0900, Hiroaki SHIMODA a =C3=A9=
crit :
> There is no store() method for inflight attribute in the
> tx-<n>/byte_queue_limits sysfs directory.
> So remove S_IWUSR bit.
>=20
> Signed-off-by: Hiroaki SHIMODA <shimoda.hiroaki@gmail.com>
> ---
>  net/core/net-sysfs.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
>=20
> diff --git a/net/core/net-sysfs.c b/net/core/net-sysfs.c
> index f3dbd4f..a1727cd 100644
> --- a/net/core/net-sysfs.c
> +++ b/net/core/net-sysfs.c
> @@ -929,7 +929,7 @@ static ssize_t bql_show_inflight(struct netdev_qu=
eue *queue,
>  }
> =20
>  static struct netdev_queue_attribute bql_inflight_attribute =3D
> -	__ATTR(inflight, S_IRUGO | S_IWUSR, bql_show_inflight, NULL);
> +	__ATTR(inflight, S_IRUGO, bql_show_inflight, NULL);
> =20
>  #define BQL_ATTR(NAME, FIELD)						\
>  static ssize_t bql_show_ ## NAME(struct netdev_queue *queue,		\

Acked-by: Eric Dumazet <eric.dumazet@gmail.com>
