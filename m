From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ehea: restore multicast and rx_errors fields
Date: Thu, 08 Mar 2012 00:23:29 -0800 (PST)
Message-ID: <20120308.002329.1825008264770615652.davem@davemloft.net>
References: <1331099201.2474.59.camel@edumazet-laptop>
	<20120307141704.GA11924@oc1711230544.ibm.com>
	<1331131491.2474.71.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: cascardo@linux.vnet.ibm.com, netdev@vger.kernel.org,
	anton@samba.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:58857 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752836Ab2CHIXi convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Mar 2012 03:23:38 -0500
In-Reply-To: <1331131491.2474.71.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 07 Mar 2012 06:44:51 -0800

> Le mercredi 07 mars 2012 =E0 11:17 -0300, Thadeu Lima de Souza Cascar=
do a
> =E9crit :
>=20
>> Tested, in particular, the multicast stat, pinging 224.0.0.1 from
>> another machine.
>>=20
>> Thanks.
>> Cascardo.
>>=20
>> Acked-by: Thadeu Lima de Souza Cascardo <cascardo@linux.vnet.ibm.com=
>
>> Tested-by: Thadeu Lima de Souza Cascardo <cascardo@linux.vnet.ibm.co=
m>
>>=20
>=20
> Thanks !
>=20
> Maybe you could submit a followup patch, to remove the port->stats
> structure and only use two u64 fields, since this driver only use two
> counters in its private "stats" ?

Yes that sounds like a good idea.

I've applied Eric's patch to 'net'.
