From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [RFC, PATCH] IPV6 : add 64 bits components in struct in6_addr
 to speedup ipv6_addr_equal() & ipv6_addr_any()
Date: Mon, 30 Apr 2007 21:08:45 +0200
Message-ID: <46363EBD.1020102@cosmosbay.com>
References: <20070430162851.ca3c7869.dada1@cosmosbay.com>	<463618DB.7020309@hp.com> <20070430.115937.104035556.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: brian.haley@hp.com, yoshfuji@linux-ipv6.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([86.65.150.130]:59500 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1946654AbXD3TJD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Apr 2007 15:09:03 -0400
In-Reply-To: <20070430.115937.104035556.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller a =E9crit :
> From: Brian Haley <brian.haley@hp.com>
> Date: Mon, 30 Apr 2007 12:27:07 -0400
>=20
>> The problem is that drivers don't necessarily align the address on t=
he=20
>> correct boundary, so on some 64-bit arches this could be fatal.  The=
re's=20
>> ways around it since I did it in a previous life, but you'd need to =
copy=20
>> the addresses and hide them in the skb in the rare case, neither of=20
>> which is a great thing to do.
>=20
> Yes, the majority of the network drivers are only ensuring 32-bit
> alignment after the ethernet header currently on receive.  They
> were designed with ipv4 in mind long ago and then the logic just
> gets copied everywhere.
>=20
>=20

Yes I see...

Maybe we could at least define a 'struct in6_addr_k' for internal struc=
tures=20
only, to speedup some parts of IPV6 stack.



