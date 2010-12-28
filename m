From: David Miller <davem@davemloft.net>
Subject: Re: [patch] net/unix: do not forget to autobind in standard case
Date: Tue, 28 Dec 2010 13:58:05 -0800 (PST)
Message-ID: <20101228.135805.260098055.davem@davemloft.net>
References: <alpine.LNX.2.01.1012250107330.22521@obet.zrqbmnf.qr>
	<1293554655.20573.5.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: jengelh@medozas.de, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57714
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751642Ab0L1V5f convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 28 Dec 2010 16:57:35 -0500
In-Reply-To: <1293554655.20573.5.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 28 Dec 2010 17:44:15 +0100

> Le samedi 25 d=E9cembre 2010 =E0 01:08 +0100, Jan Engelhardt a =E9cri=
t :
>> parent 67514fc40bbec857018cbc689d440282b75551db (v2.6.37-rc1-229-g67=
514fc)
>> commit 973bdc63c6aba703dd7b62a6ec7ae4bab7847731
>> Author: Jan Engelhardt <jengelh@medozas.de>
>> Date:   Sat Dec 25 00:50:59 2010 +0100
>>=20
>> net/unix: do not forget to autobind in standard case
>>=20
>> A program using recvmsg on an AF_LOCAL datagram socket does not
>> receive the peer's address when the remote has not issued a bind. Th=
is
>> makes it impossible to send messages back. (But the same _does_ work
>> in IP.) The cause for this is because autobinding was only done when
>> credential passing was requested.
>>=20
>=20
> It would be good you did some research and tell us why current code
> tests SOCK_PASSCRED
>=20
> There must be a reason this restrictive code is here, dont you think =
?

I definitely think that test is intentional.  I'm not applying this
without at least some basic research.
