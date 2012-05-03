From: David Miller <davem@davemloft.net>
Subject: Re: [v2 PATCH 3/4] tcp: move stats merge to the end of
 tcp_try_coalesce
Date: Thu, 03 May 2012 04:22:16 -0400 (EDT)
Message-ID: <20120503.042216.931999586895319546.davem@davemloft.net>
References: <20120503071141.13636.37564.stgit@gitlad.jf.intel.com>
	<20120503071909.13636.43086.stgit@gitlad.jf.intel.com>
	<1336031565.3503.25.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: alexander.h.duyck@intel.com, netdev@vger.kernel.org,
	jeffrey.t.kirsher@intel.com, edumazet@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:41096 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754690Ab2ECIWV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 May 2012 04:22:21 -0400
In-Reply-To: <1336031565.3503.25.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 03 May 2012 09:52:45 +0200

> On Thu, 2012-05-03 at 00:19 -0700, Alexander Duyck wrote:
>> This change cleans up the last bits of tcp_try_coalesce so that we only
>> need one goto which jumps to the end of the function.  The idea is to make
>> the code more readable by putting things in a linear order so that we start
>> execution at the top of the function, and end it at the bottom.
>> 
>> I also made a slight tweak to the code for handling frags when we are a
>> clone.  Instead of making it an if (clone) loop else nr_frags = 0 I changed
>> the logic so that if (!clone) we just set the number of frags to 0 which
>> disables the for loop anyway.
>> 
>> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
 ...
> Thanks a lot Alex, this patch serie looks very good.
> 
> Acked-by: Eric Dumazet <edumazet@google.com>

Applied.
