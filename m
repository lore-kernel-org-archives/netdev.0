From: Po-Yu Chuang <ratbert.chuang@gmail.com>
Subject: Re: [PATCH v6] net: add Faraday FTMAC100 10/100 Ethernet driver
Date: Tue, 1 Mar 2011 13:51:42 +0800
Message-ID: <AANLkTi=Sp-mAV1556pZvCvHzQ=MQNHUzjo0ap2DhKwWe@mail.gmail.com>
References: <1298539762-2242-1-git-send-email-ratbert.chuang@gmail.com>
 <1298627845-1583-1-git-send-email-ratbert.chuang@gmail.com>
 <1298634040.2659.32.camel@edumazet-laptop> <AANLkTimeDR27Q7fcBmB0ix7Q_pRT_GDpc7S3LO21-fh-@mail.gmail.com>
 <1298958336.2676.21.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	bhutchings@solarflare.com, joe@perches.com, dilinger@queued.net,
	mirqus@gmail.com, davem@davemloft.net,
	Po-Yu Chuang <ratbert@faraday-tech.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1298958336.2676.21.camel@edumazet-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Eric,

On Tue, Mar 1, 2011 at 1:45 PM, Eric Dumazet <eric.dumazet@gmail.com> w=
rote:
> Le mardi 01 mars 2011 =C3=A0 13:20 +0800, Po-Yu Chuang a =C3=A9crit :
>
>> That means, since every rx buffer is large enough, it is impossible =
to
>> get a multi-segment packets.
>>
>> So I simplified ftmac100_rx_packet().
>
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Ah, I just want to submit a v7.
Could you resign again later, please? :-)

> I am only wondering then if not using fragments would be faster then
> (eventually doing copybreaks for small frames like tg3)

Although not many circumstances are tested.
iperf shows that it is a little faster to use fragments than memcpy, so=
=2E..

> But if you plan to get new hw soon, you have the infrastructure...

best regards,
Po-Yu Chuang
