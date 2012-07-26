From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv4: Fix input route performance regression.
Date: Thu, 26 Jul 2012 15:53:35 -0700 (PDT)
Message-ID: <20120726.155335.1853505326933171952.davem@davemloft.net>
References: <20120726.141438.1996323620706359167.davem@davemloft.net>
	<1343340989.2626.12087.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: alexander.duyck@gmail.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57000 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753057Ab2GZWxf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Jul 2012 18:53:35 -0400
In-Reply-To: <1343340989.2626.12087.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 27 Jul 2012 00:16:29 +0200

> On Thu, 2012-07-26 at 14:14 -0700, David Miller wrote:
>> With the routing cache removal we lost the "noref" code paths on
>> input, and this can kill some routing workloads.
>> 
>> Reinstate the noref path when we hit a cached route in the FIB
>> nexthops.
>> 
>> With help from Eric Dumazet.
>> 
>> Reported-by: Alexander Duyck <alexander.duyck@gmail.com>
>> Signed-off-by: David S. Miller <davem@davemloft.net>
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Thanks for reviewing.
