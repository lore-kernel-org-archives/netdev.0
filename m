From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH 2/2] ipv4 routing: multipath with cache support,
 2.6.10-rc3
Date: Wed, 9 Feb 2005 13:17:10 -0800
Message-ID: <20050209131710.00315044.davem@davemloft.net>
References: <41C6B54F.2020604@einar-lueck.de>
	<20050202172333.4d0ad5f0.davem@davemloft.net>
	<420A1011.1030602@einar-lueck.de>
	<20050209120157.18dc75c1.davem@davemloft.net>
	<420A715D.7050106@einar-lueck.de>
	<20050209123004.2d65e1cf.davem@davemloft.net>
	<420A75BF.1080106@einar-lueck.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Cc: linux-kernel@vger.kernel.org, netdev@oss.sgi.com
To: Einar =?ISO-8859-1?Q?L=FCck?= <lkml@einar-lueck.de>
In-Reply-To: <420A75BF.1080106@einar-lueck.de>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 09 Feb 2005 21:42:39 +0100
Einar L=FCck <lkml@einar-lueck.de> wrote:

> We considered the routing case: in the routing case ip_route_input is c=
alled.=20
> In this case we just select the first route in the cache which is alway=
s the same=20
> (we ensure that). Consequently, the routing behaviour is not changed in=
 this case and=20
> remains in the way you like it.=20

Indeed.  You're right.  Let me re-review your second patch with
this new understanding in mind :-)
