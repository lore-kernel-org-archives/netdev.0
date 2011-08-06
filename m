From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH] enic: Add timestamp to network interface
 stats
Date: Fri, 05 Aug 2011 23:25:35 -0700 (PDT)
Message-ID: <20110805.232535.445092900994011542.davem@davemloft.net>
References: <20110805001124.32402.42919.stgit@savbu-pc100.cisco.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dannguo@cisco.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:45792 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750917Ab1HFGZg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 6 Aug 2011 02:25:36 -0400
In-Reply-To: <20110805001124.32402.42919.stgit@savbu-pc100.cisco.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Danny Guo <dannguo@cisco.com>
Date: Thu, 04 Aug 2011 17:11:24 -0700

> From: Danny Guo <dannguo@cisco.com>
> 
> This patch adds timestamps in ethtool stats. It makes it easier to provide scripts to users to calculate throughput, etc. It also allows software to synchronize timestamps with host time for correlating host events with stats collection.
> 
> Signed-off-by: Danny Guo <dannguo@cisco.com>
> Signed-off-by: Vasanthy Kolluri <vkolluri@cisco.com>
> Signed-off-by: Roopa Prabhu <roprabhu@cisco.com>
> Signed-off-by: David Wang <dwang2@cisco.com>

It's "easier" but only for your specific driver if we let this patch
go in.

Everyone tends to come up with the "easy" but localized and selfish
solution.

We have not one but several rate estimators in the kernel, if that's
unusable then fix them instead of just going for private facilities
that only will work with your driver.

I'm not applying this, sorry.
