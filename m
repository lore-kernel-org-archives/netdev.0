From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] udp_diag: Make it module when ipv6 is a module
Date: Sat, 10 Dec 2011 13:15:43 -0500 (EST)
Message-ID: <20111210.131543.1548975355099228502.davem@davemloft.net>
References: <4EE32167.2080202@parallels.com>
	<4EE32777.2030003@parallels.com>
	<1323514820.4016.15.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: xemul@parallels.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:51773 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750785Ab1LJSPs convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 10 Dec 2011 13:15:48 -0500
In-Reply-To: <1323514820.4016.15.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Sat, 10 Dec 2011 12:00:20 +0100

> Le samedi 10 d=E9cembre 2011 =E0 13:33 +0400, Pavel Emelyanov a =E9cr=
it :
>> Eric Dumazet reported, that when inet_diag is built-in the udp_diag =
also goes
>> built-in and when ipv6 is a module the udp6 lookup symbol is not fou=
nd.
>>=20
>>   LD      .tmp_vmlinux1
>> net/built-in.o: In function `udp_dump_one':
>> udp_diag.c:(.text+0xa2b40): undefined reference to `__udp6_lib_looku=
p'
>> make: *** [.tmp_vmlinux1] Erreur 1
>>=20
>> Fix this by making udp diag build mode depend on both -- inet diag a=
nd ipv6.
>>=20
>> Reported-by: Eric Dumazet <eric.dumazet@gmail.com>
>> Signed-off-by: Pavel Emelyanov <xemul@parallels.com>
=2E..
> Acked-by: Eric Dumazet <eric.dumazet@gmail.com>
>=20

Applied.
