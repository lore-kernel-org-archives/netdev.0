From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ndisc: Fix padding error in link-layer address option.
Date: Thu, 13 Dec 2012 13:01:45 -0500 (EST)
Message-ID: <20121213.130145.1818787055621467467.davem@davemloft.net>
References: <201212131429.qBDETaa6029537@94.43.138.210.xn.2iij.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39877 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755684Ab2LMSBt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Dec 2012 13:01:49 -0500
In-Reply-To: <201212131429.qBDETaa6029537@94.43.138.210.xn.2iij.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date: Thu, 13 Dec 2012 23:29:36 +0900

> If a natural number n exists where 2 + data_len <= 8n < 2 + data_len + pad,
> post padding is not initialized correctly.
> 
> (Un)fortunately, the only type that requires pad is Infiniband,
> whose pad is 2 and data_len is 20, and this logical error has not
> become obvious, but it is better to fix.
> 
> Note that ndisc_opt_addr_space() handles the situation described
> above correctly.
> 
> Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

Applied.
