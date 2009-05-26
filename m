From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: txq_trans_update() helper
Date: Mon, 25 May 2009 22:58:19 -0700 (PDT)
Message-ID: <20090525.225819.119681427.davem@davemloft.net>
References: <4A1B8007.1000703@gmail.com>
	<20090525.223827.256643479.davem@davemloft.net>
	<4A1B84AD.1040707@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59457
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753877AbZEZF6U convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 May 2009 01:58:20 -0400
In-Reply-To: <4A1B84AD.1040707@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 26 May 2009 07:57:01 +0200

> David Miller a =E9crit :
>> Closing brace here has strange indentation, which doesn't match
>> the statement of the openning brace.
>>=20
>> Please fix this, thanks.
>=20
> Oops you are right, this is a leftover.
>=20
> [PATCH] net: txq_trans_update() helper
>=20
> We would like to get rid of netdev->trans_start =3D jiffies; that abo=
ut all net
> drivers have to use in their start_xmit() function, and use txq->tran=
s_start
> instead.
>=20
> This can be done generically in core network, as suggested by David.
>=20
> Some devices, (particularly loopback) dont need trans_start update, b=
ecause
> they dont have transmit watchdog. We could add a new device flag, or =
rely
> on fact that txq->tran_start can be updated is txq->xmit_lock_owner i=
s
> different than -1. Use a helper function to hide our choice.
>=20
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied, thanks a lot Eric.
