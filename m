From: "Trenton D. Adams" <trenton.d.adams-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: 2.6.29 on MacBook 2,1 fails to reboot (was Re: 2.6.29-git13:
	Reported regressions from 2.6.28)
Date: Tue, 7 Apr 2009 14:52:59 -0600
Message-ID: <9b1675090904071352x513510ecm8b2574859b088275@mail.gmail.com>
References: <n4io5wq70ZO.A.gzG.rFn2JB@chimera>
	 <alpine.LFD.2.00.0904061443000.7443@localhost.localdomain>
	 <49DB7C77.1000702@s5r6.in-berlin.de>
	 <9b1675090904070944m798ed608i1d9194ebd1ed3961@mail.gmail.com>
	 <49DB8909.3000905@s5r6.in-berlin.de>
	 <9b1675090904071122k6a53295fwfffc336011edee8e@mail.gmail.com>
	 <49DBA821.1070408@s5r6.in-berlin.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	"Rafael J. Wysocki" <rjw-KKrjLPT3xs0@public.gmane.org>,
	Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Adrian Bunk <bunk-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Natalie Protasevich <protasnb-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Kernel Testers List <kernel-testers-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linux ACPI <linux-acpi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linux PM List <linux-pm-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>,
	Linux SCSI List <linux-scsi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Takashi Iwai <tiwai-l3A5Bk7waGM@public.gmane.org>
To: Stefan Richter <stefanr-MtYdepGKPcBMYopoZt5u/LNAH6kLmebB@public.gmane.org>
Return-path: <kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <49DBA821.1070408-MtYdepGKPcBMYopoZt5u/LNAH6kLmebB@public.gmane.org>
Sender: kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, Apr 7, 2009 at 1:23 PM, Stefan Richter
<stefanr-MtYdepGKPcBMYopoZt5u/LNAH6kLmebB@public.gmane.org> wrote:
> Trenton D. Adams wrote:
>> On Tue, Apr 7, 2009 at 11:10 AM, Stefan Richter
>> <stefanr-MtYdepGKPcBMYopoZt5u/LNAH6kLmebB@public.gmane.org> wrote:
>>>>> http://bugs.gentoo.org/show_bug.cgi?id=3D253535
>>> Interdependencies between ALSA modules have changed. =A0The Gentoo =
init
>>> scripts attempted to unload them in an order which deadlocked modpr=
obe
>>> due to dependencies. =A0The fix for Gentoo is to just not unload th=
e
>>> modules on system shutdown. =A0My Gentoo/amd64 Mac mini was affecte=
d by
>>> this too; fixed by userland update.
>>>
>>
>> While that is interesting, I am not seeing that problem on my Gentoo
>> box (the macbook), which is completely up-to-date. =A02.6.28 works, =
and
>> 2.6.29 doesn't. =A0Same init scripts, different kernels.
>
> Note that the respective update changed /etc/conf.d/alsasound (a loca=
l
> configuration file) to include
> UNLOAD_ON_STOP=3D"no"
> KILLPROC_ON_STOP=3D"no"
> This change by update is not activated by a mere emerge; one needs to
> incorporate that change with dispatch-conf or an equivalent method.
> (Or simply edit the file to have these variables set to "no".)

I run dispatch-conf every time I update.  It did not set it to no by
default.  I do see the option though.

>
>> And sure, I could put a comment on the rmmod, in the init script, bu=
t
>> IMO that would be a hack around a _bug_. =A0Which is fine for me. =A0=
But,
>> is it worth leaving the issue in the kernel?
>
> Is it a kernel issue if a script attempts to unload a busy module, th=
en
> fails to proceed? =A0I wouldn't think so.

I don't know really.  It worked before, now it doesn't.  But, now I'm
recalling something you said earlier.  They are being done in the
wrong order.  The gentoo bug mentions the correct order.  I hadn't
realized that.

>
> But more importantly, is this init scripts related bug really what's
> happening at your system? =A0Or do you actually experience an entirel=
y
> different bug?

It could be.  I will try it out when I get home from work, and get
back to you.  That would be cool if it was a simple init script
problem.  Cause then I don't have to do anymore git bisects. ;)

> --
> Stefan Richter
> -=3D=3D=3D=3D=3D-=3D-=3D=3D=3D -=3D-=3D -=3D=3D-=3D
> http://arcgraph.de/sr/
>
