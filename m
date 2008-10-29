From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] udp: RCU handling for Unicast packets.
Date: Wed, 29 Oct 2008 02:17:27 -0700 (PDT)
Message-ID: <20081029.021727.187214227.davem@davemloft.net>
References: <20081028.220536.183082966.davem@davemloft.net>
	<49081D67.3050502@cosmosbay.com>
	<49082718.2030201@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: shemminger@vyatta.com, benny+usenet@amorsen.dk, minyard@acm.org,
	netdev@vger.kernel.org, paulmck@linux.vnet.ibm.com,
	cl@linux-foundation.org, a.p.zijlstra@chello.nl,
	johnpol@2ka.mipt.ru, christian@myri.com
To: dada1@cosmosbay.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60946
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752319AbYJ2JRx convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 29 Oct 2008 05:17:53 -0400
In-Reply-To: <49082718.2030201@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <dada1@cosmosbay.com>
Date: Wed, 29 Oct 2008 10:04:24 +0100

> Eric Dumazet a =E9crit :
> > David Miller a =E9crit :
> >> From: Eric Dumazet <dada1@cosmosbay.com>
> >> Date: Tue, 28 Oct 2008 23:45:15 +0100
> >>
> >>> I will submit a new patch serie tomorrow, with :
> >>>
> >>> Patch 1 : spinlocks instead of rwlocks, and bug spotted by Christ=
ian Bell
> >>>
> >>> Patch 2 : splited on two parts (2 & 3) , one for IPV4, one for IP=
V6,=20
> >>
> >> I very much look forward to this :-)
> >>
> >> I like these changes and can't wait to add them to net-next-2.6
> >=20
>=20
> Please find updated patch 2
>=20
> Missing check in __udp6_lib_lookup() was added,
> and based on spinlock version ([PATCH] udp: introduce struct udp_tabl=
e and multiple spinlocks)

Applied, thanks Eric.
