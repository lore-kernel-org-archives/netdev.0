From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH v3 4/5] fm10k/igb/ixgbe: Replace
 __skb_alloc_page with dev_alloc_page
Date: Tue, 11 Nov 2014 12:48:26 -0500 (EST)
Message-ID: <20141111.124826.2036471212277751765.davem@davemloft.net>
References: <20141111172523.16460.16845.stgit@ahduyck-vm-fedora20>
	<20141111172657.16460.60596.stgit@ahduyck-vm-fedora20>
	<1415726904.2466.170.camel@jtkirshe-mobl>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: alexander.h.duyck@redhat.com, netdev@vger.kernel.org,
	linux-usb@vger.kernel.org, leedom@chelsio.com,
	hariprasad@chelsio.com, donald.c.skidmore@intel.com,
	oliver@neukum.org, balbi@ti.com, matthew.vick@intel.com,
	mgorman@suse.de
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59617 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751152AbaKKRsd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Nov 2014 12:48:33 -0500
In-Reply-To: <1415726904.2466.170.camel@jtkirshe-mobl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Tue, 11 Nov 2014 09:28:24 -0800

> On Tue, 2014-11-11 at 09:26 -0800, Alexander Duyck wrote:
>> The Intel drivers were pretty much just using the plain vanilla GFP
>> flags
>> in their calls to __skb_alloc_page so this change makes it so that
>> they use
>> dev_alloc_page which just uses GFP_ATOMIC for the gfp_flags value.
>> 
>> Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
>> Cc: Matthew Vick <matthew.vick@intel.com>
>> Cc: Don Skidmore <donald.c.skidmore@intel.com>
>> Signed-off-by: Alexander Duyck <alexander.h.duyck@redhat.com>
>> ---
>>  drivers/net/ethernet/intel/fm10k/fm10k_main.c |    2 +-
>>  drivers/net/ethernet/intel/igb/igb_main.c     |    2 +-
>>  drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |    3 +--
>>  3 files changed, 3 insertions(+), 4 deletions(-)
> 
> Thanks Alex, I will add the patch to my queue.

I think this entire series will need to go via my tree, because the
conversions are all required for patch #5 which removes the replaced
interface altogether.
