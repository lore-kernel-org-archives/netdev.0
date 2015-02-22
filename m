From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] rhashtable: ensure cache line alignment on
 bucket_table
Date: Sat, 21 Feb 2015 22:00:09 -0500 (EST)
Message-ID: <20150221.220009.368721064777950308.davem@davemloft.net>
References: <1424443737.5565.12.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tgraf@suug.ch
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36848 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752394AbbBVDAL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Feb 2015 22:00:11 -0500
In-Reply-To: <1424443737.5565.12.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 20 Feb 2015 06:48:57 -0800

> From: Eric Dumazet <edumazet@google.com>
> 
> struct bucket_table contains mostly read fields :
> 
> size, locks_mask, locks.
> 
> Make sure these are not sharing a cache line with buckets[]
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied.
