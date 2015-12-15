From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v5 net-next 4/4] ila: Add generic ILA translation
 facility
Date: Mon, 14 Dec 2015 23:50:45 -0500 (EST)
Message-ID: <20151214.235045.1657196344079746671.davem@davemloft.net>
References: <1450137408-2589240-1-git-send-email-tom@herbertland.com>
	<1450137408-2589240-5-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kernel-team@fb.com
To: tom@herbertland.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38117 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933098AbbLOEut (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Dec 2015 23:50:49 -0500
In-Reply-To: <1450137408-2589240-5-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Herbert <tom@herbertland.com>
Date: Mon, 14 Dec 2015 15:56:48 -0800

> +static int alloc_ila_locks(struct ila_net *ilan, gfp_t gfp)

gfp is always GFP_KERNEL, thus this flexibility is never
necessary.
