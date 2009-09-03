From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] drivers: Kill now superfluous ->last_rx
 stores
Date: Wed, 02 Sep 2009 23:09:54 -0700 (PDT)
Message-ID: <20090902.230954.227402492.davem@davemloft.net>
References: <20090831111245.GA2105@hmsreliant.think-freely.org>
	<4A9BD13E.4040501@gmail.com>
	<4A9BFBAA.10705@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: nhorman@tuxdriver.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41281
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754391AbZICGJj convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Sep 2009 02:09:39 -0400
In-Reply-To: <4A9BFBAA.10705@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 31 Aug 2009 18:34:50 +0200

> Eric Dumazet a =E9crit :
>> Neil Horman a =E9crit :
>>> I still see a large number of drivers that update dev->last_rx, alt=
hough its
>>> not all as I look through the list, so something definately seems a=
miss.
>>=20
>> Some drivers still update dev->last_rx for their own needs, not a co=
re
>> network concern.
>>=20
>> But a cleanup is certainly possible on few other drivers, about a do=
zen
>> if I count correctly.
>=20
> Well, a litle bit more if we look outside of drivers/net
>=20
> [PATCH net-next-2.6] drivers: Kill now superfluous ->last_rx stores
>=20
> The generic packet receive code takes care of setting
> netdev->last_rx when necessary, for the sake of the
> bonding ARP monitor.
>=20
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied, thanks Eric.
