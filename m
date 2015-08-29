From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] sh_eth: propagate platform_get_irq() error upstream
Date: Fri, 28 Aug 2015 22:26:22 -0700 (PDT)
Message-ID: <20150828.222622.1553006557820565400.davem@davemloft.net>
References: <9944836.IRPmWk4iN8@wasted.cogentembedded.com>
	<1774140.R12mtes975@wasted.cogentembedded.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sh@vger.kernel.org,
	horms@verge.net.au
To: sergei.shtylyov@cogentembedded.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58281 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752626AbbH2F0X (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 29 Aug 2015 01:26:23 -0400
In-Reply-To: <1774140.R12mtes975@wasted.cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Date: Fri, 28 Aug 2015 16:56:01 +0300

> The driver overrides the error returned by platform_get_irq() with -ENODEV
> which e.g. precludes the deferred  probing from working. Propagate the real
> error code to the driver core instead.
> 
> Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

Applied.
