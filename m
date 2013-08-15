From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 1/3] drivers/net: enic: Adding support for Cisco Low
 Latency NIC
Date: Thu, 15 Aug 2013 01:19:00 -0700 (PDT)
Message-ID: <20130815.011900.535860284018965484.davem@davemloft.net>
References: <1376432265-5497-1-git-send-email-neepatel@cisco.com>
	<1376432265-5497-2-git-send-email-neepatel@cisco.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, umalhi@cisco.com, nistrive@cisco.com,
	benve@cisco.com
To: neepatel@cisco.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37660 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755002Ab3HOITC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Aug 2013 04:19:02 -0400
In-Reply-To: <1376432265-5497-2-git-send-email-neepatel@cisco.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neel Patel <neepatel@cisco.com>
Date: Tue, 13 Aug 2013 15:17:43 -0700

> +static inline u64 vnic_cached_posted_index(dma_addr_t addr,
> +	unsigned int len, unsigned int index)

You are adding functions in this patch which are not used, therefore
breaking bisectability because after just this patch is applied
the compiler will warn about the static unused function.
