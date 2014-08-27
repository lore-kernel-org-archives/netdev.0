From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v4 01/13] net: dsa: reduce number of protocol
 hooks
Date: Wed, 27 Aug 2014 16:24:58 -0700 (PDT)
Message-ID: <20140827.162458.878869941352643208.davem@davemloft.net>
References: <1409028581-17399-1-git-send-email-f.fainelli@gmail.com>
	<1409028581-17399-2-git-send-email-f.fainelli@gmail.com>
	<53FDF879.1000504@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: f.fainelli@gmail.com, netdev@vger.kernel.org,
	linville@tuxdriver.com, jhs@mojatatu.com, alexander.duyck@gmail.com
To: alexander.h.duyck@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41711 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965120AbaH0XZA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Aug 2014 19:25:00 -0400
In-Reply-To: <53FDF879.1000504@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>
Date: Wed, 27 Aug 2014 08:25:45 -0700

> Just a thought, you might want to consider using a protocol value other
> than ETH_P_DSA.  Maybe we should add a new value named ETH_P_XDSA for
> this approach since what we are doing is a multiplexed DSA protocol now.
> 
> This would allow for much easier back-porting of this if needed and also
> prevents us from possibly triggering any issues if there are any
> user-space APIs that might be trying to capture packets based on the
> protocol value.

Agreed, Florian can you respin this patch set using a newly allocated
ETH_P_* value for these new semantics?

Thanks.
