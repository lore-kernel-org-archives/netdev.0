From: Tejun Heo <tj@kernel.org>
Subject: Re: Lots of new warnings with gcc-7.1.1
Date: Sat, 15 Jul 2017 07:03:16 -0400
Message-ID: <20170715110316.GD2969123@devbig577.frc2.facebook.com>
References: <CA+55aFzXz-PxKSJP=hfHD+mfCX4M6+HMacWMkDz7KB8-3y55qw@mail.gmail.com>
 <848b3f21-9516-8a66-e4b3-9056ce38d6f6@roeck-us.net>
 <CA+55aFyKpezj3oHwtBShyf9x-DJNAGQhrq55iVGM42eWKQtP3w@mail.gmail.com>
 <CA+55aFx5mCk+nzDG+gGzDUqE4gzJVERL_oO+PN-PA6oKaUhCpg@mail.gmail.com>
 <CAK8P3a2itguODKUNtw8m-7RReUkyEqk8fHYRLa-ZjJYjwwhYdg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
        Guenter Roeck <linux@roeck-us.net>,
        Jean Delvare <jdelvare@suse.com>,
        Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>,
        Sathya Prakash <sathya.prakash@broadcom.com>,
        "James E.J. Bottomley" <jejb@linux.vnet.ibm.com>,
        Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
        the arch/x86 maintainers <x86@kernel.org>,
        xen-devel <xen-devel@lists.xenproject.org>,
        linux-block <linux-block@vger.kernel.org>,
        Linux Media Mailing List <linux-media@vger.kernel.org>,
        IDE-ML <linux-ide@vger.kernel.org>,
        "linux-fbdev@vger.kernel.org" <linux-fbdev@vger.kernel.org>,
        Network Development <netdev@vger.kernel.org>
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <linux-media-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CAK8P3a2itguODKUNtw8m-7RReUkyEqk8fHYRLa-ZjJYjwwhYdg@mail.gmail.com>
Sender: linux-media-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

On Wed, Jul 12, 2017 at 03:31:02PM +0200, Arnd Bergmann wrote:
> > We also have about a bazillion
> >
> >     warning: ‘*’ in boolean context, suggest ‘&&’ instead
> >
> > warnings in drivers/ata/libata-core.c, all due to a single macro that
> > uses a pattern that gcc-7.1.1 doesn't like. The warning looks a bit
> > debatable, but I suspect the macro could easily be changed too.
> >
> > Tejun, would you hate just moving the "multiply by 1000" part _into_
> > that EZ() macro? Something like the attached (UNTESTED!) patch?
> 
> Tejun applied an almost identical patch of mine a while ago, but it seems to
> have gotten lost in the meantime in some rebase:

Yeah, I was scratching my head remembering your patch.  Sorry about
that.  It should have been routed through for-4.12-fixes.

> https://patchwork.kernel.org/patch/9721397/
> https://patchwork.kernel.org/patch/9721399/
> 
> I guess I should have resubmitted the second patch with the suggested
> improvement.

The new one looks good to me.

Thanks.

-- 
tejun
