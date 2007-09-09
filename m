From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [-mm patch] unexport raise_softirq_irqoff
Date: Sun, 9 Sep 2007 21:41:53 +0100
Message-ID: <20070909204153.GB11764@infradead.org>
References: <20070831215822.26e1432b.akpm@linux-foundation.org> <20070909202544.GV3563@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@linux-foundation.org>, davem@davemloft.net,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Adrian Bunk <bunk@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:52660 "EHLO
	pentafluge.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754321AbXIIUl6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 9 Sep 2007 16:41:58 -0400
Content-Disposition: inline
In-Reply-To: <20070909202544.GV3563@stusta.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Sep 09, 2007 at 10:25:44PM +0200, Adrian Bunk wrote:
> On Fri, Aug 31, 2007 at 09:58:22PM -0700, Andrew Morton wrote:
> >...
> > Changes since 2.6.23-rc3-mm1:
> >...
> >  git-net.patch
> >...
> >  git trees
> >...
> 
> raise_softirq_irqoff no longer has any modular user.
> 
> Signed-off-by: Adrian Bunk <bunk@kernel.org>

This should probably go in through Dave's tree as it's removing this
rather annoying user.

