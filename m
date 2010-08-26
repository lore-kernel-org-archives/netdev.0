From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] mlx4_core: module param to limit msix vec allocation
Date: Thu, 26 Aug 2010 12:24:07 -0700 (PDT)
Message-ID: <20100826.122407.260097270.davem@davemloft.net>
References: <20100826170646.GB27157@sgi.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: akepner@sgi.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51074
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753382Ab0HZTXv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Aug 2010 15:23:51 -0400
In-Reply-To: <20100826170646.GB27157@sgi.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arthur Kepner <akepner@sgi.com>
Date: Thu, 26 Aug 2010 10:06:46 -0700

> Use a module parameter to limit the number of MSI-X vectors that 
> the mlx4_core driver will attempt to allocate.
> 
> Signed-off-by: Arthur Kepner <akepner@sgi.com>

And what the heck happens if every single device driver tries to
handle this problem in the same way?  It makes no sense to make
the user specify N special module parameters just to get a working
system using MSI-X.

This must be fixed in a centralized way that allows coordination
between devices which compete for MSI-X vector resources, rather than
in a way that is specific to each and every device type.

I am not applying this patch, sorry.
