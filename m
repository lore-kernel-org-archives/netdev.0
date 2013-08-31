From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] etherdevice: Optimize
 compare_ether_addr/ether_addr_equal
Date: Sat, 31 Aug 2013 18:27:50 -0400 (EDT)
Message-ID: <20130831.182750.678717944135962097.davem@davemloft.net>
References: <1377939256.2054.11.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org
To: joe@perches.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44787 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754913Ab3HaW1w (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 31 Aug 2013 18:27:52 -0400
In-Reply-To: <1377939256.2054.11.camel@joe-AO722>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joe Perches <joe@perches.com>
Date: Sat, 31 Aug 2013 01:54:16 -0700

> When CONFIG_HAS_EFFICIENT_UNALIGNED_ACCESS is set,
> optimize compare_ether_addr a little by removing an
> xor and or by using a u32 and u16 comparison
> instead of 3 separate u16 comparisons.
> 
> Make the ether_addr_equal_64bits code a bit simpler
> by adding a test for CONFIG_64BIT and calling
> ether_addr_equal otherwise.
> 
> This also slightly improves ether_addr_equal_64bits
> by removing the zap_last_2bytes shifts in the !64bit
> case.
> 
> Signed-off-by: Joe Perches <joe@perches.com>

You'll need to update Documantion/unaligned-memory-access.txt as well
because it uses this funcation as a "real life" example.
