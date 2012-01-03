From: Greg KH <greg@kroah.com>
Subject: Re: pull request: wireless 2011-12-15
Date: Tue, 3 Jan 2012 12:52:26 -0800
Message-ID: <20120103205226.GA17131@kroah.com>
References: <20111215191523.GA2561@tuxdriver.com>
 <CACna6rw736JdkoM8zKxorCFd5oy08QTwWZ6PutoJPSr3ZN8hTg@mail.gmail.com>
 <20111215213822.GB2561@tuxdriver.com>
 <CACna6rz3qDpw4eJOoCXx7=z1719v7kS-Ou-WUseR9_vB-O2dag@mail.gmail.com>
 <CACna6rxO2dC=Y3nv-d-w89MqyM0j0aumk=r5Yh_KEg=MwOcvEQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "John W. Linville" <linville@tuxdriver.com>, davem@davemloft.net,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: =?utf-8?B?UmFmYcWCIE1pxYJlY2tp?= <zajec5@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CACna6rxO2dC=Y3nv-d-w89MqyM0j0aumk=r5Yh_KEg=MwOcvEQ@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Dec 26, 2011 at 12:36:59AM +0100, Rafa=C5=82 Mi=C5=82ecki wrote=
:
> W dniu 16 grudnia 2011 07:40 u=C5=BCytkownik Rafa=C5=82 Mi=C5=82ecki
> <zajec5@gmail.com> napisa=C5=82:
> > W dniu 15 grudnia 2011 22:38 u=C5=BCytkownik John W. Linville
> > <linville@tuxdriver.com> napisa=C5=82:
> >> On Thu, Dec 15, 2011 at 09:04:29PM +0100, Rafa=C5=82 Mi=C5=82ecki =
wrote:
> >>> 2011/12/15 John W. Linville <linville@tuxdriver.com>:
> >>> > commit 42a3b63bb2ca4996a3d1210a004eae2333f1119e
> >>> >
> >>> > Dave,
> >>> >
> >>> > Here are a few more fixes intended for the 3.2 release. =C2=A0T=
hey are
> >>> > all small and narrowly focused.
> >>>
> >>> John, I've made a mistake and didn't use [PATCH 3.2] header to ma=
ke it
> >>> clean my patch is fix. Could you take a look at
> >>> [PATCH] bcma: support for suspend and resume
> >>> please?
> >>>
> >>> It's not one-liner, but fixes lock ups, which I believe - we real=
ly
> >>> want to avoid.
> >>
> >> It's late in the release cycle, and Dave specifically asked me to =
slow down.
> >>
> >> Are these suspend/resume lockups a regression? =C2=A0Or have they =
always
> >> been there? =C2=A0Do they happen to everyone?
> >
> > The bug is present since first days of bcma. That's why I even deci=
ded
> > to add stable to CC.
> >
> > Personally I've tested that only on 1 machine (I don't have more
> > suspendable machines with mini PCIe slot). However all Macbook 8.1/=
8.2
> > users have to remove b43 & bcma before suspending [0], they complai=
n
> > about that since ever.
> >
> > Arend: I know you're also complaining for suspend in bcma. Can you
> > comment on this?
> >
> > [0] http://ubuntuforums.org/showthread.php?t=3D1695746
>=20
> User nephyrin on #bcm-users has confirmed this patch fixes
> suspend&resume for him. Without this patch he got deadlock without
> seeing any kernel panic logs - quite an ugly case.
>=20
> I still think this patch may be worth taking as fix and backporting t=
oo.

What patch specifically?  What is the git commit id of it in Linus's
tree?  Without that information, telling stable@ about it is
pointless...

greg k-h
