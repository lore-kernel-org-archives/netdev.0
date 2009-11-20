From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] net: Xmit Packet Steering (XPS)
Date: Fri, 20 Nov 2009 14:34:16 -0800 (PST)
Message-ID: <20091120.143416.155282649.davem@davemloft.net>
References: <4B05D8DC.7020907@gmail.com>
	<4B0701E2.1070806@gmail.com>
	<4B070BAC.1090406@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: jarkao2@gmail.com, therbert@google.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41664
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753794AbZKTWd7 convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 20 Nov 2009 17:33:59 -0500
In-Reply-To: <4B070BAC.1090406@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 20 Nov 2009 22:35:40 +0100

> Jarek Poplawski a =E9crit :
>>=20
>> There is one more problem: this will break things like act_mirred + =
ifb,
>> and other cases using skb->iif e.g. for filtering on virtual devices=
 at
>> the xmit path.
>>=20
>=20
> Following patch might help us to locate real uses of this obscure fie=
ld :)
>=20
> [PATCH net-next-2.6] net: rename skb->iif to skb->skb_iif
>=20
> To help grep games, rename iif to skb_iif
>=20
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied, thanks Eric.
