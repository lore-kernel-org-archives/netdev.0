From: Greg KH <greg@kroah.com>
Subject: Re: pull request: wireless 2011-12-15
Date: Tue, 3 Jan 2012 14:27:31 -0800
Message-ID: <20120103222731.GA26544@kroah.com>
References: <20111215191523.GA2561@tuxdriver.com>
 <CACna6rw736JdkoM8zKxorCFd5oy08QTwWZ6PutoJPSr3ZN8hTg@mail.gmail.com>
 <20111215213822.GB2561@tuxdriver.com>
 <CACna6rz3qDpw4eJOoCXx7=z1719v7kS-Ou-WUseR9_vB-O2dag@mail.gmail.com>
 <CACna6rxO2dC=Y3nv-d-w89MqyM0j0aumk=r5Yh_KEg=MwOcvEQ@mail.gmail.com>
 <20120103205226.GA17131@kroah.com>
 <CACna6rwjrg6m3SEBxfYWgRSTN5_4-TuA0tdG6P2pFuUvwvvjZA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "John W. Linville" <linville@tuxdriver.com>, davem@davemloft.net,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: =?utf-8?B?UmFmYcWCIE1pxYJlY2tp?= <zajec5@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CACna6rwjrg6m3SEBxfYWgRSTN5_4-TuA0tdG6P2pFuUvwvvjZA@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jan 03, 2012 at 11:06:59PM +0100, Rafa=C5=82 Mi=C5=82ecki wrote=
:
> W dniu 3 stycznia 2012 21:52 u=C5=BCytkownik Greg KH <greg@kroah.com>=
 napisa=C5=82:
> > On Mon, Dec 26, 2011 at 12:36:59AM +0100, Rafa=C5=82 Mi=C5=82ecki w=
rote:
> >> W dniu 16 grudnia 2011 07:40 u=C5=BCytkownik Rafa=C5=82 Mi=C5=82ec=
ki
> >> <zajec5@gmail.com> napisa=C5=82:
> >> > W dniu 15 grudnia 2011 22:38 u=C5=BCytkownik John W. Linville
> >> > <linville@tuxdriver.com> napisa=C5=82:
> >> >> On Thu, Dec 15, 2011 at 09:04:29PM +0100, Rafa=C5=82 Mi=C5=82ec=
ki wrote:
> >> >>> 2011/12/15 John W. Linville <linville@tuxdriver.com>:
> >> >>> > commit 42a3b63bb2ca4996a3d1210a004eae2333f1119e
> >> >>> >
> >> >>> > Dave,
> >> >>> >
> >> >>> > Here are a few more fixes intended for the 3.2 release. =C2=A0=
They are
> >> >>> > all small and narrowly focused.
> >> >>>
> >> >>> John, I've made a mistake and didn't use [PATCH 3.2] header to=
 make it
> >> >>> clean my patch is fix. Could you take a look at
> >> >>> [PATCH] bcma: support for suspend and resume
> >> >>> please?
> >> >>>
> >> >>> It's not one-liner, but fixes lock ups, which I believe - we r=
eally
> >> >>> want to avoid.
> >> >>
> >> >> It's late in the release cycle, and Dave specifically asked me =
to slow down.
> >> >>
> >> >> Are these suspend/resume lockups a regression? =C2=A0Or have th=
ey always
> >> >> been there? =C2=A0Do they happen to everyone?
> >> >
> >> > The bug is present since first days of bcma. That's why I even d=
ecided
> >> > to add stable to CC.
> >> >
> >> > Personally I've tested that only on 1 machine (I don't have more
> >> > suspendable machines with mini PCIe slot). However all Macbook 8=
=2E1/8.2
> >> > users have to remove b43 & bcma before suspending [0], they comp=
lain
> >> > about that since ever.
> >> >
> >> > Arend: I know you're also complaining for suspend in bcma. Can y=
ou
> >> > comment on this?
> >> >
> >> > [0] http://ubuntuforums.org/showthread.php?t=3D1695746
> >>
> >> User nephyrin on #bcm-users has confirmed this patch fixes
> >> suspend&resume for him. Without this patch he got deadlock without
> >> seeing any kernel panic logs - quite an ugly case.
> >>
> >> I still think this patch may be worth taking as fix and backportin=
g too.
> >
> > What patch specifically? =C2=A0What is the git commit id of it in L=
inus's
> > tree? =C2=A0Without that information, telling stable@ about it is
> > pointless...
>=20
> Sorry Greg, it's about
>=20
> commit 775ab52142b02237a54184238e922251c59a2b5c
> Author: Rafa=C5=82 Mi=C5=82ecki <zajec5@gmail.com>
> Date:   Fri Dec 9 22:16:07 2011 +0100
>=20
>     bcma: support for suspend and resume
>=20
>     bcma used to lock up machine without enabling PCI or initializing=
 CC.
>=20
>     Cc: stable@vger.kernel.org
>     Signed-off-by: Rafa=C5=82 Mi=C5=82ecki <zajec5@gmail.com>
>     Signed-off-by: John W. Linville <linville@tuxdriver.com>
>=20
> it's located in wireless-testing:
> git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-testi=
ng.git
>=20
> John didn't pass this to Linus yet.

Then there's nothing I can do about it.

As it's properly tagged, I'll pick it up when it gets to Linus.

thanks,

greg k-h
