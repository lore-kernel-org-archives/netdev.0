From: "Pradeep A. Dalvi" <netdev@pradeepdalvi.com>
Subject: Re: [PATCH] netdev/ethernet: dev_alloc_skb to netdev_alloc_skb
Date: Mon, 23 Jan 2012 15:59:06 +0530
Message-ID: <CA+Dx6HZci3qni-FUQBw62hZsS0FMomNdQysZGsmNr_fceN4CQg@mail.gmail.com>
References: <1327179463-13980-1-git-send-email-netdev@pradeepdalvi.com>
	<CANX6Da=Y5zJ4xi8=gLZZ8tUnnqxNCpvC0yBGruObWzYHrucLLg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Christoph Hellwig <hch@lst.de>, linux-kernel@vger.kernel.org
To: Viral Mehta <viral.vkm@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CANX6Da=Y5zJ4xi8=gLZZ8tUnnqxNCpvC0yBGruObWzYHrucLLg@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jan 23, 2012 at 2:10 PM, Viral Mehta <viral.vkm@gmail.com> wrot=
e:
> On Sun, Jan 22, 2012 at 2:27 AM, Pradeep A. Dalvi
> <netdev@pradeepdalvi.com> wrote:
>> Replaced deprecating dev_alloc_skb with netdev_alloc_skb in drivers/=
net/ethernet
>>
>> Signed-off-by: Pradeep A. Dalvi <netdev@pradeepdalvi.com>
>
> and these too ??
>
> vmehta@viralmehta:~/linux-3.2/drivers/infiniband/hw$ grep dev_alloc_s=
kb -r .
> ./ipath/ipath_driver.c: skb =3D __dev_alloc_skb(len, gfp_mask);
> ./nes/nes_cm.c: skb =3D dev_alloc_skb(MAX_CM_BUFFER);
> ./nes/nes_cm.c: =A0 =A0 =A0 =A0 skb =3D dev_alloc_skb(MAX_CM_BUFFER);
> ./nes/nes_cm.c: =A0 =A0 =A0 =A0 skb =3D dev_alloc_skb(MAX_CM_BUFFER);
> ./nes/nes_cm.c: =A0 =A0 =A0 =A0 skb =3D dev_alloc_skb(MAX_CM_BUFFER);
> ./nes/nes_cm.c: =A0 =A0 =A0 =A0 skb =3D dev_alloc_skb(MAX_CM_BUFFER);
> ./nes/nes_hw.c: =A0 =A0 =A0 =A0 skb =3D dev_alloc_skb(nesvnic->max_fr=
ame_size);
> ./nes/nes_hw.c: =A0 =A0 =A0 =A0 skb =3D dev_alloc_skb(nesvnic->max_fr=
ame_size);
> ./nes/nes_mgt.c: =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0skb =3D dev_alloc_skb=
(mgtvnic->nesvnic->max_frame_size);
> ./nes/nes_mgt.c: =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0skb =3D=
 dev_alloc_skb(nesvnic->max_frame_size);
> ./amso1100/c2.c: =A0 =A0 =A0 =A0skb =3D dev_alloc_skb(c2_port->rx_buf=
_size);
> vmehta@viralmehta:~/linux-3.2/drivers/infiniband/hw$

This patch is for drivers/net/ethernet directory & haven't touched
infiniband directory.
