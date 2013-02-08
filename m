From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] skbuff: Move definition of NETDEV_FRAG_PAGE_MAX_SIZE
Date: Fri, 08 Feb 2013 17:34:26 -0500 (EST)
Message-ID: <20130208.173426.995535263950174099.davem@davemloft.net>
References: <20130208201710.27890.52546.stgit@ahduyck-cp1.jf.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com,
	jeffrey.t.kirsher@intel.com
To: alexander.h.duyck@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37939 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758163Ab3BHWea (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Feb 2013 17:34:30 -0500
In-Reply-To: <20130208201710.27890.52546.stgit@ahduyck-cp1.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>
Date: Fri, 08 Feb 2013 12:17:15 -0800

> In order to address the fact that some devices cannot support the full 32K
> frag size we need to have the value accessible somewhere so that we can use it
> to do comparisons against what the device can support.  As such I am moving
> the values out of skbuff.c and into skbuff.h.
> 
> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>

Applied, thanks.

Although it was obvious to me due to context, please annotate your
subject lines with the target GIT tree as in "[PATCH net-next]: ..."
in the future.

Thanks.
