From: =?iso-8859-1?Q?J=F6rn?= Engel <joern@wohnheim.fh-wedel.de>
Subject: Re: [RFC] Patch to Abstract Ethernet PHY support (using driver model)
Date: Fri, 14 Jan 2005 15:55:18 +0100
Message-ID: <20050114145518.GA21418@wohnheim.fh-wedel.de>
References: <FC6D9B81-5514-11D9-8D51-000393C30512@freescale.com> <A3A281FF-5525-11D9-80ED-000393C30512@freescale.com> <20050106070245.GA6539@gate.ebshome.net> <61A37C72-659C-11D9-8D70-000393C30512@freescale.com> <20050113212152.GA16041@gate.ebshome.net> <20050113215808.GA15124@wohnheim.fh-wedel.de> <20050114010016.GA16635@gate.ebshome.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: quoted-printable
Return-path: <netdev-bounce@oss.sgi.com>
To: Andy Fleming <afleming@freescale.com>,
        Kumar Gala <kumar.gala@freescale.com>, Netdev <netdev@oss.sgi.com>,
        Embedded PPC Linux list <linuxppc-embedded@ozlabs.org>
Content-Disposition: inline
In-Reply-To: <20050114010016.GA16635@gate.ebshome.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 13 January 2005 17:00:16 -0800, Eugene Surovegin wrote:
> On Thu, Jan 13, 2005 at 10:58:08PM +0100, J?rn Engel wrote:
> >=20
> > http://www.broadcom.com/collateral/pb/5325-PB05-R.pdf
> >=20
> > With some thinking and very little code, you can use this neat chip
> > almost like a normal phy.
>=20
> Yeah, but why would I want to? If you connect your MAC to any 5 PHYs=20
> my statement still stands, if directly to MII you don't need any PHY=20
> stuff at all, because link is always ON and speed/duplex is fixed.
>=20
> In fact, we use different switch chips connected to PPC4xx directly.=20
> In this situation, in my NAPI IBM EMAC driver I just have special=20
> "PHY-less" case which is trivial "fixed settings" one. And all this=20
> PHY lib is completely unneeded bloat.

Wrt. the proposed PHY lib, I agree.  Didn't even bother to look at the
code, it's mere size said enough.

But an abstraction different from drivers/net/mii.c is needed to
handle the 5325 chip.  Or, you could have the special cases all over
in your code, but that's a) ugly and b) more code.  I used to have
such a mess and after doing the proper abstraction, it line count went
down.

J=F6rn

--=20
Time? What's that? Time is only worth what you do with it.
-- Theo de Raadt
