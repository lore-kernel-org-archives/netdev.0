From: "Torsten Kaiser" <just.for.lkml@googlemail.com>
Subject: Re: 2.6.24-rc6-mm1
Date: Fri, 25 Jan 2008 22:06:20 +0100
Message-ID: <64bb37e0801251306w21c7876du36de19340ce54a0f@mail.gmail.com>
References: <64bb37e0801060335k4afb3134u9c6fadb57d525dc5@mail.gmail.com>
	 <20080106223650E.tomof@acm.org>
	 <64bb37e0801061203l503f29f0hd922a1347f8169ac@mail.gmail.com>
	 <20080107151639P.fujita.tomonori@lab.ntt.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: tomof@acm.org, akpm@linux-foundation.org, jarkao2@gmail.com,
	herbert@gondor.apana.org.au, linux-kernel@vger.kernel.org,
	neilb@suse.de, bfields@fieldses.org, netdev@vger.kernel.org,
	tom@opengridcomputing.com
To: "FUJITA Tomonori" <fujita.tomonori@lab.ntt.co.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from py-out-1112.google.com ([64.233.166.181]:35149 "EHLO
	py-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760678AbYAYVGX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Jan 2008 16:06:23 -0500
Received: by py-out-1112.google.com with SMTP id u52so1276749pyb.10
        for <netdev@vger.kernel.org>; Fri, 25 Jan 2008 13:06:21 -0800 (PST)
In-Reply-To: <20080107151639P.fujita.tomonori@lab.ntt.co.jp>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sorry for the *really* late answer, but I did not have any time to do
linux things the last weeks. :-(

On Jan 7, 2008 7:16 AM, FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp> wrote:
> On Sun, 6 Jan 2008 21:03:42 +0100
> "Torsten Kaiser" <just.for.lkml@googlemail.com> wrote:
> > On Jan 6, 2008 2:33 PM, FUJITA Tomonori <tomof@acm.org> wrote:
> > > On Sun, 6 Jan 2008 12:35:35 +0100
> > > "Torsten Kaiser" <just.for.lkml@googlemail.com> wrote:
> > > > On Jan 6, 2008 12:23 PM, FUJITA Tomonori <tomof@acm.org> wrote:
> > > > And double using something does fit with the errors I'm seeing...
> > > >
> > > > > Can you try the patch to revert my IOMMU changes?
> > > > >
> > > > > http://www.mail-archive.com/linux-scsi@vger.kernel.org/msg12694.html

-> This is the revert-patch I'm talking about later

> > > > Testing for this bug is a little bit slow, as I'm compiling ~100
> > > > packages trying to trigger it.
> > > > If my current testrun with the patch from
> > > > http://www.mail-archive.com/linux-scsi@vger.kernel.org/msg12702.html
> > > > crashes, I will revert the hole IOMMU changes with above patch and try again.
> > >
> > > Thanks for testing,
> >
> > OK, I'm still testing this, but after 95 completed packages I'm rather
> > certain that reverting the IOMMU changes with this patch fixes my
> > problem.
> > I didn't have time to look more into this, so I can't offer any
> > concrete ideas where the bug is.

Until my last mail from 7. Jan this was true, that I was not able to
crash 2.6.24-rc6-mm1 with above patch.
But after testing 2.6.24-rc7 with only the IOMMU changes applied it
did crash once again.

After looking at the patch that seems rather expected as it only
touches powerpc code.
(I only looked at its diffstat after testing it, so I was not aware of
that fact during testing)

> > If you send more patches, I'm willing to test them, but it might take
> > some more time during the next week.
>
> Can you try 2.6.24-rc7 + the IOMMU changes?
>
> The patches are available at:
>
> http://www.kernel.org/pub/linux/kernel/people/tomo/iommu/
>
> Or if you prefer the git tree:
>
> git://git.kernel.org/pub/scm/linux/kernel/git/tomo/linux-2.6-misc.git iommu-sg-fixes
>
>
>
> I've looked at the changes to GART but they are straightforward and
> don't look wrong...

The resulting 2.6.24-rc7 kernel worked for me. I compiled 146 packages
without a crash.

Today I finally had some time for debugging again and tried the new
2.6.24-rc8-mm1.
The crash is still there, I will report that crash in current thread.

Torsten
