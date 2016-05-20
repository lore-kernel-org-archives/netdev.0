From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 1/1] qede: Fix DMA address APIs usage
Date: Fri, 20 May 2016 11:16:03 -0700 (PDT)
Message-ID: <20160520.111603.545404329493208707.davem@davemloft.net>
References: <1463571837-8146-1-git-send-email-manish.chopra@qlogic.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Ariel.Elior@qlogic.com,
	Yuval.Mintz@qlogic.com
To: manish.chopra@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51689 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750869AbcETSQE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 May 2016 14:16:04 -0400
In-Reply-To: <1463571837-8146-1-git-send-email-manish.chopra@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Manish Chopra <manish.chopra@qlogic.com>
Date: Wed, 18 May 2016 07:43:57 -0400

> Driver incorrectly uses dma_unmap_addr_set() to set
> a variable which is in truth a dma_addr_t
> [i.e not defined using DEFINE_DMA_UNMAP_ADDR()] and is
> being used by the driver flows other than unmapping
> physical addresses. This patch fixes driver fastpath
> where CONFIG_NEED_DMA_MAP_STATE is not set.
> 
> Signed-off-by: Manish Chopra <manish.chopra@qlogic.com>
> Signed-off-by: Yuval Mintz <Yuval.Mintz@qlogic.com>

Applied, thanks.
