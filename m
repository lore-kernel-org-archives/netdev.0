From: Po-Yu Chuang <ratbert.chuang@gmail.com>
Subject: Re: [PATCH v3] net: add Faraday FTMAC100 10/100 Ethernet driver
Date: Thu, 20 Jan 2011 23:43:17 +0800
Message-ID: <AANLkTi=BHxP465epxWwsZxfVtL7yJOCDRjQ3sKdmSYDp@mail.gmail.com>
References: <1295256060-2091-1-git-send-email-ratbert.chuang@gmail.com>
 <1295537418-2057-1-git-send-email-ratbert.chuang@gmail.com> <1295537746.2825.298.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	bhutchings@solarflare.com, joe@perches.com, dilinger@queued.net,
	Po-Yu Chuang <ratbert@faraday-tech.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1295537746.2825.298.camel@edumazet-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Dear Eric,

On Thu, Jan 20, 2011 at 11:35 PM, Eric Dumazet <eric.dumazet@gmail.com>=
 wrote:
> Le jeudi 20 janvier 2011 =C3=A0 23:30 +0800, Po-Yu Chuang a =C3=A9cri=
t :
>
>> + =C2=A0 =C2=A0 /* push packet to protocol stack */
>> + =C2=A0 =C2=A0 netif_receive_skb(skb);
>> +
>> + =C2=A0 =C2=A0 netdev->stats.rx_packets++;
>> + =C2=A0 =C2=A0 netdev->stats.rx_bytes +=3D skb->len;
>> +
>> + =C2=A0 =C2=A0 (*processed)++;
>> +
>> + =C2=A0 =C2=A0 return true;
>> +}
>> +
>
> Hmm, after call to netif_receive_skb(skb), you are not allowed to acc=
ess
> skb anymore (maybe it was freed)
>
> netdev->stats.rx_packets++;
> netdev->stats.rx_bytes +=3D skb->len;
> netif_receive_skb(skb);

Wow, you are totally right.

Thanks,
Po-Yu Chuang
