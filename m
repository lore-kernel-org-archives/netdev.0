From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: via-rhine: Convert #ifdef USE_MMIO to a runtime
 flag
Date: Mon, 05 May 2014 15:37:31 -0400 (EDT)
Message-ID: <20140505.153731.953697715071354770.davem@davemloft.net>
References: <20140502.155635.1691085402453175737.davem@davemloft.net>
	<1399120853-26967-1-git-send-email-alchark@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: rl@hellgate.ch, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, fengguang.wu@intel.com
To: alchark@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:32775 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751751AbaEEThd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 May 2014 15:37:33 -0400
In-Reply-To: <1399120853-26967-1-git-send-email-alchark@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexey Charkov <alchark@gmail.com>
Date: Sat,  3 May 2014 16:40:53 +0400

> This introduces another flag in 'quirks' to replace the preprocessor
> define (USE_MMIO) used to indicate whether the device needs a
> separate enable routine to operate in MMIO mode.
> 
> All of the currently known platform Rhine cores operate in MMIO
> mode by default, and on PCI it is preferred over PIO for performance
> reasons. However, a comment in code suggests that some (?) early
> Rhine cores only work in PIO mode, so they should not be switched
> to MMIO.
> 
> Enabling MMIO on PCI is still triggered by the same Kconfig option
> to avoid breaking user configs needlessly, but this can be changed
> going forward towards automatic runtime detection in case a list of
> PIO-only Rhine revisions can be compiled.
> 
> This also fixes a couple of compiler warnings detected by Fengguang
> Wu's test bot (!USE_MMIO case):
 ...
> Signed-off-by: Alexey Charkov <alchark@gmail.com>

Applied, but in the future please make it clear what tree you are
targetting by saying "[PATCH net]" or "[PATCH net-next]" in your
subject line.

Thanks.
