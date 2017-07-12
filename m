From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: Lots of new warnings with gcc-7.1.1
Date: Wed, 12 Jul 2017 15:31:02 +0200
Message-ID: <CAK8P3a2itguODKUNtw8m-7RReUkyEqk8fHYRLa-ZjJYjwwhYdg@mail.gmail.com>
References: <CA+55aFzXz-PxKSJP=hfHD+mfCX4M6+HMacWMkDz7KB8-3y55qw@mail.gmail.com>
 <848b3f21-9516-8a66-e4b3-9056ce38d6f6@roeck-us.net> <CA+55aFyKpezj3oHwtBShyf9x-DJNAGQhrq55iVGM42eWKQtP3w@mail.gmail.com>
 <CA+55aFx5mCk+nzDG+gGzDUqE4gzJVERL_oO+PN-PA6oKaUhCpg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Cc: Guenter Roeck <linux@roeck-us.net>, Tejun Heo <tj@kernel.org>,
        Jean Delvare <jdelvare@suse.com>,
        Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>,
        Sathya Prakash <sathya.prakash@broadcom.com>,
        "James E.J. Bottomley" <jejb@linux.vnet.ibm.com>,
        Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
        "the arch/x86 maintainers" <x86@kernel.org>,
        xen-devel <xen-devel@lists.xenproject.org>,
        linux-block <linux-block@vger.kernel.org>,
        Linux Media Mailing List <linux-media@vger.kernel.org>,
        IDE-ML <linux-ide@vger.kernel.org>,
        "linux-fbdev@vger.kernel.org" <linux-fbdev@vger.kernel.org>,
        Network Development <netdev@vger.kernel.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <linux-ide-owner@vger.kernel.org>
In-Reply-To: <CA+55aFx5mCk+nzDG+gGzDUqE4gzJVERL_oO+PN-PA6oKaUhCpg@mail.gmail.com>
Sender: linux-ide-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jul 12, 2017 at 5:41 AM, Linus Torvalds
<torvalds@linux-foundation.org> wrote:

>
> We also have about a bazillion
>
>     warning: =E2=80=98*=E2=80=99 in boolean context, suggest =E2=80=98&&=
=E2=80=99 instead
>
> warnings in drivers/ata/libata-core.c, all due to a single macro that
> uses a pattern that gcc-7.1.1 doesn't like. The warning looks a bit
> debatable, but I suspect the macro could easily be changed too.
>
> Tejun, would you hate just moving the "multiply by 1000" part _into_
> that EZ() macro? Something like the attached (UNTESTED!) patch?

Tejun applied an almost identical patch of mine a while ago, but it seems t=
o
have gotten lost in the meantime in some rebase:

https://patchwork.kernel.org/patch/9721397/
https://patchwork.kernel.org/patch/9721399/

I guess I should have resubmitted the second patch with the suggested
improvement.

     Arnd
