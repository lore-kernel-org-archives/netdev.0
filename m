From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6 v2] gre: fix improper error handling
Date: Sat, 23 Jul 2011 20:06:14 -0700 (PDT)
Message-ID: <20110723.200614.904511348785183565.davem@davemloft.net>
References: <201107231049.40603.xeb@mail.ru>
	<1311409964.6669.9.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: xeb@mail.ru, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:33015 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751160Ab1GXDGU convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Jul 2011 23:06:20 -0400
In-Reply-To: <1311409964.6669.9.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Sat, 23 Jul 2011 10:32:44 +0200

> Le samedi 23 juillet 2011 =E0 10:49 +0400, xeb@mail.ru a =E9crit :
>> Fix improper protocol err_handler, current implementation is fully
>> unapplicable and may cause kernel crash due to double kfree_skb.
>>=20
>> Signed-off-by: Dmitry Kozlov <xeb@mail.ru>
>> ---
>> net/ipv4/gre.c |   21 ++++++---------------
>>  1 files changed, 6 insertions(+), 15 deletions(-)
>> =20
>=20
> Good catch !
>=20
> Acked-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied, thanks everyone.
