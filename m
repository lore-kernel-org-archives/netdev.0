From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [BUG] skge 0000:02:05: read data parity error
Date: Mon, 14 Jan 2008 12:52:00 -0800
Message-ID: <20080114125200.28cb4c69@deepthought>
References: <6101e8c40801141157j1ce7d3f0if2e4eb2344b6c844@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	oliver.pntr@gmail.com
To: "Oliver Pinter (=?UTF-8?B?UGludMOpciBPbGl2w6ly?=)"
	<oliver.pntr@gmail.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754085AbYANUyv@vger.kernel.org>
In-Reply-To: <6101e8c40801141157j1ce7d3f0if2e4eb2344b6c844@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 14 Jan 2008 20:57:49 +0100
"Oliver Pinter (Pint=C3=A9r Oliv=C3=A9r)" <oliver.pntr@gmail.com> wrote=
:

> Hi All!
>=20
> It is fully reproductable under 2.6.22.15, 2.6.23.13 (all tainted and
> not tainted [4 different kernel] ) and 2 different PC:
>=20
> [BUG] skge 0000:02:05: read data parity error
> [BUG] skge 0000:02:05: read data parity error
>=20
> steps:
> 1. login as root
> 2. start mc
> 3. cd /sys/bus/pci/drivers/skge/0000:02:05.0
> 4. press F3 (mcview) on resource0
> 5. the system hang up, without panic or bug ... only this message
> printed 2x: [BUG] skge 0000:02:05: read data parity error
>=20

This is not a bug.

The hardware has some debug registers that if accessed cause a read
back to the host. Since this can point anywhere, it will cause errors
or system hang.

The point is don't do it.

--=20
Stephen Hemminger <stephen.hemminger@vyatta.com>
--
To unsubscribe from this list: send the line "unsubscribe linux-kernel"=
 in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
Please read the FAQ at  http://www.tux.org/lkml/
