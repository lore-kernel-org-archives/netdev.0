From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] w83977af_ir: remove two faux Kconfig macros
Date: Wed, 07 May 2014 15:24:33 -0400 (EDT)
Message-ID: <20140507.152433.1601521913694225915.davem@davemloft.net>
References: <1399201392.8729.7.camel@x220>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: samuel@sortiz.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: pebolle@tiscali.nl
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51055 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750949AbaEGTYf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 May 2014 15:24:35 -0400
In-Reply-To: <1399201392.8729.7.camel@x220>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paul Bolle <pebolle@tiscali.nl>
Date: Sun, 04 May 2014 13:03:12 +0200

> Ever since v2.3.5 the driver for "Winbond W83977AF (IR)" contains two
> unneeded preprocessor macros.
> 
> CONFIG_NETWINDER_TX_DMA_PROBLEMS is never defined and can safely be
> removed. And CONFIG_NETWINDER_RX_DMA_PROBLEMS is just an alias for
> CONFIG_ARCH_NETWINDER, so that (valid) Kconfig macro can be used
> instead.
> 
> Signed-off-by: Paul Bolle <pebolle@tiscali.nl>
> ---
> Compile tested only (on x86_64, that is).
> 
> I sneaked in a related whitespace fix.

Applied to net-next, thanks.
