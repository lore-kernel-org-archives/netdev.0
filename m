From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: Fix locking bug in netif_set_xps_queue
Date: Fri, 22 Feb 2013 15:14:42 -0500 (EST)
Message-ID: <20130222.151442.333174353561165623.davem@davemloft.net>
References: <20130222163806.7590.98066.stgit@ahduyck-cp1.jf.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, fengguang.wu@intel.com,
	dan.carpenter@oracle.com, jeffrey.t.kirsher@intel.com
To: alexander.h.duyck@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46864 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757322Ab3BVUOo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Feb 2013 15:14:44 -0500
In-Reply-To: <20130222163806.7590.98066.stgit@ahduyck-cp1.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>
Date: Fri, 22 Feb 2013 08:38:44 -0800

> Smatch found a locking bug in netif_set_xps_queue in which we were not
> releasing the lock in the case of an allocation failure.
> 
> This change corrects that so that we release the xps_map_mutex before
> returning -ENOMEM in the case of an allocation failure.
> 
> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>

Applied and queue up for -stable, thanks Alex.
