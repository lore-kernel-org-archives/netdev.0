From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/3] net: ipv4: fix potential memory leak by
 assigning uhash_entries
Date: Tue, 21 Jun 2011 22:32:59 -0700 (PDT)
Message-ID: <20110621.223259.269892963081243064.davem@davemloft.net>
References: <1308689020-1873-1-git-send-email-paul.gortmaker@windriver.com>
	<1308689020-1873-2-git-send-email-paul.gortmaker@windriver.com>
	<1308719087.2713.4.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: paul.gortmaker@windriver.com, netdev@vger.kernel.org,
	mark.asselstine@windriver.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:45810 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751221Ab1FVFdO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Jun 2011 01:33:14 -0400
In-Reply-To: <1308719087.2713.4.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 22 Jun 2011 07:04:46 +0200

> Arg no, I really wanted to get more hash slots in my 32bit machines,
> with 4Gbytes of memory.
> 
> Here is what I currently have (without your patch)
> 
> [    1.903086] UDP hash table entries: 512 (order: 2, 16384 bytes)
> 
> 
> I mean, this kmemleak was already reported.
> 
> 32MB machines are things of the past.
> 
> If you really care, please add a change to alloc_large_system_hash() ?

Crap, I thought that argument to alloc_large_system_hash() provided a
lower bound.

Indeed, I'm going to revert this patch.
