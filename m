From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: Re: sel_netif_init: 'err' is used uninitialized (was: Re: selinux:
 reduce the number of calls to synchronize_net() when flushing caches)
Date: Thu, 7 Aug 2014 16:57:30 +0200
Message-ID: <CAMuHMdWyMjUW+FB5FtkoqF7pFsm3C6+VsTK7KE6q7XRFRRMOvw@mail.gmail.com>
References: <CAMuHMdV4VpaH1nHYO5hr66Xib5o_Pib863JzGRtg2kYcjMp2TQ@mail.gmail.com>
	<5750080.46d2jsPKXX@sifl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-security-module@vger.kernel.org,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: Paul Moore <paul@paul-moore.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <5750080.46d2jsPKXX@sifl>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Paul,

On Thu, Aug 7, 2014 at 4:26 PM, Paul Moore <paul@paul-moore.com> wrote:
> On Thursday, August 07, 2014 12:31:15 PM Geert Uytterhoeven wrote:
>>
>> security/selinux/netif.c: In function =E2=80=98sel_netif_init=E2=80=99=
:
>> /scratch/geert/linux/linux-m68k/security/selinux/netif.c:285: warnin=
g:
>> =E2=80=98err=E2=80=99 is used uninitialized in this function
>>
>> Should it just return 0, like before?
>> Or should it return the return value of register_netdevice_notifier(=
)
>> instead, which also returns an error code? Or is that failure non-cr=
itical?
>
> Hi,
>
> I posted a fix for this two days ago to the SELinux list (see below).=
  As soon
> as -rc1 is released and linux-next is back in business I'll be pushin=
g the
> patch to the SELinux #next branch.
>
>  * http://marc.info/?l=3Dselinux&m=3D140727033030054&w=3D2

Thanks, I had a quick look for it, but couldn't find it.
It's always a good idea to CC lkml for such issues in mainline.

Gr{oetje,eeting}s,

                        Geert

--
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-=
m68k.org

In personal conversations with technical people, I call myself a hacker=
=2E But
when I'm talking to journalists I just say "programmer" or something li=
ke that.
                                -- Linus Torvalds
