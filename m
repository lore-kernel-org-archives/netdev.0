From: Grant Likely <grant.likely@secretlab.ca>
Subject: Re: [PATCH] greth: Fix build after OF device conversions.
Date: Tue, 1 Jun 2010 08:46:16 -0600
Message-ID: <AANLkTilS2P5gSr2mEpPcTFjhs4YnmkFK-xSAP0zPmaL7@mail.gmail.com>
References: <20100601.001059.241461551.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gy0-f174.google.com ([209.85.160.174]:64007 "EHLO
	mail-gy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756242Ab0FAOqh convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Jun 2010 10:46:37 -0400
Received: by gye5 with SMTP id 5so1173302gye.19
        for <netdev@vger.kernel.org>; Tue, 01 Jun 2010 07:46:36 -0700 (PDT)
In-Reply-To: <20100601.001059.241461551.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 1, 2010 at 1:10 AM, David Miller <davem@davemloft.net> wrot=
e:
>
> Signed-off-by: David S. Miller <davem@davemloft.net>
> ---
>
> I've pushed this to net-2.6

Thanks David.

g.

>
> =A0drivers/net/greth.c | =A0 11 +++++------
> =A01 files changed, 5 insertions(+), 6 deletions(-)
>
> diff --git a/drivers/net/greth.c b/drivers/net/greth.c
> index f37a4c1..3a029d0 100644
> --- a/drivers/net/greth.c
> +++ b/drivers/net/greth.c
> @@ -1607,14 +1607,13 @@ static struct of_device_id greth_of_match[] =3D=
 {
> =A0MODULE_DEVICE_TABLE(of, greth_of_match);
>
> =A0static struct of_platform_driver greth_of_driver =3D {
> - =A0 =A0 =A0 .name =3D "grlib-greth",
> - =A0 =A0 =A0 .match_table =3D greth_of_match,
> + =A0 =A0 =A0 .driver =3D {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 .name =3D "grlib-greth",
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 .owner =3D THIS_MODULE,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 .of_match_table =3D greth_of_match,
> + =A0 =A0 =A0 },
> =A0 =A0 =A0 =A0.probe =3D greth_of_probe,
> =A0 =A0 =A0 =A0.remove =3D __devexit_p(greth_of_remove),
> - =A0 =A0 =A0 .driver =3D {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0.owner =3D THIS_MODULE,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0.name =3D "grlib-greth",
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0},
> =A0};
>
> =A0static int __init greth_init(void)
> --
> 1.7.0.4
>
>



--=20
Grant Likely, B.Sc., P.Eng.
Secret Lab Technologies Ltd.
