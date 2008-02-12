From: "Natalie Protasevich" <protasnb@gmail.com>
Subject: Re: Open bugs
Date: Tue, 12 Feb 2008 10:55:35 -0800
Message-ID: <32209efe0802121055g4fd4911ap285d7f91e96af43f@mail.gmail.com>
References: <32209efe0802120018r17c38835ud931085e44aafefb@mail.gmail.com>
	 <1202839022.3137.63.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, akpm@linux-foundation.org,
	netdev@vger.kernel.org, alsa-devel@alsa-project.org,
	linux-ide@vger.kernel.org, bugme-daemon@kernel-bugs.osdl.org,
	linux-scsi <linux-scsi@vger.kernel.org>
To: "James Bottomley" <James.Bottomley@hansenpartnership.com>
Return-path: <linux-scsi-owner@vger.kernel.org>
In-Reply-To: <1202839022.3137.63.camel@localhost.localdomain>
Content-Disposition: inline
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Feb 12, 2008 9:57 AM, James Bottomley
<James.Bottomley@hansenpartnership.com> wrote:
> Added linux-scsi for the SCSI ones
>
> On Tue, 2008-02-12 at 00:18 -0800, Natalie Protasevich wrote:
> > Hello,
> >
> > The bugs listed are over a month old, and haven't been addressed yet.
> > It would be appreciated if corresponding maintainers identify whether
> > the bugs have been fixed, or need to be worked on, and take
> > appropriate action.
> >
> > In most cases, reporters are standing by and ready to provide
> > information and necessary testing.
> > Thanks!
> >
> > SCSI======================================================
> >
> > Problems on booting
> > http://bugzilla.kernel.org/show_bug.cgi?id=9621
> > Date: 12/22/2007
> > Regression
> > Summary: The boot stops / hangs on hardware detection of SCSI.  I have
> > an InitioINI-9X00U/UW
> > When I have an usb key sticked in /dev/sba, and run lilo then, then it
> > dont boot but give L99 99 99 99 ... error
>
> I think this was fixed by commit
> e2d435ea4084022ab88efa74214accb45b1f9e92
>
> Apparently bugzilla email is on the fritz again because this bug report
> didn't come across linux-scsi.

I just fixed that, thanks. It was incorrect "assign-to" party.

>
> > Resetting RAID attached to a FC Switch causes kernel panic and crash
> > http://bugzilla.kernel.org/show_bug.cgi?id=9598
> > 12/18/2007
> > Hardware Environment:SunFire X4200 - 2 x dual core AMD Opteron CPUs,
> > 8GB Ram, Qlogic FC adapter.
> > Summary: Resetting the RAID box causes the X4200 to crash.
>
> This one looks like the usual problem of remove re-add with the SCSI
> device model.
>
> > 3ware 9650SE -8LPML not recognized by 3w-9xxx driver
> > http://bugzilla.kernel.org/show_bug.cgi?id=8908
> > 08/19/2007
> > Problem Description: The 3w-9xxx kernel driver for 3ware 9xxx SATA
> > RAID Controller series did not recognize the 3ware 9650SE-8LPML SATA
> > RAID Controller.
>
> Since this one never apparently worked it's not a regression but an
> enhancement request, isn't it?

No this is not a regression. The bug list that I post is just any bugs
(mostly unattended or stalled). Sometimes those are regressions off of
the Raphael's list, when they don't get resolved for a while, or just
random regressions that haven't showed up on the "hot list" by
Raphael.

>
> However, adding this PCI ID to the driver should be fairly
> straightforward.  Does anyone know what the actual PCI IDs are?

I just asked the reporter to provide this information, thanks.

>
> James
>
>
