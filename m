From: Jean-Daniel Pauget <jd@disjunkt.com>
Subject: Re:  intermittant petabyte usage reported with broadcom nic
Date: Mon, 2 Apr 2007 12:31:48 +0200
Message-ID: <20070402103148.GB26022@disjunkt.com>
References: <20070402074108.GB8345@zip.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: CaT <cat@zip.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp19.orange.fr ([80.12.242.19]:40485 "EHLO smtp19.orange.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965396AbXDBKfx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 2 Apr 2007 06:35:53 -0400
Content-Disposition: inline
In-Reply-To: <20070402074108.GB8345@zip.com.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

    I don't know if a me-too may help you, but I have exactly the same=20
    trouble on a whole set of dell servers, all with bmx drivers (suse =
10.1
    kernel) and values fetched by an homebrew daemon and collected via =
rrd.

> uname -a
Linux toronto 2.6.16.27-0.6-smp #1 SMP Wed Dec 13 09:34:50 UTC 2006 x86=
_64=20
x86_64 x86_64 GNU/Linux

=2E../...
<6>Broadcom NetXtreme II Gigabit Ethernet Driver bnx2 v1.4.31 (January =
19, 2006)
<6>ACPI: PCI Interrupt 0000:09:00.0[A] -> GSI 16 (level, low) -> IRQ 16=
9
<6>usbcore: registered new driver hub
<6>eth0: Broadcom NetXtreme II BCM5708 1000Base-T (B2) PCI-X 64-bit 133=
MHz found at mem f4000000, IRQ 169, node addr 0015c5f18146
<6>ACPI: PCI Interrupt 0000:05:00.0[A] -> GSI 16 (level, low) -> IRQ 16=
9
<6>eth1: Broadcom NetXtreme II BCM5708 1000Base-T (B2) PCI-X 64-bit 133=
MHz found at mem f8000000, IRQ 169, node addr 0015c5f18144
=2E../...


On Mon, Apr 02, 2007 at 05:41:08PM +1000, CaT wrote:
> On Mon, Apr 02, 2007 at 12:13:00AM -0700, Andrew Morton wrote:
> > On Mon, 2 Apr 2007 11:43:19 +1000 CaT <cat@zip.com.au> wrote:
> >=20
> > > I take minute by minute snapshots of network traffic by sampling
> > > /proc/net/dev and most of the time everything works fine. Occasio=
nally
> > > though I get petabyte byte traffic and corresponding packet traff=
ic.

    on my side measures are performed on a 10sec frequency basis

> > How frequently?
>=20
> I can count about 6 over the past month.

    almost once a day per machine.

> > Are you able to provide some actual numbers (expected and actual=20
> > values),
> > so we can look at the bit patterns?

    I can patch my app in order to give you those exact numbers (I'm af=
raid=20
    not to be an rrd expert to extract real past values reported)
    on another side, I cannot really test new drivers on those machine =
just=20
    for those tests.

> > > This happens on an AMD64, dual core smp box with Broadcom NetXtre=
me=20
> > > II
> > > nics.
> >=20
> > What driver drivers that?  b44.c?
> bnx2

>=20
> > > The issue happens with both nics but at different times. The same
> > > sampling code runs on p4 boxes with ht on and e1000 nics without =
issues
> > > so I don't believe it's an issue with my code (famous last words =
:)

    exactly the same, just xeons instead of AMD.

--=20
    Jean-Daniel Pauget

    T=E9l: +33 (0)2 33 17 20 16
    2, rue Andr=E9 PELCA
    50580 Denneville-Plage
    France

