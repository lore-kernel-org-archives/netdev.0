From: Christoph Hellwig <hch@lst.de>
Subject: Re: [PATCH] several netdrivers need linux/init.h
Date: Thu, 27 May 2004 22:35:29 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040527203529.GA22929@lst.de>
References: <20040522230830.GA3380@infradead.org> <40B63E81.8020700@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
In-Reply-To: <40B63E81.8020700@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, May 27, 2004 at 03:16:17PM -0400, Jeff Garzik wrote:
> >@@ -22,6 +22,7 @@
> > #include <asm/uaccess.h>
> > #include <linux/if.h>
> > #include <linux/hdlc.h>
> >+#include <asm/io.h>
> > 
> > #include "farsync.h"
> > 
> 
> rejected,
> 1) just applied large farsync update, and
> 2) patch not related to $subject

Will resend with the right subject if still needed.
> > #undef COSA_SLOW_IO	/* for testing purposes only */
> > #undef REALLY_SLOW_IO
> 
> patch(1) rejected

right, in fact the patch to remove comx came from me earlier ;)

> BTW the mailing list is "netdev@oss.sgi.com" not "linux-netdev@...".

Sure.  I just have the bad habbit to add typos wherever possible.
