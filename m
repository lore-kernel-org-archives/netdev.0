From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] bridge: turn off carrier when the bridge is created
Date: Wed, 11 Mar 2015 01:29:27 -0400 (EDT)
Message-ID: <20150311.012927.708091062408959595.davem@davemloft.net>
References: <54FFAAF9.3000207@windriver.com>
	<20150311.000350.315385397499592379.davem@davemloft.net>
	<20150310222634.0e485497@urahara>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Yanjun.Zhu@windriver.com, netdev@vger.kernel.org, dsahern@gmail.com
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38728 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750707AbbCKFeZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Mar 2015 01:34:25 -0400
In-Reply-To: <20150310222634.0e485497@urahara>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <stephen@networkplumber.org>
Date: Tue, 10 Mar 2015 22:26:34 -0700

> This was discussed and changed long ago (before git was used).
> Initially in 2.5 the bridge carrier was changed to work as you have
> described but this broke some user. Therefore it was decided that the
> best thing to do was keep the carrier always on for the bridge.
> 
> You might be able to find the commit by using one of the kernel
> ancient history git trees. Kernel archeology is fun but 
> too time consuming for me to bother with.

And for that reason we are probably stuck with the current behavior.
