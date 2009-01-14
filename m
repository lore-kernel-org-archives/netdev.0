From: Sam Ravnborg <sam@ravnborg.org>
Subject: Re: [PULL -tip] fixed few make headers_check warnings
Date: Wed, 14 Jan 2009 16:38:25 +0100
Message-ID: <20090114153825.GB32082@uranus.ravnborg.org>
References: <1231836016.3212.41.camel@jaswinder.satnam> <Pine.LNX.4.64.0901140954250.27308@anakin> <3f9a31f40901140129i1389f47frf32808f3a695a118@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Geert Uytterhoeven <geert@linux-m68k.org>,
	Jaswinder Singh Rajput <jaswinder@infradead.org>,
	Ingo Molnar <mingo@elte.hu>,
	Alan Cox <alan@lxorguk.ukuu.org.uk>,
	Andrew Morton <akpm@linux-foundation.org>,
	David Miller <davem@davemloft.net>,
	x86 maintainers <x86@kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: Jaswinder Singh Rajput <jaswinderlinux@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pfepa.post.tele.dk ([195.41.46.235]:59683 "EHLO
	pfepa.post.tele.dk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753099AbZANPgm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Jan 2009 10:36:42 -0500
Content-Disposition: inline
In-Reply-To: <3f9a31f40901140129i1389f47frf32808f3a695a118@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 14, 2009 at 02:59:54PM +0530, Jaswinder Singh Rajput wrote:
> Hello Geert,
> 
> On Wed, Jan 14, 2009 at 2:26 PM, Geert Uytterhoeven
> <geert@linux-m68k.org> wrote:
> > On Tue, 13 Jan 2009, Jaswinder Singh Rajput wrote:
> >> Please pull these patches. Earlier I also floated these patches so that I can get some feedback.
> >>
> >> The following changes since commit ae2659bcd0b5bf34dd4b03f1db0a2942cc09b8e6:
> >>   Ingo Molnar (1):
> >>         Merge branch 'x86/mm'
> >>
> >> are available in the git repository at:
> >>
> >>   git://git.kernel.org/pub/scm/linux/kernel/git/jaswinder/linux-2.6-tiptop.git master
> >>
> >> Jaswinder Singh Rajput (7):
> >>       include of <linux/types.h> is preferred over <asm/types.h>
> >>       found __[us]{8,16,32,64} type without #include <linux/types.h>
> >>       capability.h: extern's make no sense in userspace
> >>       coda_psdev.h: extern's make no sense in userspace
> >>       in6.h: extern's make no sense in userspace
> >>       nubus.h: extern's make no sense in userspace
> >>       socket.h: extern's make no sense in userspace
> >
> > May I please remind you of my comment in
> > http://patchwork.kernel.org/patch/2093/?
> >
> 
> Thanks for your reminder :-)
> 
> > At least nubus.h still leaks forward declarations for kernel functions that
> > lack the "extern" keyword, so they still pollute user space.
> >
> 
> Yes, you are right, I just tried to pampered weeping warning messages
> which is annoying.

Hi Jaswinder.

I appreciate your work but I will like to question the approach.
We should rather take the warnings as an indication that this
file needs to be looked over and fix not only the warnings
reported but rater to fix all the questionable issues on a file-by-file basis.
If the patch gets involved then it should be split in two.

Could I ask you to at least consider this approach.

Thanks,
	Sam
