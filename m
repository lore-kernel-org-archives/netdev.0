From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [PATCH net-next-2.6] filter: add SKF_AD_RXHASH and SKF_AD_CPU
Date: Wed, 1 Dec 2010 16:03:01 +0800
Message-ID: <AANLkTi=P98Krp3yp=z76B1245h7bNOwWfBG=H3eGsLkd@mail.gmail.com>
References: <AANLkTikx68M43+vv+Rav_HCJMJnuc15TtuBgmbv2xP=U@mail.gmail.com>
 <1291109699.2904.11.camel@edumazet-laptop> <AANLkTi=VpmnrXTBNV7McQm6mq9ULT7KTKbM8_hLPoL=2@mail.gmail.com>
 <1291127670.2904.96.camel@edumazet-laptop> <AANLkTi=-iuGJDzELJpu26KtKr77uDx0xNCc8ibEidJ4h@mail.gmail.com>
 <1291176215.2856.383.camel@edumazet-laptop> <1291189556.2856.476.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Rui <wirelesser@gmail.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:45814 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753078Ab0LAIDW convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Dec 2010 03:03:22 -0500
Received: by fxm8 with SMTP id 8so1962550fxm.19
        for <netdev@vger.kernel.org>; Wed, 01 Dec 2010 00:03:21 -0800 (PST)
In-Reply-To: <1291189556.2856.476.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Dec 1, 2010 at 3:45 PM, Eric Dumazet <eric.dumazet@gmail.com> w=
rote:
> Add SKF_AD_RXHASH and SKF_AD_CPU to filter ancillary mechanism,
> to be able to build advanced filters.
>
> This can help spreading packets on several sockets with a fast
> selection, after RPS dispatch to N cpus for example, or to catch a
> percentage of flows in one queue.
>
> tcpdump -s 500 "cpu =3D 1" :
>
> [0] ld CPU
> [1] jeq #1 =A0jt 2 =A0jf 3
> [2] ret #500
> [3] ret #0
>
> # take 12.5 % of flows (average)
> tcpdump -s 1000 "rxhash & 7 =3D 2" :
>
> [0] ld RXHASH
> [1] and #7
> [2] jeq #2 =A0jt 3 =A0jf 4
> [3] ret #1000
> [4] ret #0
>
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> Cc: Rui <wirelesser@gmail.com>

Acked-by: Changli Gao <xiaosuo@gmail.com>

--=20
Regards,
Changli Gao(xiaosuo@gmail.com)
