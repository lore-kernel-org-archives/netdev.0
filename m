From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next-2.6] inetpeer: lower false sharing effect
Date: Fri, 10 Jun 2011 06:47:50 +0200
Message-ID: <1307681270.3210.9.camel@edumazet-laptop>
References: <1307600810.3980.85.camel@edumazet-laptop>
	 <1307664235.17300.44.camel@schen9-DESK>
	 <20110609.204330.2090335955971650557.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: tim.c.chen@linux.intel.com, netdev@vger.kernel.org,
	andi@firstfloor.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:32872 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750733Ab1FJErz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Jun 2011 00:47:55 -0400
Received: by wya21 with SMTP id 21so1590110wya.19
        for <netdev@vger.kernel.org>; Thu, 09 Jun 2011 21:47:54 -0700 (PDT)
In-Reply-To: <20110609.204330.2090335955971650557.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 09 juin 2011 =C3=A0 20:43 -0700, David Miller a =C3=A9crit :
> From: Tim Chen <tim.c.chen@linux.intel.com>
> Date: Thu, 09 Jun 2011 17:03:55 -0700
>=20
> > When I retest with original 3.0-rc2 kernel, inet_putpeer no longer =
shows
> > up, wonder if dst->peer was not set for some reason.=20
>=20
> The overhead will only show up if an inetpeer entry exists for
> the destination IP address.
>=20
> You can force one to be created, for example, by making a TCP
> connection to that destination.

Or sending big frames, to force ip fragmentation (we store the id
generator in inetpeer cache)



