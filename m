From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [patch 4/4] mISDN: misc timerdev fixes II
Date: Tue, 23 Sep 2008 11:58:44 -0400
Message-ID: <20080923155844.GA30526@infradead.org>
References: <200809222151.m8MLp3tb031906@imap1.linux-foundation.org> <20080923104026.GA12535@infradead.org> <20080923043005.358e19e7.akpm@linux-foundation.org> <20080923141740.GJ25711@one.firstfloor.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@linux-foundation.org>, kkeil@suse.de,
	netdev@vger.kernel.org, ak@linux.intel.com
To: Andi Kleen <andi@firstfloor.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([18.85.46.34]:49008 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751415AbYIWP6s (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Sep 2008 11:58:48 -0400
Content-Disposition: inline
In-Reply-To: <20080923141740.GJ25711@one.firstfloor.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 23, 2008 at 04:17:40PM +0200, Andi Kleen wrote:
> > > >  static struct file_operations mISDN_fops = {
> > > > -	.llseek		= mISDN_llseek,
> > > 
> > > This is wrong.  no llseek means we use default_llseek, which is
> > > different from returning -ESPIPE.
> > 
> > so.. this?
> 
> Hmm actually on double checking it's really needed, sorry.

Yes, unfortunately the only way it's cleared currently is through using
nonseekable_open, but I've started preparing a war plan to sort this whole
mess out.
