From: Chris Wright <chrisw@osdl.org>
Subject: Re: [stable] [BK PATCHES] 2.6.x net driver oops fixes
Date: Thu, 10 Mar 2005 13:39:17 -0800
Message-ID: <20050310213917.GW5389@shell0.pdx.osdl.net>
References: <422F59E8.2090707@pobox.com> <20050310202548.GV5389@shell0.pdx.osdl.net> <4230AE24.602@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Chris Wright <chrisw@osdl.org>, Andrew Morton <akpm@osdl.org>,
        Linus Torvalds <torvalds@osdl.org>, Netdev <netdev@oss.sgi.com>,
        stable@kernel.org, Linux Kernel <linux-kernel@vger.kernel.org>,
        Roger Luethi <rl@hellgate.ch>
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
In-Reply-To: <4230AE24.602@pobox.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* Jeff Garzik (jgarzik@pobox.com) wrote:
> Chris Wright wrote:
> >* Jeff Garzik (jgarzik@pobox.com) wrote:
> >
> >
> >>This will update the following files:
> >>
> >>drivers/net/sis900.c    |   41 +++++++++++++++++++++--------------------
> >>drivers/net/via-rhine.c |    3 +++
> >
> >
> >The via-rhine fix is already in the stable queue.  But the sis900 oops
> >fix does not apply to the stable tree.  It relies on a few intermediate
> >patches.  Appears to still be an issue for the older version which is in
> >2.6.11.  Here's a stab at a backport.  Would you like to review/validate
> >or drop this one?
> 
> The backport looks correct to me, though it would be nice to get a 
> via-rhine owner to ACK the patch before it goes in...

OK, thanks.  ITYM sis900 maintainer, is that still Ollie Lho as listed in
MAINTAINERS (that's looking old)?

thanks,
-chris
