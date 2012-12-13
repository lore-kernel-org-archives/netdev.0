From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH 1/1] net: cpts: fix for build break after ARM SoC
 integration
Date: Thu, 13 Dec 2012 14:03:36 +0100
Message-ID: <20121213130335.GA10703@netboy.at.omicron.at>
References: <1354012034-31686-1-git-send-email-mugunthanvnm@ti.com>
 <50C9B6F9.9020300@iki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Mugunthan V N <mugunthanvnm@ti.com>, netdev@vger.kernel.org,
	davem@davemloft.net, linux-arm-kernel@lists.infradead.org,
	linux-omap@vger.kernel.org, b-cousson@ti.com, paul@pwsan.com
To: Tomi Valkeinen <tomba@iki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:52389 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753210Ab2LMNDu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Dec 2012 08:03:50 -0500
Content-Disposition: inline
In-Reply-To: <50C9B6F9.9020300@iki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 13, 2012 at 01:07:37PM +0200, Tomi Valkeinen wrote:
> Hi,
> 
> On 2012-11-27 12:27, Mugunthan V N wrote:
> >   CC      drivers/net/ethernet/ti/cpts.o
> > drivers/net/ethernet/ti/cpts.c:30:24: fatal error: plat/clock.h: No such file or directory
> > compilation terminated.
> > make[4]: *** [drivers/net/ethernet/ti/cpts.o] Error 1
> > make[3]: *** [drivers/net/ethernet/ti] Error 2
> > make[2]: *** [drivers/net/ethernet] Error 2
> > make[1]: *** [drivers/net] Error 2
> > 
> > fix for build break as the header file is removed from plat-omap as part of
> > the below patch
> 
> linux-next still has this build problem, I guess this patch is lingering
> somewhere. Somewhat annoying, as the driver is enabled by default. (btw,
> why is it "default y"?)

Um, in Linus' master, net, and net-next, neither TI_CPSW nor TI_CPTS
are default y, so I don't know where you are coming from on that.

Sorry,
Richard
