From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 14/14] net: smc91x: dont't use SMC_outw for fixing up
 halfword-aligned data
Date: Fri, 11 Oct 2013 17:56:22 -0400 (EDT)
Message-ID: <20131011.175622.988103254853137065.davem@davemloft.net>
References: <1381499540-28794-1-git-send-email-matthew.leach@arm.com>
	<1381499540-28794-15-git-send-email-matthew.leach@arm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-arm-kernel@lists.infradead.org, ankit.jindal@linaro.org,
	steve.mcintyre@linaro.org, tushar.jagad@linaro.org,
	will.deacon@arm.com, catalin.marinas@arm.com,
	netdev@vger.kernel.org, nico@fluxnic.net
To: matthew.leach@arm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56380 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752110Ab3JKV4Y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Oct 2013 17:56:24 -0400
In-Reply-To: <1381499540-28794-15-git-send-email-matthew.leach@arm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Matthew Leach <matthew.leach@arm.com>
Date: Fri, 11 Oct 2013 14:52:20 +0100

> From: Will Deacon <will.deacon@arm.com>
> 
> SMC_outw invokes an endian-aware I/O accessor, which may change the data
> endianness before writing to the device. This is not suitable for data
> transfers where the memory buffer is simply a string of bytes that does
> not require any byte-swapping.
> 
> This patches fixes the smc91x SMC_PUSH_DATA macro so that it uses the
> string I/O accessor for outputting the leading or trailing halfwords on
> halfword-aligned buffers.
> 
> Cc: <netdev@vger.kernel.org>
> Cc: Nicolas Pitre <nico@fluxnic.net>
> Cc: David S. Miller <davem@davemloft.net>
> Signed-off-by: Will Deacon <will.deacon@arm.com>

Applied.
