From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: [patch 1/4] drivers/atm/firestream.c: suppress uninitialized var warning
Date: Mon, 31 Mar 2008 16:57:32 +0100
Message-ID: <20080331155732.GK9785@ZenIV.linux.org.uk>
References: <20080328165437.bfd7726c.akpm@linux-foundation.org> <20080328.165812.253071507.davem@davemloft.net> <20080328171128.ff03ec02.akpm@linux-foundation.org> <20080328.173523.66723417.davem@davemloft.net> <20080328173946.23903be0.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	chas@cmf.nrl.navy.mil, jeff@garzik.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:47755 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750943AbYCaP5h (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Mar 2008 11:57:37 -0400
Content-Disposition: inline
In-Reply-To: <20080328173946.23903be0.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 28, 2008 at 05:39:46PM -0700, Andrew Morton wrote:
> On Fri, 28 Mar 2008 17:35:23 -0700 (PDT) David Miller <davem@davemloft.net> wrote:
> 
> > From: Andrew Morton <akpm@linux-foundation.org>
> > Date: Fri, 28 Mar 2008 17:11:28 -0700
> > 
> > > Plus uninitialized_var() gives us something to grep for and
> > > experiment with if/when future gcc's get smarter.
> > 
> > That's sounds like a great investment of your time.
> > 
> > I guess there aren't any more interesting things to work
> > on, nor bugs to fix.
> 
> So you're all outa reasons.

Not really...  "we know better, gcc must STFU" applies _now_.  And gcc getting
smarter is not the only way it can become false - code change in the function
can create real uninitialized use.  gcc tends to change the warning on that,
but not if it's told to STFU in either way.

IOW, my preference would be to leave the warning as is.
