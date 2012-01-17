From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [patch] inetpeer: initialize ->redirect_genid in inet_getpeer()
Date: Tue, 17 Jan 2012 21:58:06 +0100
Message-ID: <1326833886.2606.6.camel@edumazet-laptop>
References: <20120117204843.GA20999@elgon.mountain>
	 <20120117.155231.1181293038505383400.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: dan.carpenter@oracle.com, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f174.google.com ([209.85.212.174]:55664 "EHLO
	mail-wi0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755631Ab2AQU6L (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Jan 2012 15:58:11 -0500
In-Reply-To: <20120117.155231.1181293038505383400.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 17 janvier 2012 =C3=A0 15:52 -0500, David Miller a =C3=A9crit =
:
> From: Dan Carpenter <dan.carpenter@oracle.com>
> Date: Tue, 17 Jan 2012 23:48:43 +0300
>=20
> > kmemcheck complains that ->redirect_genid doesn't get initialized.
> > Presumably it should be set to zero.
> >=20
> > Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
>=20
> It's a "don't care" until we actually get a redirect, but I've applie=
d
> your patch nonetheless.
>=20

;)
