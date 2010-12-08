From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: RCU conversion of dev_getbyhwaddr() and
 arp_ioctl()
Date: Wed, 08 Dec 2010 10:10:35 -0800 (PST)
Message-ID: <20101208.101035.226775926.davem@davemloft.net>
References: <1291548233.2806.212.camel@edumazet-laptop>
	<20101208.100528.193703457.davem@davemloft.net>
	<1291831654.2883.66.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: maximlevitsky@gmail.com, linux1394-devel@lists.sourceforge.net,
	stefanr@s5r6.in-berlin.de, netdev@vger.kernel.org,
	kuznet@ms2.inr.ac.ru, jmorris@namei.org, kaber@trash.net
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33972
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755801Ab0LHSKL convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 8 Dec 2010 13:10:11 -0500
In-Reply-To: <1291831654.2883.66.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 08 Dec 2010 19:07:34 +0100

> Le mercredi 08 d=E9cembre 2010 =E0 10:05 -0800, David Miller a =E9cri=
t :
>> From: Eric Dumazet <eric.dumazet@gmail.com>
>> Date: Sun, 05 Dec 2010 12:23:53 +0100
>>=20
>> > [PATCH] net: RCU conversion of dev_getbyhwaddr() and arp_ioctl()
>> >=20
>> > dev_getbyhwaddr() was called under RTNL.
>> >=20
>> > Rename it to dev_getbyhwaddr_rcu() and change all its caller to no=
w use
>> > RCU locking instead of RTNL.
>> >=20
>> > Change arp_ioctl() to use RCU instead of RTNL locking.
>> >=20
>> > Note: this fix a dev refcount bug in llc
>> >=20
>> > Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
>>=20
>> Applied, thanks Eric.
>=20
> Hmm, dont you want I resubmit it after the "llc: fix a device refcoun=
t
> imbalance" patch pulled from net-2.6 ?
>=20
> Sorry for the mess...

I know about the conflict and will resolve it when I do a merge in
the next hour or so.

Don't worry about this.
