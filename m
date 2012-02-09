From: David Miller <davem@davemloft.net>
Subject: Re: [patch] bna: fix error handling of
 bnad_get_flash_partition_by_offset()
Date: Thu, 09 Feb 2012 15:43:41 -0500 (EST)
Message-ID: <20120209.154341.1329684491104733307.davem@davemloft.net>
References: <20120209104934.GC5540@elgon.mountain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: rmody@brocade.com, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: dan.carpenter@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:58544 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757814Ab2BIUor (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Feb 2012 15:44:47 -0500
In-Reply-To: <20120209104934.GC5540@elgon.mountain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Thu, 9 Feb 2012 13:49:34 +0300

> The current error handling doesn't work because we flash_part is a u32
> so the checks for negative error codes don't work.  I considered making
> things signed but I don't know the hardware enough to say if that's a
> problem.  Really, we don't use the error codes so just returning zero
> for all problems is fine.
> 
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

Looks good, applied, thanks Dan.
