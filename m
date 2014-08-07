From: Paul Moore <paul@paul-moore.com>
Subject: Re: sel_netif_init: 'err' is used uninitialized (was: Re: selinux: reduce the number of calls to synchronize_net() when flushing caches)
Date: Thu, 07 Aug 2014 10:26:14 -0400
Message-ID: <5750080.46d2jsPKXX@sifl>
References: <CAMuHMdV4VpaH1nHYO5hr66Xib5o_Pib863JzGRtg2kYcjMp2TQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-security-module@vger.kernel.org,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: Geert Uytterhoeven <geert@linux-m68k.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAMuHMdV4VpaH1nHYO5hr66Xib5o_Pib863JzGRtg2kYcjMp2TQ@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thursday, August 07, 2014 12:31:15 PM Geert Uytterhoeven wrote:
>=20
> security/selinux/netif.c: In function =E2=80=98sel_netif_init=E2=80=99=
:
> /scratch/geert/linux/linux-m68k/security/selinux/netif.c:285: warning=
:
> =E2=80=98err=E2=80=99 is used uninitialized in this function
>=20
> Should it just return 0, like before?
> Or should it return the return value of register_netdevice_notifier()
> instead, which also returns an error code? Or is that failure non-cri=
tical?

Hi,

I posted a fix for this two days ago to the SELinux list (see below).  =
As soon=20
as -rc1 is released and linux-next is back in business I'll be pushing =
the=20
patch to the SELinux #next branch.

 * http://marc.info/?l=3Dselinux&m=3D140727033030054&w=3D2

--=20
paul moore
www.paul-moore.com
