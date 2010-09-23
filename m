From: Greg KH <greg@kroah.com>
Subject: Re: [stable] [BUG] 2.6.32.21 bnx2_napi->hw_tx_cons_ptr NULL
 pointer dereference
Date: Thu, 23 Sep 2010 11:40:06 -0700
Message-ID: <20100923184006.GU23040@kroah.com>
References: <20100909013437.GA6400@lintop>
 <C27F8246C663564A84BB7AB3439772421B9134BA2E@IRVEXCHCCR01.corp.ad.broadcom.com>
 <20100908.215809.232892441.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: mchan@broadcom.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, shawn.bohrer@gmail.com,
	stable@kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kroah.org ([198.145.64.141]:51309 "EHLO coco.kroah.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756208Ab0IWTSc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 23 Sep 2010 15:18:32 -0400
Content-Disposition: inline
In-Reply-To: <20100908.215809.232892441.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 08, 2010 at 09:58:09PM -0700, David Miller wrote:
> From: "Michael Chan" <mchan@broadcom.com>
> Date: Wed, 8 Sep 2010 21:55:29 -0700
> 
> > Shawn Bohrer wrote:
> > 
> >> Is there any reason these can't/shouldn't be applied to the 2.6.32.y
> >> stable series?  It looks like they apply cleanly.
> >>
> > 
> > No reason.  I just didn't know how far back to apply these patches.
> > The crash was triggered by changes in netpoll some time ago and
> > the problem has been present for some time.
> 
> Michael, please submit these to -stable then, thanks!

Now queued up.

thanks,

greg k-h
