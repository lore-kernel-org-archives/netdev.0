From: Jaswinder Singh Rajput <jaswinderlinux-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: 2.6.29-rc1: Reported regressions from 2.6.28
Date: Tue, 13 Jan 2009 08:54:33 +0530
Message-ID: <3f9a31f40901121924v86b528er652b27e670c5fe0@mail.gmail.com>
References: <XU-8icArWLM.A.UpG.8GfaJB@chimera>
	 <3f9a31f40901110546h4c069b5dx9726a0fbf8caf5a1@mail.gmail.com>
	 <20090111135237.GA20184@elte.hu> <200901112001.00394.rjw@sisk.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>,
	Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Adrian Bunk <bunk-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Natalie Protasevich <protasnb-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Kernel Testers List <kernel-testers-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linux ACPI <linux-acpi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linux PM List <linux-pm-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>,
	Linux SCSI List <linux-scsi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: "Rafael J. Wysocki" <rjw-KKrjLPT3xs0@public.gmane.org>
Return-path: <kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <200901112001.00394.rjw-KKrjLPT3xs0@public.gmane.org>
Sender: kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hello Rafael,

On Mon, Jan 12, 2009 at 12:30 AM, Rafael J. Wysocki <rjw-KKrjLPT3xs0@public.gmane.org> wrote:
> On Sunday 11 January 2009, Ingo Molnar wrote:
>>
>> * Jaswinder Singh Rajput <jaswinderlinux-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
>>
>> > On Sun, Jan 11, 2009 at 4:42 PM, Rafael J. Wysocki <rjw-KKrjLPT3xs0@public.gmane.org> wrote:
>> > >
>> > > Regressions with patches
>> > > ------------------------
>> > >
>> > > Bug-Entry       : http://bugzilla.kernel.org/show_bug.cgi?id=12428
>> > > Subject         : Build error on latest git
>> > > Submitter       : Petr Titera <P.Titera-0E4lWjIyFdTrBKCeMvbIDA@public.gmane.org>
>> > > Date            : 2009-01-11 9:49 (1 days old)
>> > > References      : http://marc.info/?l=linux-kernel&m=123166856318712&w=4
>> > > Handled-By      : Petr Titera <P.Titera-0E4lWjIyFdTrBKCeMvbIDA@public.gmane.org>
>> > > Patch           : http://marc.info/?l=linux-kernel&m=123167509024996&w=4
>> >
>> > This is a wrong fix, asm/smp.h should only be included when CONFIG_SMP
>> > is defined.
>> >
>> > I am still in the process of cleaning non-smp data from asm/smp.h for
>> > x86
>> >
>> > Attach patch is the solution for the time being
>> >
>> > Ingo, can you please put this in urgent queue.
>>
>> yes, it already is - see below.
>
> Link to this patch was added to the bug entry.  Pleaes let me know or close the
> bug when it's merged.
>

http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git;a=commit;h=4884d8e6a05026ec906355436cea9dc1acb1d09e

--
JSR
