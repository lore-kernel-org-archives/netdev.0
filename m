From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH RFT] 3c59x: fix freeing nonexistent resource on driver
 unload
Date: Mon, 06 May 2013 12:22:36 -0400 (EDT)
Message-ID: <20130506.122236.49412750367407481.davem@davemloft.net>
References: <201305030110.22462.sergei.shtylyov@cogentembedded.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, klassert@mathematik.tu-chemnitz.de,
	tedheadster@gmail.com
To: sergei.shtylyov@cogentembedded.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59942 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753733Ab3EFQWi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 May 2013 12:22:38 -0400
In-Reply-To: <201305030110.22462.sergei.shtylyov@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Date: Fri, 3 May 2013 01:10:22 +0400

> When unloading the driver that drives an EISA board, a message similar to the
> following one is displayed:
> 
> Trying to free nonexistent resource <0000000000013000-000000000001301f>
> 
> Then an user is unable to reload the driver because the resource it requested in
> the previous load hasn't been freed. This happens most probably due to a typo in
> vortex_eisa_remove() which calls release_region() with 'dev->base_addr'  instead
> of 'edev->base_addr'...
> 
> Reported-by: Matthew Whitehead <tedheadster@gmail.com>
> Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

Applied, thanks.
