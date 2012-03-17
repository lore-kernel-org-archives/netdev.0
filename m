From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv6: Don't dev_hold(dev) in ip6_mc_find_dev_rcu.
Date: Fri, 16 Mar 2012 21:57:24 -0700 (PDT)
Message-ID: <20120316.215724.388331662024242970.davem@davemloft.net>
References: <1331888054-21072-1-git-send-email-roy.qing.li@gmail.com>
	<1331907353.2420.1.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: roy.qing.li@gmail.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:39410 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752283Ab2CQE50 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 17 Mar 2012 00:57:26 -0400
In-Reply-To: <1331907353.2420.1.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 16 Mar 2012 07:15:53 -0700

> Le vendredi 16 mars 2012 =E0 16:54 +0800, roy.qing.li@gmail.com a =E9=
crit :
>> From: RongQing.Li <roy.qing.li@gmail.com>
>>=20
>> ip6_mc_find_dev_rcu() is called with rcu_read_lock(), so don't
>> need to dev_hold().
>> With dev_hold(), not corresponding dev_put(), will lead to leak.
>>=20
>> Signed-off-by: RongQing.Li <roy.qing.li@gmail.com>
 ...
> Nice catch, bug introduced in 96b52e61be1 (ipv6: mcast: RCU conversio=
ns)
>=20
> Acked-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied and queued up for -stable, thanks.
