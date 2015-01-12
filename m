From: David Miller <davem@davemloft.net>
Subject: Re: [patch -next] net: eth: xgene: devm_ioremap() returns NULL on
 error
Date: Mon, 12 Jan 2015 15:40:50 -0500 (EST)
Message-ID: <20150112.154050.544393600960931935.davem@davemloft.net>
References: <20150108105211.GB10597@mwanda>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: isubramanian@apm.com, fkan@apm.com, kchudgar@apm.com,
	grant.likely@linaro.org, robh+dt@kernel.org,
	netdev@vger.kernel.org, kernel-janitors@vger.kernel.org
To: dan.carpenter@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53585 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752117AbbALUkx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Jan 2015 15:40:53 -0500
In-Reply-To: <20150108105211.GB10597@mwanda>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Thu, 8 Jan 2015 13:52:12 +0300

> devm_ioremap() returns NULL on failure, it doesn't return an ERR_PTR.
> 
> Fixes: de7b5b3d790a ('net: eth: xgene: change APM X-Gene SoC platform ethernet to support ACPI')
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

Applied, thanks.
