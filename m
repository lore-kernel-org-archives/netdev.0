From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ucc_geth: Pass proper device to DMA routines,
 otherwise oops happens
Date: Thu, 02 Apr 2009 01:26:18 -0700 (PDT)
Message-ID: <20090402.012618.151021224.davem@davemloft.net>
References: <20090331185837.GA22545@oksana.dev.rtsoft.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Joakim.Tjernlund@transmode.se, afleming@freescale.com,
	leoli@freescale.com, netdev@vger.kernel.org,
	linuxppc-dev@ozlabs.org
To: avorontsov@ru.mvista.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52258
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752822AbZDBI0a (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Apr 2009 04:26:30 -0400
In-Reply-To: <20090331185837.GA22545@oksana.dev.rtsoft.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Anton Vorontsov <avorontsov@ru.mvista.com>
Date: Tue, 31 Mar 2009 22:58:37 +0400

> The driver should pass a device that actually specifies internal DMA
> ops, but currently it passes netdev's device, which is wrong and that
> causes following oops:
 ...
> Fix this by passing of_device's device that specifies DMA ops in its
> archdata.
> 
> Signed-off-by: Anton Vorontsov <avorontsov@ru.mvista.com>

Applied, thanks.
