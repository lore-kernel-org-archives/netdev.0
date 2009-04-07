From: "Trenton D. Adams" <trenton.d.adams@gmail.com>
Subject: Re: 2.6.29-git13: Reported regressions from 2.6.28
Date: Mon, 6 Apr 2009 22:23:29 -0600
Message-ID: <9b1675090904062123u42a00a80y3a4385740ecc0121@mail.gmail.com>
References: <n4io5wq70ZO.A.gzG.rFn2JB@chimera>
	 <alpine.LFD.2.00.0904061443000.7443@localhost.localdomain>
	 <9b1675090904062056v235af58ehc99cce8ff97fe501@mail.gmail.com>
	 <alpine.LFD.2.00.0904062103531.4010@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Rafael J. Wysocki" <rjw@sisk.pl>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Adrian Bunk <bunk@kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Natalie Protasevich <protasnb@gmail.com>,
	Kernel Testers List <kernel-testers@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	Linux ACPI <linux-acpi@vger.kernel.org>,
	Linux PM List <linux-pm@lists.linux-foundation.org>,
	Linux SCSI List <linux-scsi@vger.kernel.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <linux-scsi-owner@vger.kernel.org>
In-Reply-To: <alpine.LFD.2.00.0904062103531.4010@localhost.localdomain>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Apr 6, 2009 at 10:07 PM, Linus Torvalds
<torvalds@linux-foundation.org> wrote:
>
>
> On Mon, 6 Apr 2009, Trenton D. Adams wrote:
>> >
>> > This went through bisection, but looking at the email log, I tend to
>> > suspect that maybe Trenton marked some versions good even though they
>> > weren't (because they got versions numbers from v2.6.27), and didn't
>> > realize that that messes up bisection in a big way.
>>
>> Is it appropriate for me to respond to these things?
>
> Yes. I added you to the cc exactly because it was hard for me to judge
> from the email discussion that is linked to in the regression list whether
> you actually _did_ mark some versions good because of confusion about the
> version numbering.

Oh, didn't know you CC'd me.  I have just been searching for my name
to try and keep up to date on threads I participated in, because the
list volume is just too much.

> So you may well have done everything right, and I'm not trying to blame
> you. I just was hoping that maybe that confusion would explain why the
> bisection didn't seem to pinpoint anything sane..

This gave me a bit of a chuckle. ROFL.  I didn't think you were
_blaming_ me.  And even if you were, I'd just say "I'M HUMAN MAN". ;)

It is very well possible that I simply booted the wrong kernel, seeing
I had like 20 to choose from at the time, after doing all those
bisects.  This time, I will make the new kernels the default so that
it is impossible to happen again, assuming that is what happened.  I
will also stop and start alsa 2 or 3 times, in case it is a deadlock
timing issue as you mentioned.

I'm glad to know that I shouldn't be switching kernel versions though.
 I thought that was really crazy.

>
>
> It would be good, especially if this bug doesn't end up being solved some
> other way... And slow results are better than no results at all ;)
>
>                        Linus
>

Okay, I will try again.  Hopefully in a few days I'll have something
for the bug.
