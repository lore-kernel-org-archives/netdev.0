From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: pull request: wireless-2.6 2008-06-03
Date: Wed, 4 Jun 2008 16:54:20 -0400
Message-ID: <20080604205420.GA32186@tuxdriver.com>
References: <20080603190943.GB28966@tuxdriver.com> <20080603.141652.245225529.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-wireless@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([70.61.120.52]:4327 "EHLO ra.tuxdriver.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754172AbYFDV3I (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Jun 2008 17:29:08 -0400
Content-Disposition: inline
In-Reply-To: <20080603.141652.245225529.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 03, 2008 at 02:16:52PM -0700, David Miller wrote:
> From: "John W. Linville" <linville@tuxdriver.com>
> Date: Tue, 3 Jun 2008 15:09:43 -0400
> 
> > Kirill A. Shutemov (1):
> >       wireless.h: improve userland include-ability
> 
> I'm not pulling this into my tree.  I've already replied
> to that patch posting saying why I don't like this.

For the record, I didn't get that posting until just _after_ I got this
reply from you -- a mail server somewhere must have had indigestion!

> Even if I found this change as the only way to go and therefore
> had to take it in, the commit log is way too terse about what
> the problem is.  And it must describe the horrifics that are
> now necessary to include this file in userspace after the change.

FWIW, I'll take the blame for the overly terse commit log...

> There is zero point in us sanitizing kernel headers for userspace
> usage if this kind of crap is still necessary.  I mean tell me, why
> should we even bother in that case?  And this is why I'm not taking in
> this changeset.

Please see the discussion on the other thread, in case you have
something to add or something there persuades you.  In the meantime,
I retract this pull request and will soon follow with a rebased pull
request that expunges the wireless.h commit.

John
-- 
John W. Linville
linville@tuxdriver.com
