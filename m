From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] macvlan: use call_rcu for port free
Date: Mon, 07 Jun 2010 21:26:06 -0700 (PDT)
Message-ID: <20100607.212606.216727629.davem@davemloft.net>
References: <20100607113629.GA2730@psychotron.lab.eng.brq.redhat.com>
	<1275912936.2545.48.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: jpirko@redhat.com, netdev@vger.kernel.org, kaber@trash.net
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42343
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751036Ab0FHEZ5 convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Jun 2010 00:25:57 -0400
In-Reply-To: <1275912936.2545.48.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 07 Jun 2010 14:15:36 +0200

> Le lundi 07 juin 2010 =E0 13:36 +0200, Jiri Pirko a =E9crit :
>> Use call_rcu rather than synchronize_rcu.
>>=20
>> Signed-off-by: Jiri Pirko <jpirko@redhat.com>
>> ---
>>  drivers/net/macvlan.c |   12 ++++++++++--
>>  1 files changed, 10 insertions(+), 2 deletions(-)
>>=20
>=20
> Acked-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied.
