From: RongQing Li <roy.qing.li@gmail.com>
Subject: Re: Kernel panic from tg3 net driver
Date: Fri, 21 Oct 2011 18:48:43 +0800
Message-ID: <CAJFZqHzWUsP7szrjVwmW5+HWRND3R4qxWcnK=bqbsgL6F7XGeA@mail.gmail.com>
References: <CAEbykaX4UPDBxOHmNr=dodaquSPjhPr-pLCcUn5hSu4-xLZy-g@mail.gmail.com>
	<20111020.155659.486754557434415381.davem@davemloft.net>
	<1319141125.2854.14.camel@edumazet-laptop>
	<20111020.161147.33259825921677777.davem@davemloft.net>
	<1319141867.2854.19.camel@edumazet-laptop>
	<CAEbykaWhh12pM2jRSzfGig=jeKhVWSdxfwuXHFvLTt14=BYTbA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>, richardcochran@gmail.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Ari Savolainen <ari.m.savolainen@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAEbykaWhh12pM2jRSzfGig=jeKhVWSdxfwuXHFvLTt14=BYTbA@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Ari:

Are you sure the patch is applied correctly and the log is same?
If the log is not same, could you paste it again.

Thanks

BR

2011/10/21 Ari Savolainen <ari.m.savolainen@gmail.com>:
> That's right. I tried the patch and it didn't help.
>
> Ari
>
> 2011/10/20 Eric Dumazet <eric.dumazet@gmail.com>:
>> Le jeudi 20 octobre 2011 =E0 16:11 -0400, David Miller a =E9crit :
>>> From: Eric Dumazet <eric.dumazet@gmail.com>
>>> Date: Thu, 20 Oct 2011 22:05:25 +0200
>>>
>>> > And I think this was fixed yesterday ?
>>> >
>>> > De: =A0 =A0 =A0 =A0 roy.qing.li@gmail.com
>>> > =C0: =A0ari.m.savolainen@gmail.com, netdev@vger.kernel.org
>>> > Sujet: =A0 =A0 =A0[PATCH net-next] neigh: fix rcu splat in neigh_=
update()
>>> > Date: =A0 =A0 =A0 Tue, 18 Oct 2011 16:32:42 +0800 (18/10/2011 10:=
32:42)
>>> >
>>>
>>> Good catch, it seems to be this bug.
>>
>> Oh well, sorry, it seems it was one bug hit during bisection, but ma=
ybe
>> its completely unrelated to the real problem.
>>
>>
>>
>>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
>
