From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next-2.6] fix bonding: allow arp_ip_targets on separate
 vlans to use arp validation
Date: Thu, 07 Jan 2010 09:37:58 +0100
Message-ID: <4B459D66.5060307@gmail.com>
References: <65634d660911201528k5a07135el471b65fff9dd7c9d@mail.gmail.com> <20091120154046.67252d23@nehalam> <65634d660912171304p751e1698mbc9de50dade4317d@mail.gmail.com> <65634d661001051732qd64e79dt37e6247f8b0dc863@mail.gmail.com> <4B44258C.2050302@gmail.com> <4B44D89B.8070006@gmail.com> <4B44FC2B.4090505@gmail.com> <20100106225637.GC6490@gospo.rdu.redhat.com> <13683.1262822029@death.nxdomain.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Andy Gospodarek <andy@greyhouse.net>,
	Tom Herbert <therbert@google.com>,
	David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:57049 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751345Ab0AGIiN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jan 2010 03:38:13 -0500
In-Reply-To: <13683.1262822029@death.nxdomain.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 07/01/2010 00:53, Jay Vosburgh a =E9crit :
> Andy Gospodarek <andy@greyhouse.net> wrote:
>=20
>> This patch fixes up a problem with found with commit
>> 1f3c8804acba841b5573b953f5560d2683d2db0d.  The original change
>> overloaded null_or_orig, but doing that prevented any packet handler=
s
>> that were not tied to a specific device (i.e. ptype->dev =3D=3D NULL=
) from
>> ever receiving any frames.
>>
>> The null_or_orig variable cannot be overloaded, and must be kept as =
NULL
>> to prevent the frame from being ignored by packet handlers designed =
to
>> accept frames on any interface.
>>
>> Signed-off-by: Andy Gospodarek <andy@greyhouse.net>
>=20
> 	Tested, and it appears to work fine.  Tcpdump also appears to
> behave rationally.
>=20
> 	-J
>=20
> Signed-off-by: Jay Vosburgh <fubar@us.ibm.com>

Tested as well on my machine, I confirm this fixes the problem I had.

Acked-by: Eric Dumazet <eric.dumazet@gmail.com>

Thanks guys !
