From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] fix bonding: allow arp_ip_targets on
 separate vlans to use arp validation
Date: Thu, 07 Jan 2010 00:41:27 -0800 (PST)
Message-ID: <20100107.004127.77258555.davem@davemloft.net>
References: <20100106225637.GC6490@gospo.rdu.redhat.com>
	<13683.1262822029@death.nxdomain.ibm.com>
	<4B459D66.5060307@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: fubar@us.ibm.com, andy@greyhouse.net, therbert@google.com,
	netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57503
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755660Ab0AGIlT convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Jan 2010 03:41:19 -0500
In-Reply-To: <4B459D66.5060307@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 07 Jan 2010 09:37:58 +0100

> Le 07/01/2010 00:53, Jay Vosburgh a =E9crit :
>> Andy Gospodarek <andy@greyhouse.net> wrote:
>>=20
>>> This patch fixes up a problem with found with commit
>>> 1f3c8804acba841b5573b953f5560d2683d2db0d.  The original change
>>> overloaded null_or_orig, but doing that prevented any packet handle=
rs
>>> that were not tied to a specific device (i.e. ptype->dev =3D=3D NUL=
L) from
>>> ever receiving any frames.
>>>
>>> The null_or_orig variable cannot be overloaded, and must be kept as=
 NULL
>>> to prevent the frame from being ignored by packet handlers designed=
 to
>>> accept frames on any interface.
>>>
>>> Signed-off-by: Andy Gospodarek <andy@greyhouse.net>
>>=20
>> 	Tested, and it appears to work fine.  Tcpdump also appears to
>> behave rationally.
>>=20
>> 	-J
>>=20
>> Signed-off-by: Jay Vosburgh <fubar@us.ibm.com>
>=20
> Tested as well on my machine, I confirm this fixes the problem I had.
>=20
> Acked-by: Eric Dumazet <eric.dumazet@gmail.com>

Thanks I'll add this to net-next-2.6 to fix the problem.
