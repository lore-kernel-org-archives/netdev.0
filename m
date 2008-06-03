From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: pull request: wireless-2.6 2008-06-03
Date: Tue, 03 Jun 2008 14:16:52 -0700 (PDT)
Message-ID: <20080603.141652.245225529.davem@davemloft.net>
References: <20080603190943.GB28966@tuxdriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20080603190943.GB28966-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Date: Tue, 3 Jun 2008 15:09:43 -0400

> Kirill A. Shutemov (1):
>       wireless.h: improve userland include-ability

I'm not pulling this into my tree.  I've already replied
to that patch posting saying why I don't like this.

Even if I found this change as the only way to go and therefore
had to take it in, the commit log is way too terse about what
the problem is.  And it must describe the horrifics that are
now necessary to include this file in userspace after the change.

It needs to describe in detail what the conflicting types and
definitions in the kernel headers are that cause problems with
userspace, and the exact sequence of includes userland has to make in
order to get this right.

And I require such enormously scary details in order to make it clear
how bogus this change is.

There is zero point in us sanitizing kernel headers for userspace
usage if this kind of crap is still necessary.  I mean tell me, why
should we even bother in that case?  And this is why I'm not taking in
this changeset.
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
