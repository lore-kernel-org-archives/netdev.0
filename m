From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] xen-netback: include definition of csum_ipv6_magic
Date: Thu, 28 Nov 2013 18:38:54 -0500 (EST)
Message-ID: <20131128.183854.1965568926565257648.davem@davemloft.net>
References: <1385398354-21636-1-git-send-email-apw@canonical.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ian.campbell@citrix.com, wei.liu2@citrix.com,
	xen-devel@lists.xenproject.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: apw@canonical.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47452 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751891Ab3K1Xi4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Nov 2013 18:38:56 -0500
In-Reply-To: <1385398354-21636-1-git-send-email-apw@canonical.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andy Whitcroft <apw@canonical.com>
Date: Mon, 25 Nov 2013 16:52:34 +0000

> We are now using csum_ipv6_magic, include the appropriate header.
> Avoids the following error:
> 
>     drivers/net/xen-netback/netback.c:1313:4: error: implicit declaration of function 'csum_ipv6_magic' [-Werror=implicit-function-declaration]
>         tcph->check = ~csum_ipv6_magic(&ipv6h->saddr,
> 
> Signed-off-by: Andy Whitcroft <apw@canonical.com>

Applied, thank you.
