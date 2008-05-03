From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch 1/2] smsc-ircc2: wrap PNP probe code in #ifdef
 CONFIG_PNP
Date: Fri, 2 May 2008 18:55:11 -0700
Message-ID: <20080502185511.f20525b2.akpm@linux-foundation.org>
References: <200805022040.m42KeN16013646@imap1.linux-foundation.org>
	<20080502143802.8fb86319.akpm@linux-foundation.org>
	<20080503114617.1c063759.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: samuel@sortiz.org, netdev@vger.kernel.org, bjorn.helgaas@hp.com,
	kamalesh@linux.vnet.ibm.com
To: Stephen Rothwell <sfr@canb.auug.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:33034 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757274AbYECBza (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 May 2008 21:55:30 -0400
In-Reply-To: <20080503114617.1c063759.sfr@canb.auug.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 3 May 2008 11:46:17 +1000 Stephen Rothwell <sfr@canb.auug.org.au> wrote:

> Hi Andrew,
> 
> On Fri, 2 May 2008 14:38:02 -0700 Andrew Morton <akpm@linux-foundation.org> wrote:
> >
> > On Fri, 02 May 2008 13:40:23 -0700
> > akpm@linux-foundation.org wrote:
> > 
> > > From: Bjorn Helgaas <bjorn.helgaas@hp.com>
> > > 
> > > Wrap PNP probe code in #ifdef CONFIG_PNP.
> > > 
> > > Without this change, we'll have unresolved references to pnp_get_resource()
> > > function when CONFIG_PNP=n.  (This is a new interface that's not in mainline
> > > yet.)
> > 
> > hrm, it turns out that this is already in linux-next, only I'm
> > not sure by what route it got there.
> 
> I put it there directly at the end so that the tee would build for various
> configs.  I have been carrying it for some time.  I am also carrying a
> similar patch for nsc-ircc.  I will remove them when someone puts them
> into some other tree that I am merging.

argh, that's a process problem.

When those patches turn up in linux-next, I will assume that someone merged
them into a git tree and I will drop them.

You now own the sole copy.  If you drop them, they are lost.  If you don't
send them to anyone, you own them forever.

So..  what to do about this?  I think the only solution is for you to go
into akpm mode and start desperately trying to entice someone into merging
the patch.

