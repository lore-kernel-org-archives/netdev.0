From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH v3 0/5] Replace __skb_alloc_pages with simpler
 function
Date: Wed, 12 Nov 2014 00:11:29 -0500 (EST)
Message-ID: <20141112.001129.2013375082193967583.davem@davemloft.net>
References: <20141111172523.16460.16845.stgit@ahduyck-vm-fedora20>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-usb@vger.kernel.org,
	leedom@chelsio.com, hariprasad@chelsio.com,
	donald.c.skidmore@intel.com, oliver@neukum.org, balbi@ti.com,
	matthew.vick@intel.com, mgorman@suse.de,
	jeffrey.t.kirsher@intel.com
To: alexander.h.duyck@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37728 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750956AbaKLFLg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Nov 2014 00:11:36 -0500
In-Reply-To: <20141111172523.16460.16845.stgit@ahduyck-vm-fedora20>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@redhat.com>
Date: Tue, 11 Nov 2014 09:26:26 -0800

> This patch series replaces __skb_alloc_pages with a much simpler function,
> __dev_alloc_pages.  The main difference between the two is that
> __skb_alloc_pages had an sk_buff pointer that was being passed as NULL in
> call places where it was called.  In a couple of cases the NULL was passed
> by variable and this led to unnecessary code being run.
> 
> As such in order to simplify things the __dev_alloc_pages call only takes a
> mask and the page order being requested.  In addition it takes advantage of
> several behaviors already built into the page allocator so that it can just
> set GFP flags unconditionally.
> 
> v2: Renamed functions to dev_alloc_page(s) instead of netdev_alloc_page(s)
>     Removed __GFP_COLD flag from usb code as it was redundant
> v3: Update patch descriptions and subjects to match changes in v2

Series applied, thanks Alexander.
