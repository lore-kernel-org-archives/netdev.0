From: Paul Moore <paul@paul-moore.com>
Subject: Re: sel_netif_init: 'err' is used uninitialized
Date: Thu, 07 Aug 2014 21:01:19 -0400
Message-ID: <5275439.odfNAhPpkP@sifl>
References: <CAMuHMdV4VpaH1nHYO5hr66Xib5o_Pib863JzGRtg2kYcjMp2TQ@mail.gmail.com> <5750080.46d2jsPKXX@sifl> <20140807.120454.1646328149054855088.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: geert@linux-m68k.org, linux-security-module@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <20140807.120454.1646328149054855088.davem@davemloft.net>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thursday, August 07, 2014 12:04:54 PM David Miller wrote:
> From: Paul Moore <paul@paul-moore.com>
> Date: Thu, 07 Aug 2014 10:26:14 -0400
>=20
> > On Thursday, August 07, 2014 12:31:15 PM Geert Uytterhoeven wrote:
> >=20
> >>=20
> >> security/selinux/netif.c: In function =E2=80=98sel_netif_init=E2=80=
=99:
> >> /scratch/geert/linux/linux-m68k/security/selinux/netif.c:285: warn=
ing:
> >> =E2=80=98err=E2=80=99 is used uninitialized in this function
> >>=20
> >> Should it just return 0, like before?
> >> Or should it return the return value of register_netdevice_notifie=
r()
> >> instead, which also returns an error code? Or is that failure
> >> non-critical?
> >=20
> > Hi,
> >=20
> > I posted a fix for this two days ago to the SELinux list (see below=
).  As
> > soon as -rc1 is released and linux-next is back in business I'll be
> > pushing the patch to the SELinux #next branch.
> >=20
> >  * http://marc.info/?l=3Dselinux&m=3D140727033030054&w=3D2
>=20
> With respect to this and the lack-of-inline warning fix we spoke abou=
t
> yesterday, why are you waiting and only pushing such bug fixes into y=
our
> "next" branch?

Simply put, I didn't think the patches were significant enough to push =
at this=20
point in time.
=20
> Those sort of things should be sent to Linus now to correct the error=
s
> introduced during the merge window, as I have done last night for all
> of the networking merge fallout.

I'll (re)post the patches with a pull request in just a moment, CC'ing =
all the=20
various mailing lists and you guys can figure out who best to merge the=
m.

--=20
paul moore
www.paul-moore.com

--
To unsubscribe from this list: send the line "unsubscribe linux-securit=
y-module" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
