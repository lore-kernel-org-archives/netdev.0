From: David Woodhouse <dwmw2@infradead.org>
Subject: Re: [patch nacked? 3/4] Update smc91x driver with ARM Versatile
	board info
Date: Thu, 31 Jul 2008 11:16:59 +0100
Message-ID: <1217499419.3454.120.camel@pmac.infradead.org>
References: <200807301940.m6UJemPm012683@imap1.linux-foundation.org>
	 <20080730224255.GB12409@flint.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, jeff@garzik.org, netdev@vger.kernel.org,
	dsaxena@plexity.net, nico@cam.org
To: Russell King <rmk@arm.linux.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([18.85.46.34]:37807 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753480AbYGaKRe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Jul 2008 06:17:34 -0400
In-Reply-To: <20080730224255.GB12409@flint.arm.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2008-07-30 at 23:42 +0100, Russell King wrote:

> From: Deepak Saxena <dsaxena@plexity.net>
> > We need to specify a Versatile-specific SMC_IRQ_FLAGS value or the new
> > generic IRQ layer will complain thusly:
> > 
> > No IRQF_TRIGGER set_type function for IRQ 25 (<NULL>)

> smc91x.h _already_ contains a CONFIG_ARCH_VERSATILE section

I think the point here is that there is already a section for this board
in the driver, so any patch which adds it _again_ is wrong.

It seems to have existing definitions for everything that this patch
adds, all of which are duplicates except SMC_IRQ_FLAGS, which is defined
as (0) in this patch but as (-1) in the existing driver.

So this patch should be dropped -- if there's a need to change the
definition of SMC_IRQ_FLAGS to 0, that's a one-line patch which needs a
more appropriate comment.

-- 
David Woodhouse                            Open Source Technology Centre
David.Woodhouse@intel.com                              Intel Corporation



