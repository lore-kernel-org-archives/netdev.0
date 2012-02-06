From: "Pradeep A. Dalvi" <netdev@pradeepdalvi.com>
Subject: Re: [PATCH v5 2/5] netdev: ethernet dev_alloc_skb to netdev_alloc_skb
Date: Mon, 6 Feb 2012 23:10:30 +0530
Message-ID: <CA+Dx6HbHcU_Y5PSCisiRJxoKLjk_TKOef2BHHoRYGrP0Jc8oUg@mail.gmail.com>
References: <cf736034e7bd407297e2ea9fbf247fb410eb7b39.1328445742.git.netdev@pradeepdalvi.com>
	<59b9c48e067528d94b260b044e1b375c56c97040.1328445742.git.netdev@pradeepdalvi.com>
	<20120206.114917.1450321525231150955.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120206.114917.1450321525231150955.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Feb 6, 2012 at 10:19 PM, David Miller <davem@davemloft.net> wro=
te:
> From: "Pradeep A. Dalvi" <netdev@pradeepdalvi.com>
> Date: Sun, =A05 Feb 2012 18:20:10 +0530
>
>> From: Pradeep A Dalvi <netdev@pradeepdalvi.com>
>>
>> Replaced deprecating dev_alloc_skb with netdev_alloc_skb in drivers/=
net/ethernet
>> =A0 - Removed extra skb->dev =3D dev after netdev_alloc_skb
>>
>> Signed-off-by: Pradeep A Dalvi <netdev@pradeepdalvi.com>
>
> Applied, but again I had to fix things:
>
>> - =A0 =A0p =3D dev_alloc_skb(IEEE802_3_SZ + DE4X5_ALIGN + 2);
>> + =A0 =A0 p =3D netdev_alloc_skb(dev, IEEE802_3_SZ + DE4X5_ALIGN + 2=
);
> =A0...
>> - =A0 =A0p =3D dev_alloc_skb(len + 2);
>> + =A0 =A0 p =3D netdev_alloc_skb(dev, len + 2);
>
> Leave existing indentation alone.
>
>> - =A0 =A0 =A0 =A0 =A0 =A0 skb =3D dev_alloc_skb(ugeth->ug_info->uf_i=
nfo.max_rx_buf_length +
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 UC=
C_GETH_RX_DATA_BUF_ALIGNMENT);
>> + =A0 =A0 =A0 =A0 =A0 =A0 skb =3D netdev_alloc_skb(ugeth->ndev,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ugeth->ug_=
info->uf_info.max_rx_buf_length +
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 UCC_GETH_R=
X_DATA_BUF_ALIGNMENT);
>
> Line up subsequent lines of a multiline series of function arguments
> properly, each should start at the first column after the function ca=
lls
> openning parenthesis.

Thanks a lot again! And would remember about these too.
