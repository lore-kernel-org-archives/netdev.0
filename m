From: Dan Aloni <da-x@gmx.net>
Subject: Re: [BK PATCH 2.6] repost, fix sysctl breakage during network device renaming, for ipv4
Date: Mon, 1 Sep 2003 21:55:32 +0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030901185532.GA28941@callisto.yi.org>
References: <20030901164624.GA26886@callisto.yi.org> <20030901094127.6a0f6878.davem@redhat.com> <20030901165559.GA27099@callisto.yi.org> <20030901113143.1ba34464.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Content-Disposition: inline
In-Reply-To: <20030901113143.1ba34464.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, Sep 01, 2003 at 11:31:43AM -0700, David S. Miller wrote:
> On Mon, 1 Sep 2003 19:55:59 +0300
> Dan Aloni <da-x@gmx.net> wrote:
> 
> > The private copy of strdup() is something that I'd also wouldn't
> > want, but I don't have much choice. Please read a recent 
> > thread in lkml regarding strdup() consolidation.
> 
> Ugh, I'm afraid to look...  I guess the controversy is
> over the allocation function, what GFP_* flags it should
> use etc.?

Yes, this is the one reason against consolidation, though
I don't know why anyone would want to call strdup() from a 
context other than GPF_KERNEL. Copying strings around in the 
kernel is done as a result of userspace interaction.
 
> For now just call the thing in your patch netdev_name_dup() or
> something like that.  I can't handle having something named
> "strdup()" in there :-)

Sure, I'll do it and resend.

-- 
Dan Aloni
da-x@gmx.net
