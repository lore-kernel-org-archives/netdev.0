From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Kernel panic from tg3 net driver
Date: Sat, 22 Oct 2011 08:37:50 +0200
Message-ID: <1319265470.6180.13.camel@edumazet-laptop>
References: <CAEbykaX4UPDBxOHmNr=dodaquSPjhPr-pLCcUn5hSu4-xLZy-g@mail.gmail.com>
	 <20111020.155659.486754557434415381.davem@davemloft.net>
	 <1319141125.2854.14.camel@edumazet-laptop>
	 <20111020.161147.33259825921677777.davem@davemloft.net>
	 <1319141867.2854.19.camel@edumazet-laptop>
	 <CAEbykaWhh12pM2jRSzfGig=jeKhVWSdxfwuXHFvLTt14=BYTbA@mail.gmail.com>
	 <CAJFZqHzWUsP7szrjVwmW5+HWRND3R4qxWcnK=bqbsgL6F7XGeA@mail.gmail.com>
	 <CAEbykaVJneQ0ozUvYh2PRn-p_BowL4z4_4Y8EFCdO9mOsNX7OQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: RongQing Li <roy.qing.li@gmail.com>,
	David Miller <davem@davemloft.net>, richardcochran@gmail.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Ari Savolainen <ari.m.savolainen@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAEbykaVJneQ0ozUvYh2PRn-p_BowL4z4_4Y8EFCdO9mOsNX7OQ@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le samedi 22 octobre 2011 =C3=A0 09:12 +0300, Ari Savolainen a =C3=A9cr=
it :
> 2011/10/21 RongQing Li <roy.qing.li@gmail.com>:
> > Hi Ari:
> >
> > Are you sure the patch is applied correctly and the log is same?
> > If the log is not same, could you paste it again.
> >
> > Thanks
>=20
> Yes, I'm sure. The panic and the rcu splat are unrelated. The panic
> occurs when skb_tx_timestamp is being called after skb having been
> freed by tigon3_dma_hwbug_workaround.

OK that makes sense, thanks !

Do you plan to submit a patch, now you found the bug ?
