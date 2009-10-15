From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] virtio_net: use dev_kfree_skb_any() in
 free_old_xmit_skbs()
Date: Wed, 14 Oct 2009 23:30:30 -0700 (PDT)
Message-ID: <20091014.233030.129292617.davem@davemloft.net>
References: <4AD455E4.2070105@navynet.it>
	<4AD62626.6010709@navynet.it>
	<4AD66E9B.2020803@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: mcetra@navynet.it, ctrixk@navynet.it, rjw@sisk.pl,
	linux-kernel@vger.kernel.org, kernel-testers@vger.kernel.org,
	netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57058
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754977AbZJOGae convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Oct 2009 02:30:34 -0400
In-Reply-To: <4AD66E9B.2020803@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 15 Oct 2009 02:36:43 +0200

> Massimo Cetra a =E9crit :
>> Eric,
>> thanks for the patch.
>> The problem didn't arise again and i haven't seen any warning like t=
hat
>> on both servers where that problem was happening more frequently.
>>=20
>> I would say that it's fixed and if it's not, i'll let you know as so=
on
>> as it happens again.
>>=20
>=20
> Thanks Massimo, I think patch is reasonably safe and should be taken =
as is :
>=20
>=20
> [PATCH] virtio_net: use dev_kfree_skb_any() in free_old_xmit_skbs()

Applied, thanks Eric.
