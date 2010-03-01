From: M G Berberich <berberic@fmi.uni-passau.de>
Subject: Re: 2.6.33 dies on modprobe
Date: Mon, 1 Mar 2010 10:07:08 +0100
Message-ID: <20100301090708.GF17929@forwiss.uni-passau.de>
References: <20100228221257.GA8858@invalid> <2375c9f91002282022n29e83858jd8cadbb2e664b436@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
To: =?iso-8859-1?Q?Am=E9rico?= Wang <xiyou.wangcong@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <2375c9f91002282022n29e83858jd8cadbb2e664b436@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

Am Montag, den 01. M=C3=A4rz schrieb Am=C3=A9rico Wang:
> On Mon, Mar 1, 2010 at 6:12 AM, M G Berberich
> <berberic@fmi.uni-passau.de> wrote:

> > I tried to build a 2.6.33 kernel but on boot it dies on modprobe
> > (kernel-Oops). This might be the result of faulty config, but I'm
> > totaly clueless what's the fault.
> >
> > The kernel starts up fine and mounts the root-filesystem, but then
> > dies on the first modprobe executed. I can boot it with init=3D/bin=
/bash
> > and get a working bash (until I do modprobe on any module).
> >
> > System is a Gigabyte M55S-S3 rev 2.0 (nForce 550) with an AMD Athlo=
n64
> > X2 5000+ and amd64-kernel architecture. kernel-sources are from
> > kernel.org.

> It seems something is wrong with forcedeth code or PCI code.
> Adding some Cc's.

I don't think it's forcedeth. forcedeth just happens to be the first
module that get's loaded in startup. It crashes with any other module
too (I tried ohci_hcd).=20

To repeat myself: This might be the result of faulty config

	MfG
	bmg

--=20
=E2=80=9EDes is v=C3=B6llig wurscht, was heut beschlos- | M G Berberich
 sen wird: I bin sowieso dagegn!=E2=80=9C          | berberic@fmi.uni-p=
assau.de
(SPD-Stadtrat Kurt Schindler; Regensburg)  | www.fmi.uni-passau.de/~ber=
beric
