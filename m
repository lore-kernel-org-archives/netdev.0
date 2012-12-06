From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tulip: Fix compiler warning when
 CONFIG_DEBUG_SECTION_MISMATCH=y
Date: Thu, 06 Dec 2012 16:35:05 -0500 (EST)
Message-ID: <20121206.163505.1977671697087736227.davem@davemloft.net>
References: <1354799067-25680-1-git-send-email-christoph.paasch@uclouvain.be>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: grundler@parisc-linux.org, netdev@vger.kernel.org
To: christoph.paasch@uclouvain.be
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48072 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1424779Ab2LFVfI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Dec 2012 16:35:08 -0500
In-Reply-To: <1354799067-25680-1-git-send-email-christoph.paasch@uclouvain.be>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Christoph Paasch <christoph.paasch@uclouvain.be>
Date: Thu,  6 Dec 2012 14:04:27 +0100

> WARNING: drivers/net/ethernet/dec/tulip/tulip.o(.text+0x4057): Section
> mismatch in reference from the function tulip_init_one() to the variable
> .devinit.rodata:early_486_chipsets
> The function tulip_init_one() references
> the variable __devinitconst early_486_chipsets.
> This is often because tulip_init_one lacks a __devinitconst
> annotation or the annotation of early_486_chipsets is wrong.
> 
> Signed-off-by: Christoph Paasch <christoph.paasch@uclouvain.be>

Can you at least do the bare minimum amount of research when making
"fixes" like this?

These __devinit removals were done on purpose.
