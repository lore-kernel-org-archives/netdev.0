From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] net: dummy: allocate devices with alloc_netdev_id
Date: Mon, 06 Jun 2011 20:38:51 -0700 (PDT)
Message-ID: <20110606.203851.1325136360346365091.davem@davemloft.net>
References: <1307410786-19110-1-git-send-email-lucian.grijincu@gmail.com>
	<1307410786-19110-3-git-send-email-lucian.grijincu@gmail.com>
	<1307416765.2642.37.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: lucian.grijincu@gmail.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:60288 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754100Ab1FGDiz convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Jun 2011 23:38:55 -0400
In-Reply-To: <1307416765.2642.37.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 07 Jun 2011 05:19:25 +0200

> Le mardi 07 juin 2011 =E0 04:39 +0300, Lucian Adrian Grijincu a =E9cr=
it :
>> The most like case is that no one else is registering devices with a
>> name like "dummy%d".
>>=20
>> We can bring the complexity down by replacing:
>> - alloc_netdev_id which is O(N) with
>> - alloc_netdev_id which, on the average case, is O(1).
>>=20
>> $ time modprobe dummy numdummies=3D5000
>> - with alloc_netdev   : 9.50s
>> - with alloc_netdev_id: 3.50s
>>=20
>> NOTE: Stats generated on a heavily patched 3.0-rc1 which replaces th=
e
>>       current O(N^2) sysctl algorithm with a better one.
>=20
> Yes, and disabled hotplug I guess.
>=20
> Dont try this on a random computer ;)
>=20
> # time modprobe dummy numdummies=3D5000
>=20
> real	4m45.646s
> user	0m0.000s
> sys	0m12.440s
> # uptime
>  05:13:46 up 13:30,  3 users,  load average: 11221.41, 6918.70, 3101.=
12

ROFL
