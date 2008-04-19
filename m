From: Matthew Wilcox <matthew@wil.cx>
Subject: Re: [PATCH] Removal of debug code containing deprecated calls to cli()/sti()
Date: Fri, 18 Apr 2008 19:30:18 -0600
Message-ID: <20080419013018.GG20637@parisc-linux.org>
References: <20080418190729.GE20637@parisc-linux.org> <1208568380-22219-1-git-send-email-mark.asselstine@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kernel-janitors@vger.kernel.org, chas@cmf.nrl.navy.mil,
	netdev@vger.kernel.org
To: Mark Asselstine <mark.asselstine@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from palinux.external.hp.com ([192.25.206.14]:32863 "EHLO
	mail.parisc-linux.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751104AbYDSBaU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Apr 2008 21:30:20 -0400
Content-Disposition: inline
In-Reply-To: <1208568380-22219-1-git-send-email-mark.asselstine@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Apr 18, 2008 at 09:26:20PM -0400, Mark Asselstine wrote:
> Code within NS_DEBUG_SPINLOCKS contained deprecated cli()/sti() function calls.
> NS_DEBUG_SPINLOCKS and the associated code seems to be of little use these days
> so the strategy of removing this code rather then updating it to use spinlocks
> has been taken.
> 
> Signed-off-by: Mark Asselstine <mark.asselstine@windriver.com>
Reviewed-by: Matthew Wilcox <willy@linux.intel.com>

-- 
Intel are signing my paycheques ... these opinions are still mine
"Bill, look, we understand that you're interested in selling us this
operating system, but compare it to ours.  We can't possibly take such
a retrograde step."
