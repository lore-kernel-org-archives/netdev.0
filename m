From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] bnxt: add dma mapping attributes
Date: Tue, 09 May 2017 20:49:37 -0400 (EDT)
Message-ID: <20170509.204937.115947896476049334.davem@davemloft.net>
References: <1494362253-270990-1-git-send-email-shannon.nelson@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, sparclinux@vger.kernel.org
To: shannon.nelson@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:35126 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751353AbdEJAtl (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 9 May 2017 20:49:41 -0400
In-Reply-To: <1494362253-270990-1-git-send-email-shannon.nelson@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shannon Nelson <shannon.nelson@oracle.com>
Date: Tue,  9 May 2017 13:37:33 -0700

> @@ -66,6 +66,12 @@
>  MODULE_DESCRIPTION("Broadcom BCM573xx network driver");
>  MODULE_VERSION(DRV_MODULE_VERSION);
>  
> +#ifdef CONFIG_SPARC
> +#define BNXT_DMA_ATTRS  DMA_ATTR_WEAK_ORDERING
> +#else
> +#define BNXT_DMA_ATTRS	0
> +#endif
> +

I do not what this ifdef crap showing up in every driver just
to improve performance on one platform.

This needs to be generically done somehow in a way that
drivers get the correct setting automatically and without
ifdef checks.
