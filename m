From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 2/3] atl1c: change author
Date: Thu, 01 Mar 2012 04:27:36 -0800
Message-ID: <1330604856.2465.44.camel@edumazet-laptop>
References: <1330580469-23348-1-git-send-email-cjren@qca.qualcomm.com>
	 <1330580469-23348-3-git-send-email-cjren@qca.qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, qca-linux-team@qualcomm.com,
	nic-devel@qualcomm.com
To: Cloud Ren <cjren@qca.qualcomm.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1330580469-23348-3-git-send-email-cjren@qca.qualcomm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le jeudi 01 mars 2012 =C3=A0 13:41 +0800, Cloud Ren a =C3=A9crit :
> The author, jie yang, has left. please use nic-devel@qualcomm.com rep=
ort bugs to
> us.
>=20
> Signed-off-by: Cloud Ren <cjren@qca.qualcomm.com>
> ---
>  drivers/net/ethernet/atheros/atl1c/atl1c_main.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
>=20
> diff --git a/drivers/net/ethernet/atheros/atl1c/atl1c_main.c b/driver=
s/net/ethernet/atheros/atl1c/atl1c_main.c
> index 6bf387b..815f683 100644
> --- a/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
> +++ b/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
> @@ -52,7 +52,7 @@ static DEFINE_PCI_DEVICE_TABLE(atl1c_pci_tbl) =3D {
>  };
>  MODULE_DEVICE_TABLE(pci, atl1c_pci_tbl);
> =20
> -MODULE_AUTHOR("Jie Yang <jie.yang@atheros.com>");
> +MODULE_AUTHOR("Qualcomm Corporation, <nic-devel@qualcomm.com>");
>  MODULE_DESCRIPTION("Atheros 1000M Ethernet Network Driver");
>  MODULE_LICENSE("GPL");
> =20

Jie Yang, _is_ the original author. Thats a truth.

Why would you want to remove this line, this sounds very bad.

What you probably want is a change in MAINTAINERS file to reflect who
maintains atl1c at this moment and how to reach them by email.

Notes:

- Its also possible to add a new MODULE_AUTHOR() line

- You could remove the obsolete email address and keep Jie Yang name as
in :

MODULE_AUTHOR("Jie Yang");
