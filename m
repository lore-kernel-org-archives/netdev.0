From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Removal of debug code containing deprecated calls to
 cli()/sti()
Date: Sat, 19 Apr 2008 18:12:02 -0700 (PDT)
Message-ID: <20080419.181202.247094241.davem@davemloft.net>
References: <20080418190729.GE20637@parisc-linux.org>
	<1208568380-22219-1-git-send-email-mark.asselstine@windriver.com>
	<20080419013018.GG20637@parisc-linux.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mark.asselstine@windriver.com, kernel-janitors@vger.kernel.org,
	chas@cmf.nrl.navy.mil, netdev@vger.kernel.org
To: matthew@wil.cx
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53041
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752566AbYDTBMA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 19 Apr 2008 21:12:00 -0400
In-Reply-To: <20080419013018.GG20637@parisc-linux.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Matthew Wilcox <matthew@wil.cx>
Date: Fri, 18 Apr 2008 19:30:18 -0600

> On Fri, Apr 18, 2008 at 09:26:20PM -0400, Mark Asselstine wrote:
> > Code within NS_DEBUG_SPINLOCKS contained deprecated cli()/sti() function calls.
> > NS_DEBUG_SPINLOCKS and the associated code seems to be of little use these days
> > so the strategy of removing this code rather then updating it to use spinlocks
> > has been taken.
> > 
> > Signed-off-by: Mark Asselstine <mark.asselstine@windriver.com>
> Reviewed-by: Matthew Wilcox <willy@linux.intel.com>

Applied, thanks everyone.
