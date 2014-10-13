From: =?iso-8859-1?Q?Llu=EDs?= Batlle i Rossell <viric@viric.name>
Subject: Re: Regarding tx-nocache-copy in the Sheevaplug
Date: Mon, 13 Oct 2014 16:31:38 +0200
Message-ID: <20141013143138.GJ1972@vicerveza.homeunix.net>
References: <20141013105246.GD1972@vicerveza.homeunix.net>
 <20141013142156.GE26864@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Carles =?iso-8859-1?Q?Pag=E8s?= <page@cubata.homelinux.net>,
	linux-arm-kernel@lists.infradead.org
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20141013142156.GE26864@lunn.ch>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Enabling tx offload and disabling tx-nocache-copy, making the machine *=
send* a
lot of ssh traffic (sftp for example) makes ssh fail HMAC. It's quite e=
asy to
reproduce here.

As for the hardware, it's an old sheevaplug board.

On Mon, Oct 13, 2014 at 04:21:56PM +0200, Andrew Lunn wrote:
> On Mon, Oct 13, 2014 at 12:52:46PM +0200, Llu=EDs Batlle i Rossell wr=
ote:
> > Hello,
> >=20
> > on the 7th of January 2014 ths patch was applied:
> > https://lkml.org/lkml/2014/1/7/307
> >=20
> > [PATCH v2] net: Do not enable tx-nocache-copy by default
> >        =20
> > In the Sheevaplug (ARM Feroceon 88FR131 from Marvell) this made pac=
kets to be
> > sent corrupted. I think this machine has something special about th=
e cache.
>=20
> Hi Llu=EDs
>=20
> Please could you describe your test setup. I would like to try to
> reproduce the problem. I have a machine based on kirkwood 6282 and th=
e
> same ethernet.
>=20
> Thanks
> 	Andrew
