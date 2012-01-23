From: "Pradeep A. Dalvi" <netdev@pradeepdalvi.com>
Subject: Re: [PATCH/RESEND] drivers/net/ethernet: dev_alloc_skb to netdev_alloc_skb
Date: Tue, 24 Jan 2012 00:49:32 +0530
Message-ID: <CA+Dx6HY92Z8KtDXf73O3QMWLj__+Q2g7PxjiZ7omn+tuh8YK5A@mail.gmail.com>
References: <1327343283-4830-1-git-send-email-netdev@pradeepdalvi.com>
	<1327344034.6317.3.camel@joe2Laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Christoph Hellwig <hch@lst.de>, linux-kernel@vger.kernel.org,
	Eric Dumazet <eric.dumazet@gmail.com>
To: Joe Perches <joe@perches.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1327344034.6317.3.camel@joe2Laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jan 24, 2012 at 12:10 AM, Joe Perches <joe@perches.com> wrote:
> On Mon, 2012-01-23 at 23:58 +0530, Pradeep A. Dalvi wrote:
>> Replaced deprecating dev_alloc_skb with netdev_alloc_skb in drivers/=
net/ethernet
>> =A0 - Removed extra skb->dev =3D dev after netdev_alloc_skb
> []
>> diff --git a/drivers/net/ethernet/amd/lance.c b/drivers/net/ethernet=
/amd/lance.c
> []
>> @@ -871,13 +871,12 @@ lance_init_ring(struct net_device *dev, gfp_t =
gfp)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct sk_buff *skb;
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 void *rx_buff;
>>
>> - =A0 =A0 =A0 =A0 =A0 =A0 skb =3D alloc_skb(PKT_BUF_SZ, GFP_DMA | gf=
p);
>> + =A0 =A0 =A0 =A0 =A0 =A0 skb =3D netdev_alloc_skb(dev, PKT_BUF_SZ);
>
> This change seems suspect.
> I stopped reading here.
>
> Perhaps you should break this large patch
> into multiple separate patches.
>
> The trivial, obviously correct
> and the possibly broken.

Not really sure what made you suspect something in here. If you could
help me understand possibly broken scenarios, would essentially be
helpful. Thanks in advance!
