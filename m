From: Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
Subject: Re: [PATCH net-next 5/5] 6lowpan: remove unecessary break
Date: Fri, 25 Oct 2013 07:28:28 +0400
Message-ID: <EFDF4460-F8D0-4721-82F1-ABC3D5F75FDA@gmail.com>
References: <1382647904-11311-1-git-send-email-alex.aring@gmail.com> <1382647904-11311-6-git-send-email-alex.aring@gmail.com>
Mime-Version: 1.0 (1.0)
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "linux-zigbee-devel@lists.sourceforge.net"
	<linux-zigbee-devel@lists.sourceforge.net>,
	"werner@almesberger.net" <werner@almesberger.net>,
	"dbaryshkov@gmail.com" <dbaryshkov@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Alexander Aring <alex.aring@gmail.com>
To: Alexander Aring <alex.aring@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f48.google.com ([209.85.215.48]:49720 "EHLO
	mail-la0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755383Ab3JYD23 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Oct 2013 23:28:29 -0400
Received: by mail-la0-f48.google.com with SMTP id ev20so2554739lab.21
        for <netdev@vger.kernel.org>; Thu, 24 Oct 2013 20:28:28 -0700 (PDT)
In-Reply-To: <1382647904-11311-6-git-send-email-alex.aring@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> 25 =D0=BE=D0=BA=D1=82. 2013 =D0=B3., =D0=B2 0:51, Alexander Aring <al=
ex.aring@gmail.com> =D0=BD=D0=B0=D0=BF=D0=B8=D1=81=D0=B0=D0=BB(=D0=B0):
>=20
> Signed-off-by: Alexander Aring <alex.aring@gmail.com>
> Reviewed-by: Werner Almesberger <werner@almesberger.net>
> ---
> net/ieee802154/6lowpan.c | 1 -
> 1 file changed, 1 deletion(-)
>=20
> diff --git a/net/ieee802154/6lowpan.c b/net/ieee802154/6lowpan.c
> index e15b101..09350f1 100644
> --- a/net/ieee802154/6lowpan.c
> +++ b/net/ieee802154/6lowpan.c
> @@ -440,7 +440,6 @@ lowpan_uncompress_udp_header(struct sk_buff *skb,=
 struct udphdr *uh)
>        default:
>            pr_debug("ERROR: unknown UDP format\n");
>            goto err;
> -            break;
>        }
>=20

It's not an unnecessary, it's let say a "good coding practice" to have =
a break for every case including default.=20

>        pr_debug("uncompressed UDP ports: src =3D %d, dst =3D %d\n",
> --=20
> 1.8.4.1
>=20
