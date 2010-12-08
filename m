From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: RCU conversion of dev_getbyhwaddr() and
 arp_ioctl()
Date: Wed, 08 Dec 2010 19:07:34 +0100
Message-ID: <1291831654.2883.66.camel@edumazet-laptop>
References: <1291504514.1874.92.camel@maxim-laptop>
	 <1291537161.2806.109.camel@edumazet-laptop>
	 <1291548233.2806.212.camel@edumazet-laptop>
	 <20101208.100528.193703457.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: maximlevitsky@gmail.com, linux1394-devel@lists.sourceforge.net,
	stefanr@s5r6.in-berlin.de, netdev@vger.kernel.org,
	kuznet@ms2.inr.ac.ru, jmorris@namei.org, kaber@trash.net
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f171.google.com ([209.85.215.171]:42773 "EHLO
	mail-ey0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755595Ab0LHSHk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Dec 2010 13:07:40 -0500
Received: by eyg5 with SMTP id 5so1160047eyg.2
        for <netdev@vger.kernel.org>; Wed, 08 Dec 2010 10:07:38 -0800 (PST)
In-Reply-To: <20101208.100528.193703457.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 08 d=C3=A9cembre 2010 =C3=A0 10:05 -0800, David Miller a =C3=
=A9crit :
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Sun, 05 Dec 2010 12:23:53 +0100
>=20
> > [PATCH] net: RCU conversion of dev_getbyhwaddr() and arp_ioctl()
> >=20
> > dev_getbyhwaddr() was called under RTNL.
> >=20
> > Rename it to dev_getbyhwaddr_rcu() and change all its caller to now=
 use
> > RCU locking instead of RTNL.
> >=20
> > Change arp_ioctl() to use RCU instead of RTNL locking.
> >=20
> > Note: this fix a dev refcount bug in llc
> >=20
> > Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
>=20
> Applied, thanks Eric.

Hmm, dont you want I resubmit it after the "llc: fix a device refcount
imbalance" patch pulled from net-2.6 ?

Sorry for the mess...


