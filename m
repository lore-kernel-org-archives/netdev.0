From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [patch] vlan: add rtnl_dereference() annotations
Date: Wed, 14 Dec 2011 08:01:00 +0100
Message-ID: <1323846060.2846.23.camel@edumazet-laptop>
References: <20111214062943.GD7499@elgon.mountain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Patrick McHardy <kaber@trash.net>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org, Jiri Pirko <jpirko@redhat.com>
To: Dan Carpenter <dan.carpenter@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:35368 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753620Ab1LNHBG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Dec 2011 02:01:06 -0500
In-Reply-To: <20111214062943.GD7499@elgon.mountain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 14 d=C3=A9cembre 2011 =C3=A0 09:29 +0300, Dan Carpenter a =C3=
=A9crit :
> The original code generates a Sparse warning:
> net/8021q/vlan_core.c:336:9:
> 	error: incompatible types in comparison expression (different addres=
s spaces)
>=20
> It's ok to dereference __rcu pointers here because we are holding the
> RTNL lock.  I've added some calls to rtnl_dereference() to silence th=
e
> warning.
>=20
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
> ---
> I haven't tested this, and I'm not super familiar with this code.
> Please review it carefully.
>=20

Acked-by: Eric Dumazet <eric.dumazet@gmail.com>
