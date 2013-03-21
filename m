From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] sh_eth: fix unused variable warning
Date: Thu, 21 Mar 2013 18:27:50 -0400 (EDT)
Message-ID: <20130321.182750.1209336291753319090.davem@davemloft.net>
References: <201303220159.00633.sergei.shtylyov@cogentembedded.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nobuhiro.iwamatsu.yj@renesas.com
To: sergei.shtylyov@cogentembedded.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48019 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932925Ab3CUW1y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Mar 2013 18:27:54 -0400
In-Reply-To: <201303220159.00633.sergei.shtylyov@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Date: Fri, 22 Mar 2013 01:59:00 +0300

> Commit d5e07e69218fd9aa21d6c8c5ccc629d92bdb9b0f (sh_eth: use managed device API)
> has caused this warning (due to my overlook):
> 
> drivers/net/ethernet/renesas/sh_eth.c: In function `sh_eth_drv_remove':
> drivers/net/ethernet/renesas/sh_eth.c:2482:25: warning: unused variable `mdp'
> [-Wunused-variable]
> 
> Kill the darn variable now...
> 
> Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

Applied, thanks.
