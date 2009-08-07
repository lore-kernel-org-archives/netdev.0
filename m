From: Greg KH <greg@kroah.com>
Subject: Re: [patch for 2.6.31? 2/2] gigaset: really fix chars_in_buffer
Date: Thu, 6 Aug 2009 20:50:30 -0700
Message-ID: <20090807035030.GA23938@kroah.com>
References: <200908062219.n76MJXhY024495@imap1.linux-foundation.org>
 <20090806.202227.224933454.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org, tilman@imap.cc
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kroah.org ([198.145.64.141]:45019 "EHLO coco.kroah.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751395AbZHGEHA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 7 Aug 2009 00:07:00 -0400
Content-Disposition: inline
In-Reply-To: <20090806.202227.224933454.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 06, 2009 at 08:22:27PM -0700, David Miller wrote:
> From: akpm@linux-foundation.org
> Date: Thu, 06 Aug 2009 15:19:32 -0700
> 
> > From: Tilman Schmidt <tilman@imap.cc>
> > 
> > The tty_operation chars_in_buffer() is not allowed to return a negative
> > value to signal an error.  Corrects the problem flagged by commit
> > 23198fda7182969b619613a555f8645fdc3dc334, "tty: fix chars_in_buffers".
> > 
> > Signed-off-by: Tilman Schmidt <tilman@imap.cc>
> > Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> 
> I was letting Alan Cox handle changes in this area since it's
> TTY stuff, and thus it probably should go to the new TTY
> mad man, CC:'d :-)

Thanks, I'll queue it up.

greg k-h
