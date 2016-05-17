From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] r8169: default to 64-bit DMA on recent PCIe chips
Date: Tue, 17 May 2016 14:22:38 -0400 (EDT)
Message-ID: <20160517.142238.1044761521251148537.davem@davemloft.net>
References: <1463258415-31072-1-git-send-email-ard.biesheuvel@linaro.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, romieu@fr.zoreil.com,
	ricardo.salveti@linaro.org, leif.lindholm@linaro.org,
	graeme.gregory@linaro.org, amit.kucheria@linaro.org,
	nic_swsd@realtek.com
To: ard.biesheuvel@linaro.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49284 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752386AbcEQSWk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 May 2016 14:22:40 -0400
In-Reply-To: <1463258415-31072-1-git-send-email-ard.biesheuvel@linaro.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Date: Sat, 14 May 2016 22:40:15 +0200

> The current logic around the 'use_dac' module parameter prevents the
> r81969 driver from being loadable on 64-bit systems without any RAM
> below 4 GB when the parameter is left at its default value.
> 
> So introduce a new default value -1 which indicates that 64-bit DMA
> should be enabled on sufficiently recent PCIe chips, i.e., versions
> RTL_GIGA_MAC_VER_18 or later. Explicit param values of 0 or 1 retain
> the existing behavior of unconditionally enabling/disabling 64-bit DMA
> on 64-bit architectures (i.e., regardless of the type and version of the
> chip)
> 
> Since PCIe chips do not need to CPlusCmd Dual Address Cycle to be set,
> make that conditional on the device type as well.
> 
> Cc: Realtek linux nic maintainers <nic_swsd@realtek.com>
> Signed-off-by: Ard Biesheuvel <ard.biesheuvel@linaro.org>

Applied, let's see what happens...
