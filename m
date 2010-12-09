From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: Abstract away all dst_entry metrics accesses.
Date: Thu, 09 Dec 2010 08:18:36 +0100
Message-ID: <1291879116.2795.51.camel@edumazet-laptop>
References: <20101208.214834.226775385.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:52939 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751043Ab0LIHSl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Dec 2010 02:18:41 -0500
Received: by wwa36 with SMTP id 36so2116105wwa.1
        for <netdev@vger.kernel.org>; Wed, 08 Dec 2010 23:18:40 -0800 (PST)
In-Reply-To: <20101208.214834.226775385.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 08 d=C3=A9cembre 2010 =C3=A0 21:48 -0800, David Miller a =C3=
=A9crit :
> Use helper functions to hide all direct accesses, especially writes,
> to dst_entry metrics values.
>=20
> This will allow us to:
>=20
> 1) More easily change how the metrics are stored.
>=20
> 2) Implement COW for metrics.
>=20
> In particular this will help us put metrics into the inetpeer
> cache if that is what we end up doing.  We can make the _metrics
> member a pointer instead of an array, initially have it point
> at the read-only metrics in the FIB, and then on the first set
> grab an inetpeer entry and point the _metrics member there.
>=20
> Signed-off-by: David S. Miller <davem@davemloft.net>

Very exciting, thanks David !

Acked-by: Eric Dumazet <eric.dumazet@gmail.com>


