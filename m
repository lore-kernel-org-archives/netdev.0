From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] ibmveth: Fix oops on request_irq failure
Date: Thu, 29 Sep 2011 00:34:44 -0400 (EDT)
Message-ID: <20110929.003444.288841051862935342.davem@davemloft.net>
References: <201109281533.p8SFXhfe030707@d03av04.boulder.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: brking@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:46301 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752846Ab1I2EfC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Sep 2011 00:35:02 -0400
In-Reply-To: <201109281533.p8SFXhfe030707@d03av04.boulder.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Brian King <brking@linux.vnet.ibm.com>
Date: Wed, 28 Sep 2011 10:33:43 -0500

> 
> If request_irq fails, the ibmveth driver will overwrite
> the rc and end up returning a successful rc on its open
> function, resulting in an oops later when a packet gets
> sent and buffers are not allocated due to the failed open.
> 
> Signed-off-by: Brian King <brking@linux.vnet.ibm.com>

Applied.
