From: Mitchell Blank Jr <mitch@sfgoth.com>
Subject: Re: [PATCH][ATM]: [lanai] ioctl only meant for debugging (from mitch@sfgoth.com)
Date: Mon, 22 Sep 2003 21:45:11 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030923044511.GB15907@gaz.sfgoth.com>
References: <hch@infradead.org> <200309221755.h8MHt5kT010184@ginger.cmf.nrl.navy.mil> <20030922190017.A27677@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: chas williams <chas@cmf.nrl.navy.mil>, davem@redhat.com,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Christoph Hellwig <hch@infradead.org>
Content-Disposition: inline
In-Reply-To: <20030922190017.A27677@infradead.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Christoph Hellwig wrote (in two different emails):
> Umm, shouldn't you just ifdef out the whole function and it's
> assignment to the operations vector?  This looks horribly ugly..

Sorry for any ugliness - its my fault.  I personally don't think it really
makes a difference either way.  Its already #ifdef'ed the same way in 2.6.

> and
> third your (void)arg crap is ugly as hell. (what compiler do you have
> that complains about this, btw, gcc 3.3 doesn't..).

"gcc -Wunused-parameter"

It's true that the kernel doesn't compile with that option but I've gotten
in the habit of adding the "(void) x;" from working on other projects that
do.  I think it's pretty harmless.

> #if FOO
> foo_ioctl()
> {
> }
> #else
> #define foo_ioctl	NULL
> #endif

Yes, that would probably be (a bit) cleaner.  That's what we already
use for lanai_proc_read if !CONFIG_PROC_FS

-Mitch
