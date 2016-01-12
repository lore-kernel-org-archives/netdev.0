From: Lubomir Rintel <lkundrak@v3.sk>
Subject: Re: [PATCH 1/3] ifb: make device count build-time configurable
Date: Tue, 12 Jan 2016 16:31:51 +0100
Message-ID: <1452612711.18559.62.camel@v3.sk>
References: <1452599804-27284-1-git-send-email-lkundrak@v3.sk>
	 <5695199E.2040303@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Jamal Hadi Salim <jhs@mojatatu.com>
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <5695199E.2040303@iogearbox.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2016-01-12 at 16:19 +0100, Daniel Borkmann wrote:
> On 01/12/2016 12:56 PM, Lubomir Rintel wrote:
> > The devices can be created at run-time for quite some time already
> > and the
> > load-time device creation collides with attempts to create the
> > device of
> > the same name:
> >=20
> > =C2=A0=C2=A0=C2=A0# rmmod ifb
> > =C2=A0=C2=A0=C2=A0# ip link add ifb0 type ifb
> > =C2=A0=C2=A0=C2=A0RTNETLINK answers: File exists
> >=20
> > This is pretty much the same situation as was with the block loop
> > devices
> > which was solved by adding a build-time configuration that the
> > distributions could use as they deem fit while keeping the default
> > for
> > compatibility.
> >=20
> > Let's do that here as well.
>=20
> Thanks for the set in general, good to see it fixed!
>=20
> > Signed-off-by: Lubomir Rintel <lkundrak@v3.sk>
> > ---
> [...]
> > +config IFB_COUNT
> > +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0int "Number of ifb=
 devices to pre-create at init time"
> > +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0depends on IFB
> > +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0default 3
>=20
> Should that not be 2?

Yes, it should be. Good catch, thanks. Will follow-up with a fixed
patch.

Lubo
