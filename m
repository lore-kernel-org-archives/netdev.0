From: Lubomir Rintel <lkundrak@v3.sk>
Subject: Re: [PATCH 1/3] ifb: make device count build-time configurable
Date: Tue, 12 Jan 2016 16:43:49 +0100
Message-ID: <1452613429.18559.69.camel@v3.sk>
References: <1452599804-27284-1-git-send-email-lkundrak@v3.sk>
	 <5695199E.2040303@iogearbox.net> <56951D49.5020800@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Jamal Hadi Salim <jhs@mojatatu.com>
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <56951D49.5020800@iogearbox.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2016-01-12 at 16:35 +0100, Daniel Borkmann wrote:
> On 01/12/2016 04:19 PM, Daniel Borkmann wrote:
> > On 01/12/2016 12:56 PM, Lubomir Rintel wrote:
=2E..
> > > -static int numifbs =3D 2;
> > =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0^^^^^^^^^^^^
> > > +static int numifbs =3D CONFIG_IFB_COUNT;
> > > =C2=A0 module_param(numifbs, int, 0);
> > > =C2=A0 MODULE_PARM_DESC(numifbs, "Number of ifb devices");
>=20
> Btw, perhaps there should also be a pr_info() or the like to warn the=
 user
> that relying on modprobe creating these devs is deprecated and schedu=
led
> for removal in future, so they should switch to ip link instead ...

I don't know, is it actually is scheduled for removal?

I was under impression that changes in default behavior users can rely
on are generally near impossible to do since the potential problems
largely outweigh the benefits. The distributions will do the changes in
their kernels anyway and changing behavior on kernel upgrades in random
old systems might be risky.

That said, it's just an impression. I don't follow the development
closely enough to be sure about anything.

Lubo
