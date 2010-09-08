From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] net: introduce rcu_dereference_rtnl
Date: Wed, 08 Sep 2010 14:15:47 -0700 (PDT)
Message-ID: <20100908.141547.212676559.davem@davemloft.net>
References: <1283893657.2634.210.camel@edumazet-laptop>
	<1283970567.2237.0.camel@achroite.uk.solarflarecom.com>
	<1283971469.2428.9.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: bhutchings@solarflare.com, jarkao2@gmail.com,
	netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50505
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754142Ab0IHVP3 convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 8 Sep 2010 17:15:29 -0400
In-Reply-To: <1283971469.2428.9.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 08 Sep 2010 20:44:29 +0200

> Le mercredi 08 septembre 2010 =E0 19:29 +0100, Ben Hutchings a =E9cri=
t :
>=20
>> No semicolon on the end, please.  The 'caller' will add that.
>=20
> Oh definitely, thanks !
>=20
> [PATCH net-next-2.6] net: introduce rcu_dereference_rtnl
>=20
> We use rcu_dereference_check(p, rcu_read_lock_held() ||
> lockdep_rtnl_is_held()) several times in network stack.
>=20
> More usages to come too, so its time to create a helper.
>=20
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied, thanks Eric.
