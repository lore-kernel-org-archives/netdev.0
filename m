From: Gustavo Padovan <padovan-Y3ZbgMPKUGA34EUeqzHoZw@public.gmane.org>
Subject: Re: Fwd: Linux 3.3-rc3
Date: Fri, 10 Feb 2012 16:24:56 -0200
Message-ID: <20120210182456.GD5022@joana>
References: <CA+55aFyDE+chjpt9N5yNG=+A_LL5qhZjPYfOjFGuZcXUPGEoOQ@mail.gmail.com>
 <20120210100809.GB28736@pcnci.linuxbox.cz>
 <CA+55aFw9wOUbJKm7vVZYzFfKucanX43T2RwKoEfvNiVeEJP-2A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Marcel Holtmann <marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Return-path: <linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <CA+55aFw9wOUbJKm7vVZYzFfKucanX43T2RwKoEfvNiVeEJP-2A-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Linus,

* Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org> [2012-02-10 08:56:29 -=
0800]:

> This seems to have gotten lost somewhere - the lkml post was from the
> middle of January.

Actually not, the fix is in another tree and should be sent mainline so=
on. I
was away from development during January and the pull requests stopped =
during
that time. Things should be back to normal now.

If you wanna go ahead and apply this patch directly you have my ack:

Acked-by: Gustavo F. Padovan <padovan-Y3ZbgMPKUGA34EUeqzHoZw@public.gmane.org>

	Gustavo

>=20
>                     Linus
>=20
> ---------- Forwarded message ----------
> From: Nikola Ciprich <nikola.ciprich-Jp3n8lUXroTtwjQa/ONI9g@public.gmane.org>
> Date: Fri, Feb 10, 2012 at 2:08 AM
> Subject: Re: Linux 3.3-rc3
> To: Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
> Cc: Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
> geert-Td1EMuHUCqxL1ZNQvxDV9g@public.gmane.org
>=20
>=20
> On Wed, Feb 08, 2012 at 07:36:37PM -0800, Linus Torvalds wrote:
> > Another week, another -rc.
> >
> > No big surprises, which is just how I like it. About a third of the
> > patches are in ARM, but the bulk of that is due to the removal of t=
he
> > unused DMA map code form the bcmring support. So no complaints.
> >
> > The rest is fairly flat in the diffstat (=3D=3D random small change=
s all
> > over), although mostly drivers. More sound/hda (and asoc) updates,
> > some target and IB updates, etc etc.
> >
> > Shortlog appended for your perusal, you can see the kind of largely
> > "fix small details" almost all of it is,
>=20
> Hi,
>=20
> just wanted to let You know, that following fix didn't make it into
> Your tree yet:
> https://lkml.org/lkml/2012/1/15/23
>=20
> the bug is causing build failures with some GCC versions:
>=20
> =C2=A0CC [M] =C2=A0net/bluetooth/l2cap_sock.o
> net/bluetooth/l2cap_sock.c: In function =E2=80=98l2cap_sock_connect=E2=
=80=99:
> include/net/bluetooth/l2cap.h:838: sorry, unimplemented: inlining
> failed in call to =E2=80=98l2cap_chan_connect=E2=80=99: function body=
 not available
> net/bluetooth/l2cap_sock.c:126: sorry, unimplemented: called from her=
e
> make[2]: *** [net/bluetooth/l2cap_sock.o] Error 1
> make[1]: *** [net/bluetooth] Error 2
> make: *** [net] Error 2
>=20
> BR
> nik
>=20
>=20
> --
> -------------------------------------
> Ing. Nikola CIPRICH
> LinuxBox.cz, s.r.o.
> 28. rijna 168, 709 01 Ostrava
>=20
> tel.: =C2=A0 +420 596 603 142
> fax: =C2=A0 =C2=A0+420 596 621 273
> mobil: =C2=A0+420 777 093 799
> www.linuxbox.cz
>=20
> mobil servis: +420 737 238 656
> email servis: servis-Jp3n8lUXroTtwjQa/ONI9g@public.gmane.org
> -------------------------------------
