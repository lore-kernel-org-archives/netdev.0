From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: [PATCH] tg3: add amd8131 to "write reorder" chipsets
Date: Fri, 7 Jul 2006 16:16:58 -0400
Message-ID: <20060707201653.GE22636@tuxdriver.com>
References: <1551EAE59135BE47B544934E30FC4FC041BD9B@NT-IRVA-0751.brcm.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([70.61.120.52]:36870 "EHLO ra.tuxdriver.com")
	by vger.kernel.org with ESMTP id S1751231AbWGGURO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Jul 2006 16:17:14 -0400
To: Michael Chan <mchan@broadcom.com>
Content-Disposition: inline
In-Reply-To: <1551EAE59135BE47B544934E30FC4FC041BD9B@NT-IRVA-0751.brcm.ad.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jul 07, 2006 at 12:51:35PM -0700, Michael Chan wrote:
> John W. Linville wrote:
> 
> > Add the AMD 8131 bridge to the list of chipsets that reorder writes.
> > 
> > Signed-off-by: John W. Linville <linville@tuxdriver.com>
> 
> Hi John,
> 
> The latest tg3 driver in 2.6.18 has a recovery mechanism to detect
> and recover from this kind of reordering problem.  I suppose we can
> add this chipset now if we're reasonably sure that it is reordering
> MMIO.  But it will be nice to actually see the recovery mechanism in
> action catching this chipset.

Obviously it is between you and Dave to decide what is best.  We are
carrying this patch in RHEL4 at the moment, so I didn't want to hold
it back from upstream.  If you think you have a better solution then
"it's on you"... :-)

John
-- 
John W. Linville
linville@tuxdriver.com
