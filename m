From: David Miller <davem@davemloft.net>
Subject: Re: [patch 4/4] pxa168_eth: silence gcc warnings
Date: Tue, 24 Aug 2010 14:51:03 -0700 (PDT)
Message-ID: <20100824.145103.70214095.davem@davemloft.net>
References: <20100824165505.GK29330@bicker>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ssanap@marvell.com, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: error27@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53406
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756129Ab0HXVup (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Aug 2010 17:50:45 -0400
In-Reply-To: <20100824165505.GK29330@bicker>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Carpenter <error27@gmail.com>
Date: Tue, 24 Aug 2010 18:55:05 +0200

> Casting "pep->tx_desc_dma" to to a struct tx_desc pointer makes gcc
> complain:
> 
> drivers/net/pxa168_eth.c:657: warning:
> 	cast to pointer from integer of different size
> 
> Signed-off-by: Dan Carpenter <error27@gmail.com>

Applied.
