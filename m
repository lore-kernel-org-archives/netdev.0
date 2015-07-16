From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH V2 net-next 2/3] net: introduce socket family constants
Date: Wed, 15 Jul 2015 21:29:33 -0700 (PDT)
Message-ID: <20150715.212933.2174174212971221554.davem@davemloft.net>
References: <1436877755-23431-1-git-send-email-ubraun@linux.vnet.ibm.com>
	<1436877755-23431-3-git-send-email-ubraun@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: utz.bacher@de.ibm.com, netdev@vger.kernel.org,
	linux-s390@vger.kernel.org, schwidefsky@de.ibm.com,
	heiko.carstens@de.ibm.com, ursula.braun@de.ibm.com
To: ubraun@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35271 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751424AbbGPE3e (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jul 2015 00:29:34 -0400
In-Reply-To: <1436877755-23431-3-git-send-email-ubraun@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ursula Braun <ubraun@linux.vnet.ibm.com>
Date: Tue, 14 Jul 2015 14:42:34 +0200

> diff --git a/net/Kconfig b/net/Kconfig
> index 57a7c5a..d829694 100644
> --- a/net/Kconfig
> +++ b/net/Kconfig
> @@ -54,6 +54,7 @@ source "net/packet/Kconfig"
>  source "net/unix/Kconfig"
>  source "net/xfrm/Kconfig"
>  source "net/iucv/Kconfig"
> +source "net/smc/Kconfig"

This breaks the build, every patch in the series must leave the kernel
in a consistent, building, working state.

This patch series submission is of very low quality.
