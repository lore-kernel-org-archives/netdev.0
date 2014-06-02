From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next V6 2/2] net/mlx4_en: Use affinity hint
Date: Sun, 01 Jun 2014 21:16:50 -0700
Message-ID: <1401682610.3645.166.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1401029247-15196-1-git-send-email-amirv@mellanox.com>
	 <1401029247-15196-3-git-send-email-amirv@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Or Gerlitz <ogerlitz@mellanox.com>, netdev@vger.kernel.org,
	Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Yuval Atias <yuvala@mellanox.com>, linux-kernel@vger.kernel.org
To: Amir Vadai <amirv@mellanox.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1401029247-15196-3-git-send-email-amirv@mellanox.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 2014-05-25 at 17:47 +0300, Amir Vadai wrote:
> From: Yuval Atias <yuvala@mellanox.com>
>=20
> The =E2=80=9Caffinity hint=E2=80=9D mechanism is used by the user spa=
ce
> daemon, irqbalancer, to indicate a preferred CPU mask for irqs.
> Irqbalancer can use this hint to balance the irqs between the
> cpus indicated by the mask.
>=20
> We wish the HCA to preferentially map the IRQs it uses to numa cores
> close to it.  To accomplish this, we use cpumask_set_cpu_local_first(=
), that
> sets the affinity hint according the following policy:
> First it maps IRQs to =E2=80=9Cclose=E2=80=9D numa cores.  If these a=
re exhausted, the
> remaining IRQs are mapped to =E2=80=9Cfar=E2=80=9D numa cores.
>=20
> Signed-off-by: Yuval Atias <yuvala@mellanox.com>
> Signed-off-by: Amir Vadai <amirv@mellanox.com>
> ---

  CC [M]  drivers/net/ethernet/mellanox/mlx4/en_netdev.o
drivers/net/ethernet/mellanox/mlx4/en_netdev.c: In function =E2=80=98ml=
x4_en_init_affinity_hint=E2=80=99:
drivers/net/ethernet/mellanox/mlx4/en_netdev.c:1546:23: error: incompat=
ible types when assigning to type =E2=80=98cpumask_var_t=E2=80=99 from =
type =E2=80=98void *=E2=80=99
drivers/net/ethernet/mellanox/mlx4/en_netdev.c: In function =E2=80=98ml=
x4_en_free_affinity_hint=E2=80=99:
drivers/net/ethernet/mellanox/mlx4/en_netdev.c:1553:41: error: incompat=
ible types when assigning to type =E2=80=98cpumask_var_t=E2=80=99 from =
type =E2=80=98void *=E2=80=99
