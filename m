From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: eth: xgene: change APM X-Gene SoC platform
 ethernet to support ACPI
Date: Fri, 19 Dec 2014 12:31:07 -0500 (EST)
Message-ID: <20141219.123107.1080751255468272638.davem@davemloft.net>
References: <1418945991-31494-1-git-send-email-fkan@apm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, patches@apm.com,
	linux-kernel@vger.kernel.org
To: fkan@apm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57904 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751082AbaLSRbK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Dec 2014 12:31:10 -0500
In-Reply-To: <1418945991-31494-1-git-send-email-fkan@apm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Feng Kan <fkan@apm.com>
Date: Thu, 18 Dec 2014 15:39:51 -0800

> +#define NO_MAC_FOUND	0
> +#define RES_ENET_CSR	0
> +#define RES_RING_CSR	1
> +#define RES_RING_CMD	2

Don't define your own magic set of error return semantics.

For example, in the MAC address acquisition case, just verify that
you get an ETH_ALEN length value from the fetch routines and return
-ENODEV or similar if you do not.
