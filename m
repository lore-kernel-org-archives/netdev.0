From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] drivers/net: ks8842 Fix crash on received packet when
 in PIO mode.
Date: Thu, 19 May 2011 16:12:28 -0400 (EDT)
Message-ID: <20110519.161228.1163475688237712245.davem@davemloft.net>
References: <20110518225945.GB6416@dens-work>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: info@mocean-labs.com, netdev@vger.kernel.org
To: dennis.aberilla@mimomax.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:35697 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934076Ab1ESUMg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 May 2011 16:12:36 -0400
In-Reply-To: <20110518225945.GB6416@dens-work>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dennis Aberilla <dennis.aberilla@mimomax.com>
Date: Thu, 19 May 2011 10:59:47 +1200

> This patch fixes a kernel crash during packet reception due to not
> enough allocated bytes for the skb. This applies to the driver when
> running in PIO mode in an ISA bus setup.
> 
> Signed-off-by: Dennis Aberilla <denzzzhome@yahoo.com>

If you're trying to accomodate the fact that the loops iterate
always by 2 or 4 bytes at a time, then you will need to allocate
up to "3" bytes of slack space, not just "2".

You need to describe exactly what the precise problem is in your
commit message, or else people might find it difficult to figure
out exactly what the problem is.
