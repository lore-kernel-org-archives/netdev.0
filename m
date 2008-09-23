From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [patch 4/4] mISDN: misc timerdev fixes II
Date: Tue, 23 Sep 2008 16:17:40 +0200
Message-ID: <20080923141740.GJ25711@one.firstfloor.org>
References: <200809222151.m8MLp3tb031906@imap1.linux-foundation.org> <20080923104026.GA12535@infradead.org> <20080923043005.358e19e7.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Christoph Hellwig <hch@infradead.org>, kkeil@suse.de,
	netdev@vger.kernel.org, andi@firstfloor.org, ak@linux.intel.com
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:50300 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751445AbYIWOMq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Sep 2008 10:12:46 -0400
Content-Disposition: inline
In-Reply-To: <20080923043005.358e19e7.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 23, 2008 at 04:30:05AM -0700, Andrew Morton wrote:
> On Tue, 23 Sep 2008 06:40:26 -0400 Christoph Hellwig <hch@infradead.org> wrote:
> 
> > On Mon, Sep 22, 2008 at 02:51:03PM -0700, akpm@linux-foundation.org wrote:
> > > From: Andi Kleen <andi@firstfloor.org>
> > > 
> > > - Remove noop VFS stubs. The VFS does that on a NULL pointer anyways.
> > 
> > > -static loff_t
> > > -mISDN_llseek(struct file *filep, loff_t offset, int orig)
> > > -{
> > > -	return -ESPIPE;
> > > -}
> > 
> > >  static struct file_operations mISDN_fops = {
> > > -	.llseek		= mISDN_llseek,
> > 
> > This is wrong.  no llseek means we use default_llseek, which is
> > different from returning -ESPIPE.
> 
> so.. this?

Hmm actually on double checking it's really needed, sorry.

-Andi
