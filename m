From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: Re: [PATCH 17/39] mv643xx_eth: use 'mv643xx_eth_' prefix consistently
Date: Fri, 6 Jun 2008 09:09:51 +0200
Message-ID: <20080606070951.GB5100@xi.wantstofly.org>
References: <1212490974-23719-1-git-send-email-buytenh@wantstofly.org> <1212490974-23719-18-git-send-email-buytenh@wantstofly.org> <20080605115903.GF3807@farnsworth.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Dale Farnsworth <dale@farnsworth.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xi.wantstofly.org ([83.160.184.112]:45539 "EHLO
	xi.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753286AbYFFHKY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Jun 2008 03:10:24 -0400
Content-Disposition: inline
In-Reply-To: <20080605115903.GF3807@farnsworth.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jun 05, 2008 at 04:59:04AM -0700, Dale Farnsworth wrote:

> > A bunch of places in the mv643xx_eth driver use the 'mv643xx_'
> > prefix.  Since the mv643xx is a chip that includes more than just
> > ethernet, this patch makes all those places use either no prefix
> > (for some internal-use-only functions), or the full 'mv643xx_eth_'
> > prefix.
> > 
> > Signed-off-by: Lennert Buytenhek <buytenh@marvell.com>
> > ---
> >  drivers/net/mv643xx_eth.c | 1169 +++++++++++++++++++++++----------------------
> >  1 files changed, 585 insertions(+), 584 deletions(-)
> 
> I'm not sure it's worth changing all the local vars from mp to mep,
> but it's not a big deal.

Well, you're right -- that change is retarded.  I'll just pull
that out.
