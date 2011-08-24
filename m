From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] rps: support IPIP encapsulation
Date: Wed, 24 Aug 2011 16:14:13 -0700 (PDT)
Message-ID: <20110824.161413.146713540632470238.davem@davemloft.net>
References: <1314218479.2506.15.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, therbert@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:44599 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751547Ab1HXXOV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Aug 2011 19:14:21 -0400
In-Reply-To: <1314218479.2506.15.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 24 Aug 2011 22:41:19 +0200

> Skip IPIP header to get proper layer-4 information.
> 
> Like GRE tunnels, this only works if rxhash is not already provided by
> the device itself (ethtool -K ethX rxhash off), to allow kernel compute
> a software rxhash.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied, thanks.
