From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] ehea: Reduce memory usage in buffer pools
Date: Fri, 25 Nov 2011 13:00:21 -0500 (EST)
Message-ID: <20111125.130021.1921439178229825424.davem@davemloft.net>
References: <20111123211302.2a37debb@kryten>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: cascardo@linux.vnet.ibm.com, netdev@vger.kernel.org
To: anton@samba.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:56359 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752568Ab1KYSAb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Nov 2011 13:00:31 -0500
In-Reply-To: <20111123211302.2a37debb@kryten>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Anton Blanchard <anton@samba.org>
Date: Wed, 23 Nov 2011 21:13:02 +1100

> 
> Now that we enable multiqueue by default the ehea driver is using
> quite a lot of memory for its buffer pools. With 4 queues we
> consume 64MB in the jumbo packet ring, 16MB in the medium packet
> ring and 16MB in the tiny packet ring.
> 
> We should only fill the jumbo ring once the MTU is increased but
> for now halve it's size so it consumes 32MB. Also reduce the tiny
> packet ring, with 4 queues we had 16k entries which is overkill.
> 
> Signed-off-by: Anton Blanchard <anton@samba.org>

Applied.
