From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] dl2k: Clean up rio_ioctl
Date: Thu, 26 Apr 2012 05:38:59 -0400 (EDT)
Message-ID: <20120426.053859.370303075509597686.davem@davemloft.net>
References: <4F989789.9040405@suse.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: jeffm@suse.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:58406 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753941Ab2DZJjE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Apr 2012 05:39:04 -0400
In-Reply-To: <4F989789.9040405@suse.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Mahoney <jeffm@suse.com>
Date: Wed, 25 Apr 2012 20:32:09 -0400

> The dl2k driver's rio_ioctl call has a few issues:
> - No permissions checking
> - Implements SIOCGMIIREG and SIOCGMIIREG using the SIOCDEVPRIVATE numbers
> - Has a few ioctls that may have been used for debugging at one point
>   but have no place in the kernel proper.
> 
> This patch removes all but the MII ioctls, renumbers them to use the
> standard ones, and adds the proper permission check for SIOCSMIIREG.
> 
> We can also get rid of the dl2k-specific struct mii_data in favor of
> the generic struct mii_ioctl_data.
> 
> Since we have the phyid on hand, we can add the SIOCGMIIPHY ioctl too.
> 
> Most of the MII code for the driver could probably be converted to use
> the generic MII library but I don't have a device to test the results.
> 
> Reported-by: Stephan Mueller <stephan.mueller@atsec.com>
> Signed-off-by: Jeff Mahoney <jeffm@suse.com>

Applied, thanks.
