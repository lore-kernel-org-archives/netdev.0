From: Koki Sanagi <sanagi.koki@jp.fujitsu.com>
Subject: Re: [RFC PATCH v2 4/5] skb: add tracepoints to freeing skb
Date: Mon, 28 Jun 2010 09:25:37 +0900
Message-ID: <4C27EC01.6030708@jp.fujitsu.com>
References: <4C2312A8.9060903@jp.fujitsu.com>	 <4C23FF55.3090604@jp.fujitsu.com> <1277441711.2481.3.camel@edumazet-laptop>	 <4C2456DA.8030200@jp.fujitsu.com> <1277496347.2481.12.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, kaneshige.kenji@jp.fujitsu.com,
	izumi.taku@jp.fujitsu.com, netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1277496347.2481.12.camel@edumazet-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

(2010/06/26 5:05), Eric Dumazet wrote:
> Le vendredi 25 juin 2010 =C3=A0 16:12 +0900, Koki Sanagi a =C3=A9crit=
 :
>=20
>>> You might add a trace point to skb_free_datagram_locked() too, sinc=
e it
>>> contains an inlined consume_skb()
>>>
>>
>> I think it is contrary.
>=20
> I think you are _very_ wrong.
>=20
>> skb_free_datagram_locked() contains consume_skb(), so tracepoint isn=
't needed.
>> Because skb_free_datagram_locked() can be traced by trace_consume_sk=
b().
>>
>>
>>
>=20
> Koki, it would be good if you worked on net-next-2.6, so that my comm=
ent
> applies.

Yes, I am very wrong... I saw skb_free_datagram_locked() at linux-2.6.3=
4.
It would be good to add tracepoint to it.
=20
> Also, not sending this kind of patches on netdev is not going to help
> very much.
>=20
> Who is supposed to review them on lkml and Ack them ?=20
>=20
> Nobody.
>=20
> Please build your future network related patches against net-next-2.6=
,
> and send them to nedev and David Miller, the official network
> maintainer, as stated in MAINTAINERS file.
>=20
> NETWORKING [GENERAL]
> M:      "David S. Miller" <davem@davemloft.net>
> L:      netdev@vger.kernel.org
> W:      http://www.linuxfoundation.org/en/Net
> W:      http://patchwork.ozlabs.org/project/netdev/list/
> T:      git git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-2=
=2E6.git
> T:      git git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-n=
ext-2.6.git
> S:      Maintained
> F:      net/
> F:      include/net/
> F:      include/linux/in.h
> F:      include/linux/net.h
> F:      include/linux/netdevice.h

Yes, my submitting this time has many improper things(address, format a=
nd description...).
I'll check and modify them next time.

Thanks,
Koki Sanagi.
>=20
>=20
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>=20
>=20
