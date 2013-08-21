From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 5/7] bcm63xx_enet: replace devm_request_and_ioremap by
 devm_ioremap_resource
Date: Tue, 20 Aug 2013 23:22:40 -0700 (PDT)
Message-ID: <20130820.232240.98227185752652907.davem@davemloft.net>
References: <1376911241-27720-1-git-send-email-Julia.Lawall@lip6.fr>
	<1376911241-27720-6-git-send-email-Julia.Lawall@lip6.fr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kernel-janitors@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Julia.Lawall@lip6.fr
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52081 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752098Ab3HUGWl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Aug 2013 02:22:41 -0400
In-Reply-To: <1376911241-27720-6-git-send-email-Julia.Lawall@lip6.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Julia Lawall <Julia.Lawall@lip6.fr>
Date: Mon, 19 Aug 2013 13:20:39 +0200

> From: Julia Lawall <Julia.Lawall@lip6.fr>
> 
> Use devm_ioremap_resource instead of devm_request_and_ioremap.
> 
> This was done using the semantic patch
> scripts/coccinelle/api/devm_ioremap_resource.cocci
> 
> The relevant call to platform_get_resource was manually moved down to the
> call to devm_ioremap_resource.
> 
> Signed-off-by: Julia Lawall <Julia.Lawall@lip6.fr>

Applied to net-next, thanks.
