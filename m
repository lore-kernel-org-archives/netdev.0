From: David Miller <davem@davemloft.net>
Subject: Re: [patch 2/4] pxa168_eth: fix error handling in prope
Date: Tue, 24 Aug 2010 14:50:47 -0700 (PDT)
Message-ID: <20100824.145047.179951528.davem@davemloft.net>
References: <20100824165333.GI29330@bicker>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ssanap@marvell.com, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: error27@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53396
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756100Ab0HXVu3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Aug 2010 17:50:29 -0400
In-Reply-To: <20100824165333.GI29330@bicker>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Carpenter <error27@gmail.com>
Date: Tue, 24 Aug 2010 18:53:33 +0200

> A couple issues here:
> * Some resources weren't released.  
> * If alloc_etherdev() failed it would have caused a NULL dereference
>   because "pep" would be null when we checked "if (pep->clk)".
> * Also it's better to propagate the error codes from mdiobus_register()
>   instead of just returning -ENOMEM.
> 
> Signed-off-by: Dan Carpenter <error27@gmail.com>

Applied.
