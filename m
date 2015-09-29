From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v4 net-next 0/2] ipv4: Hash-based multipath routing
Date: Mon, 28 Sep 2015 19:55:41 -0700 (PDT)
Message-ID: <20150928.195541.2230338616645241909.davem@davemloft.net>
References: <1443037777-25390-1-git-send-email-pch@ordbogen.com>
	<20150928.193355.515603960827814980.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net
To: pch@ordbogen.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52677 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932091AbbI2Czm convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Sep 2015 22:55:42 -0400
In-Reply-To: <20150928.193355.515603960827814980.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: David Miller <davem@davemloft.net>
Date: Mon, 28 Sep 2015 19:33:55 -0700 (PDT)

> From: Peter N=F8rlund <pch@ordbogen.com>
> Date: Wed, 23 Sep 2015 21:49:35 +0200
>=20
>> When the routing cache was removed in 3.6, the IPv4 multipath algori=
thm changed
>> from more or less being destination-based into being quasi-random pe=
r-packet
>> scheduling. This increases the risk of out-of-order packets and make=
s it
>> impossible to use multipath together with anycast services.
>>=20
>> This patch series replaces the old implementation with flow-based lo=
ad
>> balancing based on a hash over the source and destination addresses.
>=20
> This isn't perfect but it's a significant step in the right direction=
=2E
> So I'm going to apply this to net-next now and we can make incrementa=
l
> improvements upon it.

Actually, I had to revert, this doesn't build:

[davem@localhost net-next]$ make -s -j8
Setup is 16876 bytes (padded to 16896 bytes).
System is 10011 kB
CRC 324f2811
Kernel: arch/x86/boot/bzImage is ready  (#337)
ERROR: "__ip_route_output_key_hash" [net/dccp/dccp_ipv4.ko] undefined!
scripts/Makefile.modpost:90: recipe for target '__modpost' failed
make[1]: *** [__modpost] Error 1
Makefile:1095: recipe for target 'modules' failed
make: *** [modules] Error 2
