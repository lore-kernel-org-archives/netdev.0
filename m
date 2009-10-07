From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] udp: extend hash tables to 256 slots
Date: Tue, 06 Oct 2009 22:35:18 -0700 (PDT)
Message-ID: <20091006.223518.235187454.davem@davemloft.net>
References: <4ACC1C73.1010506@gmail.com>
	<20091006.222935.231081303.davem@davemloft.net>
	<4ACC2815.7010101@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: rick.jones2@hp.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34233
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755238AbZJGFfY convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 7 Oct 2009 01:35:24 -0400
In-Reply-To: <4ACC2815.7010101@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 07 Oct 2009 07:33:09 +0200

> David Miller a =E9crit :
>>=20
>> That's incredible that it's been that low for so long :-)
>>=20
>> Bug please, dynamically size this thing, maybe with a cap of say 64K
>> to start with.  If you don't have time for it I'll take care of this=
=2E
>=20
>=20
> Well, we can not exceed 65536 slots, given the nature of UDP protocol=
 :)
>=20
> Do you mean a static allocation at boot time with a size that can be=20
> overidden in cmdline(like tcp and ip route),
>=20
> or something that can dynamically extends hash table at runtime ?

I mean dynamically size it between 256 and 65536 slots at boot time,
based upon memory size.
