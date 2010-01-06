From: David Miller <davem@davemloft.net>
Subject: Re: [BUG net-next-2.6] Had to revert bonding: allow arp_ip_targets
 on separate vlans to use arp validation
Date: Wed, 06 Jan 2010 13:38:11 -0800 (PST)
Message-ID: <20100106.133811.207901772.davem@davemloft.net>
References: <4B44258C.2050302@gmail.com>
	<4B44D89B.8070006@gmail.com>
	<4B44FC2B.4090505@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: therbert@google.com, netdev@vger.kernel.org, fubar@us.ibm.com,
	andy@greyhouse.net
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41349
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755514Ab0AFViK convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Jan 2010 16:38:10 -0500
In-Reply-To: <4B44FC2B.4090505@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 06 Jan 2010 22:10:03 +0100

> Le 06/01/2010 19:38, Eric Dumazet a =E9crit :
>>=20
>> (net-next-2.6 doesnt work well on my bond/vlan setup, I suspect I ne=
ed a bisection)
>=20
> David, I had to revert 1f3c8804acba841b5573b953f5560d2683d2db0d
> (bonding: allow arp_ip_targets on separate vlans to use arp validatio=
n)
>=20
> Or else, my vlan devices dont work (unfortunatly I dont have much tim=
e
> these days to debug the thing)

I bet this is the same issue Jay was running into, and he
ACK'd the patch anyways. :-)

This is why I wanted full testing and feedback before committing this
change.

Unless I see a fix in the next day I'm reverting from net-next-2.6

