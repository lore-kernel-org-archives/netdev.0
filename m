From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [TG3]: About hw coalescing infrastructure.
Date: Mon, 04 Jul 2005 16:00:34 -0700 (PDT)
Message-ID: <20050704.160034.55511095.davem@davemloft.net>
References: <42C9B8DB.7020403@cosmosbay.com>
	<20050704.154712.63128211.davem@davemloft.net>
	<42C9BE69.2070008@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: quoted-printable
Cc: mchan@broadcom.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: dada1@cosmosbay.com
In-Reply-To: <42C9BE69.2070008@cosmosbay.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <dada1@cosmosbay.com>
Date: Tue, 05 Jul 2005 00:55:37 +0200

> David S. Miller a =E9crit :
>=20
> > Please don't ever do stuff like that :-(  That makes the driver
> > version, and any other information you report completely meaningless
> > and useless.  You've just wasted a lot of our time.
> >=20
>=20
> Yes. But if you dont want us to test your patches, dont send them to
> the list.

The case here is that you didn't even mention that you had
the patch applied.  If you don't say what changes you've applied
to the stock driver we can't properly debug anything.

> For your information, 2.6.13-rc1 locks too.
>=20
> Very easy way to lock it :
>=20
> ping -f some_destination.

SMP system?  What platform and 570x chip revision?

Does the stock driver in 2.6.12 hang as well?
