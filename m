From: "Pradeep A. Dalvi" <netdev@pradeepdalvi.com>
Subject: Re: [PATCH v5 4/5] netdev: ethernet dev_alloc_skb to netdev_alloc_skb
Date: Mon, 6 Feb 2012 23:13:00 +0530
Message-ID: <CA+Dx6HaRFw-zACqQb-VWCnGyA5jagZmNhQx=Os=Nbv626O4msg@mail.gmail.com>
References: <cf736034e7bd407297e2ea9fbf247fb410eb7b39.1328445742.git.netdev@pradeepdalvi.com>
	<d8ad7b1e88df72e284cbc8b8fba1745530923375.1328445742.git.netdev@pradeepdalvi.com>
	<20120206.120740.1750013890695365167.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120206.120740.1750013890695365167.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Feb 6, 2012 at 10:37 PM, David Miller <davem@davemloft.net> wro=
te:
> From: "Pradeep A. Dalvi" <netdev@pradeepdalvi.com>
> Date: Sun, =A05 Feb 2012 18:21:05 +0530
>
>> From: Pradeep A Dalvi <netdev@pradeepdalvi.com>
>>
>> Replaced deprecating dev_alloc_skb with netdev_alloc_skb in drivers/=
net/ethernet
>> =A0 - Removed extra skb->dev =3D dev after netdev_alloc_skb
>>
>> Signed-off-by: Pradeep A Dalvi <netdev@pradeepdalvi.com>
>
> I'm not applying this, you screw up the code formatting in too
> many locations.
>
> Do NOT take the output of checkpatch literally, look at the result
> and determine on your own whether it looks reasonable or not:
>
>> - =A0 =A0 =A0 =A0 =A0 =A0 struct sk_buff *skb =3D dev_alloc_skb(np->=
rx_buf_sz + NV_RX_ALLOC_PAD);
>> + =A0 =A0 =A0 =A0 =A0 =A0 struct sk_buff *skb =3D
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 netdev_alloc_skb(dev, np->=
rx_buf_sz + NV_RX_ALLOC_PAD);
>
> This, looks like crap. =A0The longer line is better.
>
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct sk_buff *skb =3D de=
v_alloc_skb(hmp->rx_buf_sz + 2);
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct sk_buff *skb =3D ne=
tdev_alloc_skb(dev,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 hmp->rx_buf_sz + 2);
>
> Same thing here.
>
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct sk_buff *skb =3D de=
v_alloc_skb(yp->rx_buf_sz + 2);
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct sk_buff *skb =3D ne=
tdev_alloc_skb(dev,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 yp->rx_buf_sz + 2);
>
> Column line-up rule violated, and this looks like crap as a result. =A0=
The long
> single line would look 100 times better.
>
> And there are many other instances of this problem.
>
> Here's my advice, just do the textual change of the function name and=
 add
> the network device argument, don't mess with the coding style at all.
>
> You're fare much better than how these patches ended up in the cases =
where
> you tried to "improve" things.

I shall fix these and resubmit patch again.

Thanks & regards,
Pradeep A. Dalvi
