From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: remove rcu locking from fib_rules_event()
Date: Wed, 17 Mar 2010 07:32:39 +0100
Message-ID: <1268807559.2932.35.camel@edumazet-laptop>
References: <1268201018.2872.139.camel@edumazet-laptop>
	 <20100316.212846.160081359.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, paulmck@linux.vnet.ibm.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f211.google.com ([209.85.218.211]:55658 "EHLO
	mail-bw0-f211.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753264Ab0CQGcp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Mar 2010 02:32:45 -0400
Received: by bwz3 with SMTP id 3so825896bwz.29
        for <netdev@vger.kernel.org>; Tue, 16 Mar 2010 23:32:43 -0700 (PDT)
In-Reply-To: <20100316.212846.160081359.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 16 mars 2010 =C3=A0 21:28 -0700, David Miller a =C3=A9crit :
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Wed, 10 Mar 2010 07:03:38 +0100
>=20
> > We hold RTNL at this point and dont use RCU variants of list traver=
sals,
> > we dont need rcu_read_lock()/rcu_read_unlock()
> >=20
> > Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
>=20
> Applied.

Thanks David.

I believe the synchronize_rcu() we have in this file is useless too,
I'll submit a patch.



