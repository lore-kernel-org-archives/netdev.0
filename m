From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] net: Add a missing local_irq_enable()
Date: Mon, 05 Apr 2010 15:42:53 -0700 (PDT)
Message-ID: <20100405.154253.216913267.davem@davemloft.net>
References: <alpine.DEB.1.00.1004051426140.22393@pokey.mtv.corp.google.com>
	<z2m412e6f7f1004051523p6198556ak3e2ab9a52a3167d4@mail.gmail.com>
	<1270507307.9013.43.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: xiaosuo@gmail.com, therbert@google.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42409
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756569Ab0DEWmv convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 Apr 2010 18:42:51 -0400
In-Reply-To: <1270507307.9013.43.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 06 Apr 2010 00:41:47 +0200

> Le mardi 06 avril 2010 =E0 06:23 +0800, Changli Gao a =E9crit :
>=20
>> It seems that irq isn't enabled when breaking the loop. Please add
>>    local_irq_enable();
>> after rps_unlock(queue);
>=20
> Gah.. you are right, following patch needed, since David already appl=
ied
> Tom's patch.
>=20
> [PATCH net-next-2.6] net: Add a missing local_irq_enable()
>=20
> As noticed by Changli Gao, we must call local_irq_enable() after
> rps_unlock()
>=20
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied, hope it's fully resolved now :-)
