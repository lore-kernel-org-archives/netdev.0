From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: TCP packet size and delivery packet decisions
Date: Tue, 07 Sep 2010 08:09:29 +0200
Message-ID: <1283839769.2585.572.camel@edumazet-laptop>
References: <AANLkTikMPENe011GxK15TNTXwdckZSSYfb=3pdDwfUeG@mail.gmail.com>
	 <20100906.221644.123986391.davem@davemloft.net>
	 <AANLkTik75BGz=csDKVRk+Ni9__MqXMpHeqi_sHniu09A@mail.gmail.com>
	 <20100906.223010.173858342.davem@davemloft.net>
	 <AANLkTi=x4+YqyuOvpnUXd2PjMHifMPXEgEA=0=+wfPk7@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: =?UTF-8?Q?=E3=83=84?= Leandro Melo de Sales <leandroal@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:42492 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750775Ab0IGGJe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Sep 2010 02:09:34 -0400
Received: by wwj40 with SMTP id 40so7628096wwj.1
        for <netdev@vger.kernel.org>; Mon, 06 Sep 2010 23:09:33 -0700 (PDT)
In-Reply-To: <AANLkTi=x4+YqyuOvpnUXd2PjMHifMPXEgEA=0=+wfPk7@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 07 septembre 2010 =C3=A0 03:02 -0300, =E3=83=84 Leandro Melo d=
e Sales a
=C3=A9crit :
> >
>=20
> David,
>    Yes, 78 bytes is the size of each command. I have concluded the
> same as you. In this case, to deal with this type of situation, how
> about changing TCP implementation on Linux to send the whole packet
> when it is too small such in this case or when TCP notice that there
> is no change in the advertised rcwd or when advertised win is equal t=
o
> advertised MSS, since the receiver is saying "I can receive packets i=
n
> the same size of my cwd"?
>=20
>   I'm sorry if I'm suggesting something that does not make sense, but
> since receiver advertises that are able to receive packets in that
> size which is equal to the congwin size, splitting the packet in this
> case only [unnecessarily] increased the flow completion time or avoid
> data to be delivered to the application as soon as possible since it
> arrived splitted. As we could notice from the tcpdump report, TCP
> implementation under Linux does not wait for any ACK of the first 48
> bytes sent out, it just sent the other 30 bytes in a consecutive
> delivery, which is the same as sending 78 bytes at once, since no
> decision is taken to send or not the other last 30 bytes.
>=20
>    Regardless this discussion, can you at least suggest any workaroun=
d
> that I can do in the application layer to make TCP send the whole
> packet at once? As I said, I tried to use TCP_CORK suggested by
> Arnaldo (acme), but it does not work for me in this case.
>=20

Is it a critical problem for you ?

If you give us at least some minutes or hours or even days to think
about this corner case, I am sure we can find a solution :)

They are two factors here : MSS=3D78 and WIN=3D78

Thanks


