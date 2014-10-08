From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: randconfig build error with next-20141008, in
 drivers/net/ethernet/mellanox/mlx4/en_tx.c
Date: Wed, 08 Oct 2014 07:49:06 -0700
Message-ID: <1412779746.11091.176.camel@edumazet-glaptop2.roam.corp.google.com>
References: <CA+r1ZhiU6uzE-CQcTJoH2JxrS06H+5Paaofz+3Ugzon02mxD8Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Rothwell <sfr@canb.auug.org.au>,
	linux-next <linux-next@vger.kernel.org>,
	linux-kernel <linux-kernel@vger.kernel.org>, amirv@mellanox.com,
	netdev <netdev@vger.kernel.org>
To: Jim Davis <jim.epost@gmail.com>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <CA+r1ZhiU6uzE-CQcTJoH2JxrS06H+5Paaofz+3Ugzon02mxD8Q@mail.gmail.com>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2014-10-08 at 07:42 -0700, Jim Davis wrote:
> Building with the attached random configuration file,
>=20
> drivers/net/ethernet/mellanox/mlx4/en_tx.c: In function =E2=80=98mlx4=
_en_process_tx_cq=E2=80=99:
> drivers/net/ethernet/mellanox/mlx4/en_tx.c:395:27: error: =E2=80=98st=
ruct netdev_queue=E2=80=99
> has no member named =E2=80=98dql=E2=80=99
>   prefetchw(&ring->tx_queue->dql.limit);
>                            ^
> drivers/net/ethernet/mellanox/mlx4/en_tx.c: In function =E2=80=98mlx4=
_en_xmit=E2=80=99:
> drivers/net/ethernet/mellanox/mlx4/en_tx.c:740:27: error: =E2=80=98st=
ruct netdev_queue=E2=80=99
> has no member named =E2=80=98dql=E2=80=99
>   prefetchw(&ring->tx_queue->dql);
>                            ^
> make[5]: *** [drivers/net/ethernet/mellanox/mlx4/en_tx.o] Error 1

Thanks for the report, I'll take care of this.
