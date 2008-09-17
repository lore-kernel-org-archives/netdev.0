From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [Bug #11500] /proc/net bug related to selinux
Date: Wed, 17 Sep 2008 15:53:42 -0700
Message-ID: <m1wshawfih.fsf@frodo.ebiederm.org>
References: <j3zWxt-CgYL.A.WTF.bbsyIB@albercik>
	<200809171724.36269.paul.moore@hp.com>
	<20080917144842.7df59f9e.akpm@linux-foundation.org>
	<200809171812.59693.paul.moore@hp.com>
	<20080917152407.76230f0c.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Paul Moore <paul.moore-VXdhtT5mjnY@public.gmane.org>, sds-+05T5uksL2qpZYMLLGbcSA@public.gmane.org,
	jmorris-gx6/JNMH7DfYtjvyW6yDsg@public.gmane.org, rjw-KKrjLPT3xs0@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	kernel-testers-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Return-path: <kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20080917152407.76230f0c.akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org> (Andrew
	Morton's message of "Wed, 17 Sep 2008 15:24:07 -0700")
Sender: kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org> writes:

> On Wed, 17 Sep 2008 18:12:59 -0400
> Paul Moore <paul.moore-VXdhtT5mjnY@public.gmane.org> wrote:
>
>> > We don't even know the extent of the damage yet.  Which distros were
>> > affected? With which versions of which userspace packages?
>> 
>> Can I assume that the "right" thing to do would be to find the problem 
>> and revert whatever change caused the issue, yes?  Or are we happy to 
>> wait and see since the fallout so far has been minimal?
>
> I don't think a revert is justified after all this time.  afaik I'm the
> first person to notice the problem, and it's been out there for
> multiple months.
>
> However it would be good if we could find some not-completely-stinky
> way of making the old userspace work.
>
> otoh, people who are shipping 2.6.25- and 2.6.26-based distros probably
> wouldn't want such a patch in their kernels anyway.

Disable selinux?

Get a selinux mystic to update that selinux policy.  I bet it is a one line
change to each the policy about /proc/net as a symlink.

Although I am puzzled why we don't get the same label as /proc/net as a directory
had.

Eric
