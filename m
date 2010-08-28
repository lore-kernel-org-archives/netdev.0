From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3] slip: Use net_device_stats from struct net_device
Date: Fri, 27 Aug 2010 19:26:18 -0700 (PDT)
Message-ID: <20100827.192618.193702625.davem@davemloft.net>
References: <1282811286-19659-1-git-send-email-tklauser@distanz.ch>
	<1282896728-5211-1-git-send-email-tklauser@distanz.ch>
	<1282897693.2487.2.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: tklauser@distanz.ch, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59471
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753016Ab0H1C0D convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 27 Aug 2010 22:26:03 -0400
In-Reply-To: <1282897693.2487.2.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 27 Aug 2010 10:28:13 +0200

> Le vendredi 27 ao=FBt 2010 =E0 10:12 +0200, Tobias Klauser a =E9crit =
:
>> Use net_device->stats for stats instead of private variable copies i=
n
>> struct slip. Use ndo_get_stat64 so the additions can be performed on=
 a private
>> destination buffer.
>>=20
>> Cc: Eric Dumazet <eric.dumazet@gmail.com>
>> Signed-off-by: Tobias Klauser <tklauser@distanz.ch>
>> ---
>>  drivers/net/slip.c |   61 ++++++++++++++++++++++++++---------------=
----------
>>  drivers/net/slip.h |    9 -------
>>  2 files changed, 31 insertions(+), 39 deletions(-)
>>=20
>=20
> Acked-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied, thanks everyone.
