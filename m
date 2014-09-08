From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] drivers: net: ethernet: octeon_mgmt: fix a compiler
 warning
Date: Mon, 08 Sep 2014 14:24:01 -0700 (PDT)
Message-ID: <20140908.142401.1360869498562836138.davem@davemloft.net>
References: <1410188513-2541-1-git-send-email-aaro.koskinen@nsn.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, david.daney@cavium.com
To: aaro.koskinen@nsn.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44447 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754096AbaIHVYC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Sep 2014 17:24:02 -0400
In-Reply-To: <1410188513-2541-1-git-send-email-aaro.koskinen@nsn.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Aaro Koskinen <aaro.koskinen@nsn.com>
Date: Mon,  8 Sep 2014 18:01:53 +0300

> Fix the following compiler warning:
> 
> drivers/net/ethernet/octeon/octeon_mgmt.c: In function 'octeon_mgmt_clean_tx_buffers':
> drivers/net/ethernet/octeon/octeon_mgmt.c:295:4: warning: ISO C90 forbids mixed declarations and code [-Wdeclaration-after-statement]
>     u64 ns = cvmx_read_csr(CVMX_MIXX_TSTAMP(p->port));
>     ^
> 
> Signed-off-by: Aaro Koskinen <aaro.koskinen@nsn.com>

Applied, thank you.
