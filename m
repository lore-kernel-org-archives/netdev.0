From: Lubomir Rintel <lkundrak@v3.sk>
Subject: Re: [PATCH 2/3] dummy: make device count build-time configurable
Date: Fri, 05 Feb 2016 16:09:07 +0100
Message-ID: <1454684947.2779.12.camel@v3.sk>
References: <1452599853-27399-1-git-send-email-lkundrak@v3.sk>
	 <20160112104247.1004c32c@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160112104247.1004c32c@xeon-e3>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Stephen,

On Tue, 2016-01-12 at 10:42 -0800, Stephen Hemminger wrote:
> On Tue, 12 Jan 2016 12:57:33 +0100
> Lubomir Rintel <lkundrak@v3.sk> wrote:
>=20
> > The devices can be created at run-time for quite some time already
> > and the
> > load-time device creation collides with attempts to create the
> > device of
> > the same name:
> >=20
> > =C2=A0 # rmmod dummy
> > =C2=A0 # ip link add dummy0 type dummy
> > =C2=A0 RTNETLINK answers: File exists
> >=20
> > This is pretty much the same situation as was with the block loop
> > devices
> > which was solved by adding a build-time configuration that the
> > distributions could use as they deem fit while keeping the default
> > for
> > compatibility.
> >=20
> > Let's do that here as well.
> >=20
> > Signed-off-by: Lubomir Rintel <lkundrak@v3.sk>
>=20
> There is already a module parameter for this, so making it a compile
> time option adds nothing.

This option changes the defaults for the parameter.

When the module gets autoloaded, the user doesn't get a chance to
specify the module parameter and unwanted devices pop in.

Worse even, the automatically created devices are likely to collide
with what the user asked for.

Lubo
