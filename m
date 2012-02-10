From: Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Subject: Fwd: Linux 3.3-rc3
Date: Fri, 10 Feb 2012 08:56:29 -0800
Message-ID: <CA+55aFw9wOUbJKm7vVZYzFfKucanX43T2RwKoEfvNiVeEJP-2A@mail.gmail.com>
References: <CA+55aFyDE+chjpt9N5yNG=+A_LL5qhZjPYfOjFGuZcXUPGEoOQ@mail.gmail.com>
 <20120210100809.GB28736@pcnci.linuxbox.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Marcel Holtmann <marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org>,
	"Gustavo F. Padovan" <padovan-Y3ZbgMPKUGA34EUeqzHoZw@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20120210100809.GB28736-xTMdSLfc3Wpi51D5yjT6kKVXKuFTiq87@public.gmane.org>
Sender: linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This seems to have gotten lost somewhere - the lkml post was from the
middle of January.

                    Linus

---------- Forwarded message ----------
=46rom: Nikola Ciprich <nikola.ciprich-Jp3n8lUXroTtwjQa/ONI9g@public.gmane.org>
Date: Fri, Feb 10, 2012 at 2:08 AM
Subject: Re: Linux 3.3-rc3
To: Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Cc: Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
geert-Td1EMuHUCqxL1ZNQvxDV9g@public.gmane.org


On Wed, Feb 08, 2012 at 07:36:37PM -0800, Linus Torvalds wrote:
> Another week, another -rc.
>
> No big surprises, which is just how I like it. About a third of the
> patches are in ARM, but the bulk of that is due to the removal of the
> unused DMA map code form the bcmring support. So no complaints.
>
> The rest is fairly flat in the diffstat (=3D=3D random small changes =
all
> over), although mostly drivers. More sound/hda (and asoc) updates,
> some target and IB updates, etc etc.
>
> Shortlog appended for your perusal, you can see the kind of largely
> "fix small details" almost all of it is,

Hi,

just wanted to let You know, that following fix didn't make it into
Your tree yet:
https://lkml.org/lkml/2012/1/15/23

the bug is causing build failures with some GCC versions:

=A0CC [M] =A0net/bluetooth/l2cap_sock.o
net/bluetooth/l2cap_sock.c: In function =91l2cap_sock_connect=92:
include/net/bluetooth/l2cap.h:838: sorry, unimplemented: inlining
failed in call to =91l2cap_chan_connect=92: function body not available
net/bluetooth/l2cap_sock.c:126: sorry, unimplemented: called from here
make[2]: *** [net/bluetooth/l2cap_sock.o] Error 1
make[1]: *** [net/bluetooth] Error 2
make: *** [net] Error 2

BR
nik


--
-------------------------------------
Ing. Nikola CIPRICH
LinuxBox.cz, s.r.o.
28. rijna 168, 709 01 Ostrava

tel.: =A0 +420 596 603 142
fax: =A0 =A0+420 596 621 273
mobil: =A0+420 777 093 799
www.linuxbox.cz

mobil servis: +420 737 238 656
email servis: servis-Jp3n8lUXroTtwjQa/ONI9g@public.gmane.org
-------------------------------------
