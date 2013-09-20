From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] mrp: add periodictimer to allow retries when
 packets get lost
Date: Fri, 20 Sep 2013 14:59:03 -0400 (EDT)
Message-ID: <20130920.145903.1454447110808820874.davem@davemloft.net>
References: <1379528419.1787.50.camel@joe-AO722>
	<1379532280-11047-1-git-send-email-noel@burton-krahn.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, joe@perches.com, david.ward@ll.mit.edu
To: noel@burton-krahn.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39580 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752129Ab3ITS7F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Sep 2013 14:59:05 -0400
In-Reply-To: <1379532280-11047-1-git-send-email-noel@burton-krahn.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Noel Burton-Krahn <noel@burton-krahn.com>
Date: Wed, 18 Sep 2013 12:24:40 -0700

> MRP doesn't implement the periodictimer in 802.1Q, so it never retries
> if packets get lost.  I ran into this problem when MRP sent a MVRP
> JoinIn before the interface was fully up.  The JoinIn was lost, MRP
> didn't retry, and MVRP registration failed.
> 
> Tested against Juniper QFabric switches
> 
> Signed-off-by: Noel Burton-Krahn <noel@burton-krahn.com>

David W., please review this patch.

Thanks.
