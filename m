From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] netdev/ethernet: dev_alloc_skb to netdev_alloc_skb
Date: Mon, 23 Jan 2012 10:43:56 +0100
Message-ID: <1327311836.2525.6.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <1327179463-13980-1-git-send-email-netdev@pradeepdalvi.com>
	 <CANX6Da=Y5zJ4xi8=gLZZ8tUnnqxNCpvC0yBGruObWzYHrucLLg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Pradeep A. Dalvi" <netdev@pradeepdalvi.com>,
	netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Christoph Hellwig <hch@lst.de>, linux-kernel@vger.kernel.org
To: Viral Mehta <viral.vkm@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CANX6Da=Y5zJ4xi8=gLZZ8tUnnqxNCpvC0yBGruObWzYHrucLLg@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le lundi 23 janvier 2012 =C3=A0 14:10 +0530, Viral Mehta a =C3=A9crit :
> On Sun, Jan 22, 2012 at 2:27 AM, Pradeep A. Dalvi
> <netdev@pradeepdalvi.com> wrote:
> > Replaced deprecating dev_alloc_skb with netdev_alloc_skb in drivers=
/net/ethernet
> >
> > Signed-off-by: Pradeep A. Dalvi <netdev@pradeepdalvi.com>
>=20
> and these too ??
>=20
> vmehta@viralmehta:~/linux-3.2/drivers/infiniband/hw$ grep dev_alloc_s=
kb -r .
> ./ipath/ipath_driver.c:	skb =3D __dev_alloc_skb(len, gfp_mask);
> ./nes/nes_cm.c:	skb =3D dev_alloc_skb(MAX_CM_BUFFER);
> ./nes/nes_cm.c:		skb =3D dev_alloc_skb(MAX_CM_BUFFER);

Those should probably use a mere alloc_skb(), since they dont need the
NET_SKB_PAD

> ./nes/nes_cm.c:		skb =3D dev_alloc_skb(MAX_CM_BUFFER);
> ./nes/nes_cm.c:		skb =3D dev_alloc_skb(MAX_CM_BUFFER);
> ./nes/nes_cm.c:		skb =3D dev_alloc_skb(MAX_CM_BUFFER);
> ./nes/nes_hw.c:		skb =3D dev_alloc_skb(nesvnic->max_frame_size);
> ./nes/nes_hw.c:		skb =3D dev_alloc_skb(nesvnic->max_frame_size);
> ./nes/nes_mgt.c:		skb =3D dev_alloc_skb(mgtvnic->nesvnic->max_frame_s=
ize);
> ./nes/nes_mgt.c:			skb =3D dev_alloc_skb(nesvnic->max_frame_size);
> ./amso1100/c2.c:	skb =3D dev_alloc_skb(c2_port->rx_buf_size);
> vmehta@viralmehta:~/linux-3.2/drivers/infiniband/hw$
> --
