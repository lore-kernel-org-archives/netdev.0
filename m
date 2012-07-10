From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 03/16] tcp: Maintain dynamic metrics in local cache.
Date: Tue, 10 Jul 2012 08:33:06 -0700 (PDT)
Message-ID: <20120710.083306.1003488340031629044.davem@davemloft.net>
References: <20120710.080714.2272376193166978850.davem@davemloft.net>
	<1341934298.3265.5514.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38637 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751661Ab2GJPdH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Jul 2012 11:33:07 -0400
In-Reply-To: <1341934298.3265.5514.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 10 Jul 2012 17:31:38 +0200

> On Tue, 2012-07-10 at 08:07 -0700, David Miller wrote:
>> Maintain a local hash table of TCP dynamic metrics blobs.
>> 
>> Computed TCP metrics are no longer maintained in the route metrics.
>> 
>> The table uses RCU and an extremely simple hash so that it has low
>> latency and low overhead.  A simple hash is legitimate because we only
>> make metrics blobs for fully established connections.
>> 
>> Some tweaking of the default hash table sizes, metric timeouts, and
>> the hash chain length limit certainly could use some tweaking.  But
>> the basic design seems sound.
>> 
>> Signed-off-by: David S. Miller <davem@davemloft.net>
>> ---
> 
> Seems to lack namespace support, or maybe I missed something ?

It does, I'll have to add it.  Thanks for catching that.
