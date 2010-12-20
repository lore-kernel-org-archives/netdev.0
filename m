From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6] net_sched: always clone skbs
Date: Mon, 20 Dec 2010 10:27:29 -0800 (PST)
Message-ID: <20101220.102729.193722143.davem@davemloft.net>
References: <1292855730-19265-1-git-send-email-xiaosuo@gmail.com>
	<1292855876.2800.46.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: xiaosuo@gmail.com, jarkao2@gmail.com, netdev@vger.kernel.org,
	hadi@cyberus.ca, pstaszewski@itcare.pl
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41800
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932742Ab0LTS1A convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 20 Dec 2010 13:27:00 -0500
In-Reply-To: <1292855876.2800.46.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 20 Dec 2010 15:37:56 +0100

> Le lundi 20 d=E9cembre 2010 =E0 22:35 +0800, Changli Gao a =E9crit :
>> Pawel reported a panic related to handling shared skbs in ixgbe
>> incorrectly. So we need to revert my previous patch to work around
>> this bug. Instead of reverting the patch completely, I just revert
>> the essential lines, so we can add the previous optimization
>> back more easily in future.
>>=20
>>     commit 3511c9132f8b1e1b5634e41a3331c44b0c13be70
>>     Author: Changli Gao <xiaosuo@gmail.com>
>>     Date:   Sat Oct 16 13:04:08 2010 +0000
>>    =20
>>         net_sched: remove the unused parameter of qdisc_create_dflt(=
)
>>=20
>> Reported-by: Pawel Staszewski <pstaszewski@itcare.pl>
>> Signed-off-by: Changli Gao <xiaosuo@gmail.com>
>=20
> Acked-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied, thanks everyone.
