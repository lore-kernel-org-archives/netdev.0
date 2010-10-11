From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net dst: use a percpu_counter to track entries
Date: Mon, 11 Oct 2010 16:10:38 -0700 (PDT)
Message-ID: <20101011.161038.189691429.davem@davemloft.net>
References: <1286555854.2959.605.camel@edumazet-laptop>
	<20101011.130758.70192030.davem@davemloft.net>
	<1286832573.30423.93.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52734
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751523Ab0JKXKQ convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 Oct 2010 19:10:16 -0400
In-Reply-To: <1286832573.30423.93.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 11 Oct 2010 23:29:33 +0200

> Le lundi 11 octobre 2010 =E0 13:07 -0700, David Miller a =E9crit :
>=20
>> When I first read the subject line for this patch, I was
>> scared, because I thought you were using a percpu counter
>> for dst entry refcounts :-)
>>=20
>> Anyways this is fine, applied, thanks!
>=20
> I though about a crazy idea for loopback device (but not a percpu
> counter for dst refcounts)
>=20
> Add a cpu field somewhere so that each cpu manipulates a different ds=
t.
>=20
> Or maybe just never cache such dst, so that each tcp socket uses its =
own
> dst.

We could even make the cpu (in lieu of a socket) a key in the lookup,
but that would complicate handling things like PMTU indications and
redirects.
