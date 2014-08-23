From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/2] net: Header length compution function
Date: Sat, 23 Aug 2014 12:19:59 -0700 (PDT)
Message-ID: <20140823.121959.890509134482478336.davem@davemloft.net>
References: <53D90099.6040906@intel.com>
	<20140730.183907.1435538533126954589.davem@davemloft.net>
	<53DA61FE.40406@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, amirv@mellanox.com, netdev@vger.kernel.org,
	ogerlitz@mellanox.com, yevgenyp@mellanox.com, idos@mellanox.com
To: alexander.h.duyck@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35824 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750957AbaHWTUA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Aug 2014 15:20:00 -0400
In-Reply-To: <53DA61FE.40406@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>
Date: Thu, 31 Jul 2014 08:34:22 -0700

> On 07/30/2014 06:39 PM, David Miller wrote:
>> I don't think my proposed patch is a bad trade off.  Where we have the
>> __skb_header_pointer() thing that takes preloaded pointers and header
>> length values.  It adds only one test which frankly should never
>> trigger and can be moved down into skb_copy_bits() or similar.
> 
> This works for me.  Once it is in I can see about pushing a patch to add
> some FCoE support and work on moving over igb and ixgbe.

You should be able to do this against net-next now, just FYI.
