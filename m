From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: bnx2x: fix error value sign
Date: Sun, 14 Nov 2010 21:29:43 +0100
Message-ID: <1289766583.2743.144.camel@edumazet-laptop>
References: <1289765315-6028-1-git-send-email-segoon@openwall.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: kernel-janitors@vger.kernel.org,
	Eilon Greenstein <eilong@broadcom.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Vasiliy Kulikov <segoon@openwall.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1289765315-6028-1-git-send-email-segoon@openwall.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le dimanche 14 novembre 2010 =C3=A0 23:08 +0300, Vasiliy Kulikov a =C3=A9=
crit :
> bnx2x_init_one() should return negative value on error.
> By mistake it returns ENODEV instead of -ENODEV.
>=20
> Signed-off-by: Vasiliy Kulikov <segoon@openwall.com>
> ---
>  Compile tested.
>=20
>  drivers/net/bnx2x/bnx2x_main.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
>=20
> diff --git a/drivers/net/bnx2x/bnx2x_main.c b/drivers/net/bnx2x/bnx2x=
_main.c
> index 4a6f0ea..be52edc 100644
> --- a/drivers/net/bnx2x/bnx2x_main.c
> +++ b/drivers/net/bnx2x/bnx2x_main.c
> @@ -9064,7 +9064,7 @@ static int __devinit bnx2x_init_one(struct pci_=
dev *pdev,
>  	default:
>  		pr_err("Unknown board_type (%ld), aborting\n",
>  			   ent->driver_data);
> -		return ENODEV;
> +		return -ENODEV;
>  	}
> =20
>  	cid_count +=3D CNIC_CONTEXT_USE;

I remember sending same patch in the past... it was lost somehow...
