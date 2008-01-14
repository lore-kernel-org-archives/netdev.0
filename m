From: Adrian Bunk <bunk@kernel.org>
Subject: Re: [BUG] skge 0000:02:05: read data parity error
Date: Mon, 14 Jan 2008 23:01:05 +0200
Message-ID: <20080114210105.GG9847@does.not.exist>
References: <6101e8c40801141157j1ce7d3f0if2e4eb2344b6c844@mail.gmail.com> <20080114125200.28cb4c69@deepthought>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Oliver Pinter =?utf-8?B?KFBpbnTDqXIgT2xpdsOpcik=?=
	<oliver.pntr@gmail.com>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, gregkh@suse.de
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754213AbYANVCY@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20080114125200.28cb4c69@deepthought>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jan 14, 2008 at 12:52:00PM -0800, Stephen Hemminger wrote:
> On Mon, 14 Jan 2008 20:57:49 +0100
> "Oliver Pinter (Pint=C3=A9r Oliv=C3=A9r)" <oliver.pntr@gmail.com> wro=
te:
>=20
> > Hi All!
> >=20
> > It is fully reproductable under 2.6.22.15, 2.6.23.13 (all tainted a=
nd
> > not tainted [4 different kernel] ) and 2 different PC:
> >=20
> > [BUG] skge 0000:02:05: read data parity error
> > [BUG] skge 0000:02:05: read data parity error
> >=20
> > steps:
> > 1. login as root
> > 2. start mc
> > 3. cd /sys/bus/pci/drivers/skge/0000:02:05.0
> > 4. press F3 (mcview) on resource0
> > 5. the system hang up, without panic or bug ... only this message
> > printed 2x: [BUG] skge 0000:02:05: read data parity error
>=20
> This is not a bug.
>=20
> The hardware has some debug registers that if accessed cause a read
> back to the host. Since this can point anywhere, it will cause errors
> or system hang.
>=20
> The point is don't do it.

Is it really a good idea that _reading_ files under /sys can kill your=20
machine?

That sounds like a huge trap for people debugging their machine (or e.g=
=2E=20
forgetting to exclude /sys from their backup).

cu
Adrian

--=20

       "Is there not promise of rain?" Ling Tan asked suddenly out
        of the darkness. There had been need of rain for many days.
       "Only a promise," Lao Er said.
                                       Pearl S. Buck - Dragon Seed

--
To unsubscribe from this list: send the line "unsubscribe linux-kernel"=
 in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
Please read the FAQ at  http://www.tux.org/lkml/
