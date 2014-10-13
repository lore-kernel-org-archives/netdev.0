From: =?iso-8859-1?Q?Llu=EDs?= Batlle i Rossell <viric@viric.name>
Subject: Re: Regarding tx-nocache-copy in the Sheevaplug
Date: Mon, 13 Oct 2014 17:48:07 +0200
Message-ID: <20141013154807.GN1972@vicerveza.homeunix.net>
References: <20141013105246.GD1972@vicerveza.homeunix.net>
 <20141013142156.GE26864@lunn.ch>
 <20141013143138.GJ1972@vicerveza.homeunix.net>
 <1413211759.9362.103.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ezequiel Garcia <ezequiel.garcia@free-electrons.com>,
	Andrew Lunn <andrew@lunn.ch>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org,
	Carles =?iso-8859-1?Q?Pag=E8s?= <page@cubata.homelinux.net>,
	linux-arm-kernel@lists.infradead.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1413211759.9362.103.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Oct 13, 2014 at 07:49:19AM -0700, Eric Dumazet wrote:
> On Mon, 2014-10-13 at 16:31 +0200, Llu=EDs Batlle i Rossell wrote:
> > Enabling tx offload and disabling tx-nocache-copy, making the machi=
ne *send* a
> > lot of ssh traffic (sftp for example) makes ssh fail HMAC. It's qui=
te easy to
> > reproduce here.
> >=20
> > As for the hardware, it's an old sheevaplug board.
>=20
>=20
> Have you tried disabling TSO only, and are you using the latest kerne=
l ?
>=20
> Ezequiel Garcia added lot of changes recently.
>=20
>=20

Is TSO TCP segmentation offload? It's disabled. The kernel is 3.16.3 (d=
ebian).
https://packages.debian.org/testing/kernel/linux-image-3.16-2-kirkwood
