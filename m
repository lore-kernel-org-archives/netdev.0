From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] sundance: get_stats proper locking
Date: Sat, 09 Oct 2010 09:24:12 -0700 (PDT)
Message-ID: <20101009.092412.42805633.davem@davemloft.net>
References: <20101009095346.GA12951@hera.kernel.org>
	<1286626621.2692.18.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: dkirjanov@kernel.org, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47533
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756388Ab0JIQXv convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 9 Oct 2010 12:23:51 -0400
In-Reply-To: <1286626621.2692.18.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Sat, 09 Oct 2010 14:17:01 +0200

> Le samedi 09 octobre 2010 =E0 09:53 +0000, Denis Kirjanov a =E9crit :
>> Add initial ethtool statistics support=20
>=20
> OK, I guess its time to add proper locking into sundance after all ;)
>=20
> [PATCH net-next] sundance: get_stats proper locking
>=20
> sundance get_stats() should not be run concurrently, add a lock to av=
oid
> potential losses.
>=20
> Note: Remove unused rx_lock field
>=20
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied.
