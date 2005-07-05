From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [TG3]: About hw coalescing infrastructure.
Date: Tue, 05 Jul 2005 18:14:59 +0200
Message-ID: <42CAB203.7050700@cosmosbay.com>
References: <42C9B8DB.7020403@cosmosbay.com>	<20050704.154712.63128211.davem@davemloft.net>	<42C9BE69.2070008@cosmosbay.com> <20050704.160034.55511095.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: quoted-printable
Cc: mchan@broadcom.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20050704.160034.55511095.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

David S. Miller a =E9crit :

> SMP system?  What platform and 570x chip revision?
>=20

dual opterons 248,
Ethernet controller: Broadcom Corporation NetXtreme BCM5702 Gigabit Ether=
net (rev 02)

> Does the stock driver in 2.6.12 hang as well?

Stock driver in 2.6.11 or 2.6.12 cause hangs (crashes ?) too, but no kern=
el mesages are logged on disk.
I think this is crashing in cache_grow() (slab code), not sure because I =
dont have access to the console.

The 2.6.13-rc1 tg3 driver seems to survive (running for 18 hours now), an=
d the cpu used by network activity
was cut down :)

rx-usecs: 500
rx-frames: 30
rx-usecs-irq: 500
rx-frames-irq: 20

tx-usecs: 490
tx-frames: 53
tx-usecs-irq: 490
tx-frames-irq: 5

About 1200 IRQ/second now, with 30000 recv packs/s and 25000 xmit pack/s

Thank you

Eric
