From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 0/3] Drop get_headlen functions in favor of
 generic function
Date: Fri, 05 Sep 2014 17:47:29 -0700 (PDT)
Message-ID: <20140905.174729.2145013721791180379.davem@davemloft.net>
References: <20140905231807.2035.33588.stgit@ahduyck-bv4.jf.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com,
	jeffrey.t.kirsher@intel.com
To: alexander.h.duyck@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58074 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750762AbaIFArb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Sep 2014 20:47:31 -0400
In-Reply-To: <20140905231807.2035.33588.stgit@ahduyck-bv4.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>
Date: Fri, 05 Sep 2014 19:20:12 -0400

> This series replaces the igb_get_headlen and ixgbe_get_headlen functions
> with a generic function named eth_get_headlen.
> 
> I have done some performance testing on ixgbe with 258 byte frames since
> the calls are only used on frames larger than 256 bytes and have seen no
> significant difference in CPU utilization.
> 
> v2: renamed __skb_get_poff to skb_get_poff
>     renamed ___skb_get_poff to __skb_get_poff

Nice work, series applied, thanks Alex.
