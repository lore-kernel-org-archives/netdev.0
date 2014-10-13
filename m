From: =?iso-8859-1?Q?Llu=EDs?= Batlle i Rossell <viric@viric.name>
Subject: Re: Regarding tx-nocache-copy in the Sheevaplug
Date: Mon, 13 Oct 2014 14:32:17 +0200
Message-ID: <20141013123217.GF1972@vicerveza.homeunix.net>
References: <20141013105246.GD1972@vicerveza.homeunix.net>
 <1413203171.9362.81.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Carles =?iso-8859-1?Q?Pag=E8s?= <page@cubata.homelinux.net>,
	linux-arm-kernel@lists.infradead.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1413203171.9362.81.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Oct 13, 2014 at 05:26:11AM -0700, Eric Dumazet wrote:
> On Mon, 2014-10-13 at 12:52 +0200, Llu=EDs Batlle i Rossell wrote:
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
> >=20
> > Enabling back this tx-nocache-copy (as it used to be before the pat=
ch) the
> > transfers work fine again. I think that most people, encountering t=
his problem,
> > completely disable the tx offload instead of enabling back this set=
ting.
> >=20
> > Is this an ARM kernel problem regarding this platform?
>=20
> Which NIC and driver is this exactly ?

According to dmesg in 3.10.1:
[    7.858872] mv643xx_eth: MV-643xx 10/100/1000 ethernet driver versio=
n 1.4
[    7.866001] mv643xx_eth_port mv643xx_eth_port.0 eth0: port 0 with MA=
C address 00:50:43:01:d1:bb

Regards,
Llu=EDs.
