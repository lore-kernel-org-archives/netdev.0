From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6 v2] net: sk_{detach|attach}_filter() rcu
 fixes
Date: Mon, 27 Sep 2010 21:51:57 -0700 (PDT)
Message-ID: <20100927.215157.260083160.davem@davemloft.net>
References: <1285603064.3017.42.camel@edumazet-laptop>
	<1285603650.3017.57.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, paulmck@linux.vnet.ibm.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56041
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751441Ab0I1Evg convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 28 Sep 2010 00:51:36 -0400
In-Reply-To: <1285603650.3017.57.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 27 Sep 2010 18:07:30 +0200

> Le lundi 27 septembre 2010 =E0 17:57 +0200, Eric Dumazet a =E9crit :
>> sk_attach_filter() is run with socket locked.
>>=20
>> Use the appropriate rcu_dereference_protected() instead of blocking =
BH,
>> and rcu_dereference_bh().
>> There is no point adding BH prevention and memory barrier.
>=20
> Hmm, same thing can be done in sk_detach_filter, here is a v2.
>=20
> Thanks
>=20
> [PATCH net-next-2.6 v2] net: sk_{detach|attach}_filter() rcu fixes
>=20
> sk_attach_filter() and sk_detach_filter() are run with socket locked.
>=20
> Use the appropriate rcu_dereference_protected() instead of blocking B=
H,
> and rcu_dereference_bh().
> There is no point adding BH prevention and memory barrier.
>=20
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied.
