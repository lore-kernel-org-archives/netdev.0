From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] sh_eth: kill 'ret' variable in sh_eth_ring_init()
Date: Wed, 04 Nov 2015 20:59:33 -0500 (EST)
Message-ID: <20151104.205933.1566095146723535499.davem@davemloft.net>
References: <3103690.zc6n37veWQ@wasted.cogentembedded.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sh@vger.kernel.org
To: sergei.shtylyov@cogentembedded.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59344 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1031116AbbKEB7f (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Nov 2015 20:59:35 -0500
In-Reply-To: <3103690.zc6n37veWQ@wasted.cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Date: Wed, 04 Nov 2015 00:17:08 +0300

> The 'ret' local variable in sh_eth_ring_init() serves no useful purpose as
> the only  values it gets assigned are 0 and -ENOMEM both of which could be
> returned directly...
> 
> Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

Applied.
