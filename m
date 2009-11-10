From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [PATCH] ifb: add multi-queue support
Date: Tue, 10 Nov 2009 21:06:58 +0800
Message-ID: <412e6f7f0911100506r6a922b8aoabd359e7e4290ebe@mail.gmail.com>
References: <4AF924A5.1050303@gmail.com> <4AF92D6D.8060300@gmail.com>
	 <412e6f7f0911100143k68284faes92e39d8ca94aa9d4@mail.gmail.com>
	 <4AF9471C.5080606@gmail.com>
	 <412e6f7f0911100314i33d6a49dl5163b5e8472babcf@mail.gmail.com>
	 <4AF95174.3060104@trash.net>
	 <412e6f7f0911100414w7b6f45aap39f6568b7af2c1a7@mail.gmail.com>
	 <4AF95A3D.5060602@trash.net>
	 <412e6f7f0911100437g2759eb6dg509af4edb8848291@mail.gmail.com>
	 <4AF96055.90509@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Tom Herbert <therbert@google.com>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-px0-f173.google.com ([209.85.216.173]:46851 "EHLO
	mail-px0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752693AbZKJNGx convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Nov 2009 08:06:53 -0500
Received: by pxi3 with SMTP id 3so2583925pxi.22
        for <netdev@vger.kernel.org>; Tue, 10 Nov 2009 05:06:58 -0800 (PST)
In-Reply-To: <4AF96055.90509@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 10, 2009 at 8:45 PM, Patrick McHardy <kaber@trash.net> wrot=
e:
>
> Its a trivial change, you can put them in the same patch:
>
> static int ifb_get_tx_queues(struct net *net, struct nlattr *tb[],
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 unsigned int *num_tx_queues,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 unsigned int *real_num_tx_queues)
> {
> =C2=A0 =C2=A0unsigned int n =3D 1;
>
> =C2=A0 =C2=A0if (tb[IFLA_NTXQ])
> =C2=A0 =C2=A0 =C2=A0 n =3D nla_get_u32(tb[IFLA_NTXQ]);
>
> =C2=A0 =C2=A0*num_tx_queues =3D n;
> =C2=A0 =C2=A0*real_num_tx_queues =3D n;
> =C2=A0 =C2=A0return 0;
> }
>

Is IFLA_NTXQ added? I didn't find it in any branch. And I think both
num_tx_queueus and real_num_tx_queues are needed.

--=20
Regards=EF=BC=8C
Changli Gao(xiaosuo@gmail.com)
